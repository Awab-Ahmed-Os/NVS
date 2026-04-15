import logging
from flask import Blueprint, request, jsonify, make_response
from .models import db, Scan, Port, Vulnerability, ScanVulnerability, Remediation
from .scanner import run_nmap_scan
from .utils import match_vulnerabilities
from .report_generator import generate_pdf_report
from .ai_agent import generate_remediation
from datetime import datetime
import threading

main = Blueprint('main', __name__)

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Health check route
@main.route('/')
def index():
    return jsonify({"message": "CVE Scanner API is running with Gemini AI"})

# Get all vulnerabilities
@main.route('/vulnerabilities', methods=['GET'])
def get_vulnerabilities():
    vulns = Vulnerability.query.all()
    return jsonify([
        {
            "vuln_id": v.vuln_id,
            "cve_id": v.cve_id,
            "description": v.description,
            "cvss_score": v.cvss_score,
            "severity": v.severity,
            "reference_url": v.reference_url
        } for v in vulns
    ])

# Get scan history
@main.route('/history', methods=['GET'])
def get_history():
    scans = Scan.query.all()
    history = []
    for scan in scans:
        history.append({
            "scan_id": scan.scan_id,
            "target_ip": scan.target_ip,
            "scan_type": scan.scan_type,
            "status": scan.status,
            "start_time": scan.start_time.isoformat() if scan.start_time else None,
            "end_time": scan.end_time.isoformat() if scan.end_time else None
        })
    return jsonify(history)

def perform_scan(scan_id, target_ip, scan_type, port_from, port_to):
    try:
        results = run_nmap_scan(target_ip, scan_type, port_from, port_to)
        for result in results:
            port = Port(
                scan_id=scan_id,
                port_number=result['port_number'],
                protocol=result['protocol'],
                states=result['state'],
                service_name=result.get('service_name', '')
            )
            db.session.add(port)
        db.session.commit()

        # Match vulnerabilities
        match_vulnerabilities(scan_id, Port.query.filter_by(scan_id=scan_id).all())

        scan = Scan.query.get(scan_id)
        scan.end_time = datetime.utcnow()
        scan.status = 'success'
        db.session.commit()
        logger.info(f"Scan {scan_id} completed successfully")
    except Exception as e:
        scan = Scan.query.get(scan_id)
        scan.status = 'error'
        scan.end_time = datetime.utcnow()
        db.session.commit()
        logger.error(f"Scan {scan_id} failed: {str(e)}")

# Start a new scan
@main.route('/scan', methods=['POST'])
def start_scan():
    logger.info("Received /scan POST request")
    data = request.json
    logger.info(f"Request JSON data: {data}")
    target_ip = data.get('target_ip')
    scan_type = data.get('scan_type', 'TCP')
    port_from = data.get('port_from')
    port_to = data.get('port_to')

    if not target_ip:
        logger.warning("Scan start failed: target_ip is missing")
        return jsonify({"error": "target_ip is required"}), 400

    logger.info(f"Starting new scan for IP: {target_ip}, type: {scan_type}, ports: {port_from}-{port_to}")

    new_scan = Scan(
        target_ip=target_ip,
        scan_type=scan_type,
        start_time=datetime.utcnow(),
        status='running'
    )
    db.session.add(new_scan)
    db.session.commit()

    thread = threading.Thread(target=perform_scan, args=(new_scan.scan_id, target_ip, scan_type, port_from, port_to))
    thread.start()

    logger.info(f"Scan started asynchronously with scan_id: {new_scan.scan_id}")

    return jsonify({
        "message": "Scan started",
        "scan_id": new_scan.scan_id
    }), 201

# Get scan results
@main.route('/scan/<int:scan_id>', methods=['GET'])
def get_scan_results(scan_id):
    logger.info(f"Fetching results for scan_id: {scan_id}")
    scan = Scan.query.get_or_404(scan_id)
    ports = Port.query.filter_by(scan_id=scan_id).all()

    port_data = [{
        "port_number": p.port_number,
        "protocol": p.protocol,
        "state": p.states,
        "service_name": p.service_name
    } for p in ports]

    result = {
        "scan_id": scan.scan_id,
        "target_ip": scan.target_ip,
        "status": scan.status,
        "start_time": scan.start_time,
        "end_time": scan.end_time,
        "ports": port_data
    }
    logger.info(f"Returning results for scan_id {scan_id}: {len(port_data)} ports found")
    return jsonify(result)

# Get matched vulnerabilities
@main.route('/scan/<int:scan_id>/vulnerabilities', methods=['GET'])
def get_scan_vulnerabilities(scan_id):
    logger.info(f"Fetching vulnerabilities for scan_id: {scan_id}")
    matches = ScanVulnerability.query.filter_by(scan_id=scan_id).all()
    results = []

    for match in matches:
        vuln = Vulnerability.query.get(match.vuln_id)
        remediation = Remediation.query.filter_by(vuln_id=vuln.vuln_id).first()

        results.append({
            "cve_id": vuln.cve_id,
            "description": vuln.description,
            "cvss_score": float(vuln.cvss_score) if vuln.cvss_score is not None else 0.0,
            "severity": vuln.severity,
            "reference_url": vuln.reference_url,
            "match_confidence": match.match_confidence,
            "remediation": remediation.recommendation if remediation else None
        })
    logger.info(f"Returning {len(results)} vulnerabilities for scan_id {scan_id}")
    return jsonify(results)

# Generate PDF report
@main.route('/scan/<int:scan_id>/report', methods=['GET'])
def download_report(scan_id):
    scan = Scan.query.get_or_404(scan_id)
    try:
        pdf_data = generate_pdf_report(scan_id)
        response = make_response(pdf_data)
        response.headers['Content-Type'] = 'application/pdf'
        response.headers['Content-Disposition'] = f'attachment; filename=scan_report_{scan_id}.pdf'
        return response
    except Exception as e:
        logger.error(f"Error generating PDF report for scan {scan_id}: {str(e)}")
        return jsonify({"error": f"Failed to generate PDF report: {str(e)}"}), 500

# Welcome endpoint with logging
@main.route('/welcome', methods=['GET'])
def welcome():
    logger.info(f"Request received: {request.method} {request.path}")
    return jsonify({"message": "Welcome to the Flask API Service!"})

# AI Remediation endpoint
@main.route('/ai/remediate/<int:scan_id>', methods=['GET'])
def ai_remediate(scan_id):
    results = ScanVulnerability.query.filter_by(scan_id=scan_id).all()
    if not results:
        return jsonify({"error": "No CVEs found for this scan"}), 404

    output = []
    for result in results:
        vuln = Vulnerability.query.get(result.vuln_id)
        if vuln:
            try:
                suggestion = generate_remediation(vuln)
            except Exception as e:
                logger.error(f"Error generating AI remediation for {vuln.cve_id}: {str(e)}")
                suggestion = generate_remediation_fallback(vuln)
            output.append({
                "cve_id": vuln.cve_id,
                "remediation": suggestion
            })

    return jsonify({"remediation_suggestions": output})
