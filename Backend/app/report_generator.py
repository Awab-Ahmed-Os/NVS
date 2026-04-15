from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.platypus import HRFlowable
from reportlab.graphics.shapes import Drawing, Rect, String, Path
from .models import Scan, Port, ScanVulnerability, Vulnerability, Remediation
from datetime import datetime
import io

def generate_pdf_report(scan_id):
    scan = Scan.query.get(scan_id)
    if not scan:
        raise ValueError(f"Scan with ID {scan_id} not found")
    ports = Port.query.filter_by(scan_id=scan_id).all()
    # Filter to only open ports
    ports = [p for p in ports if p.states == 'open']
    matches = ScanVulnerability.query.filter_by(scan_id=scan_id).all()

    # Collect unique vulnerabilities with their details (to avoid duplicates in breakdown)
    unique_vulns = {}
    for match in matches:
        vuln = Vulnerability.query.get(match.vuln_id)
        if not vuln:
            continue
        if vuln.cve_id not in unique_vulns:
            remediation = Remediation.query.filter_by(vuln_id=vuln.vuln_id).first()
            unique_vulns[vuln.cve_id] = {
                'cve_id': vuln.cve_id,
                'severity': vuln.severity,
                'cvss_score': vuln.cvss_score,
                'description': vuln.description,
                'remediation': remediation.recommendation if remediation else 'N/A'
            }
    all_vulnerabilities = list(unique_vulns.values())

    # Calculate vulnerability counts (case insensitive)
    total_vulnerabilities = len(all_vulnerabilities)
    critical_vulns = len([v for v in all_vulnerabilities if (v['severity'] or '').lower() == 'critical'])
    high_vulns = len([v for v in all_vulnerabilities if (v['severity'] or '').lower() == 'high'])
    medium_vulns = len([v for v in all_vulnerabilities if (v['severity'] or '').lower() == 'medium'])
    low_vulns = len([v for v in all_vulnerabilities if (v['severity'] or '').lower() == 'low'])

    # Create PDF in memory
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, leftMargin=72, rightMargin=72, topMargin=72, bottomMargin=72)
    styles = getSampleStyleSheet()

    # Custom styles matching PDFPreviewScreen design
    title_style = ParagraphStyle('Title', parent=styles['Title'], fontSize=28, alignment=1, spaceAfter=12, fontName='Helvetica-Bold')
    subtitle_style = ParagraphStyle('Subtitle', parent=styles['Title'], fontSize=24, alignment=1, spaceAfter=24, fontName='Helvetica-Bold')
    heading2_style = ParagraphStyle('Heading2', parent=styles['Heading2'], fontSize=20, spaceAfter=12, fontName='Helvetica-Bold', borderWidth=0, borderColor=colors.black, borderPadding=2)
    normal_style = ParagraphStyle('Normal', parent=styles['Normal'], fontSize=14, alignment=0,  leading=18)
    footer_style = ParagraphStyle('Footer', parent=styles['Normal'], fontSize=10, alignment=0, textColor=colors.gray)

    story = []

    # Report Header - Stacked title
    story.append(Paragraph("Network Vulnerability Scanner", title_style))
    story.append(Paragraph("Scan Report", subtitle_style))
    # Horizontal line
    story.append(HRFlowable(width="100%", thickness=2, color=colors.black))

    # Report Details - Inline format
    story.append(Spacer(1, 12))
    details = [
        f"<b>Target IP or Hostname:</b> {scan.target_ip} ",
        f"<b>Scan Type:</b> {scan.scan_type}",
        f"<b>Start Time:</b> {scan.start_time.strftime('%Y-%m-%d %H:%M:%S') if scan.start_time else 'N/A'}",
        f"<b>End Time:</b> {scan.end_time.strftime('%Y-%m-%d %H:%M:%S') if scan.end_time else 'N/A'}"
    ]
    for detail in details:
        story.append(Paragraph(detail, normal_style))
    story.append(Spacer(1, 12))

    # Executive Summary - 2 boxes: Open Ports and Vulnerabilities
    story.append(Paragraph("Executive Summary", heading2_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.black))
    story.append(Spacer(1, 12))

    # Create summary boxes
    drawing = Drawing(440, 80)  # Width: 200*2 + 20*2 + 20 (spacing), Height: 80

    # Open Ports box (left) - Rectangle
    ports_rect = Rect(20, 0, 200, 80)
    ports_rect.fillColor = colors.Color(0xdc/255, 0xee/255, 0xff/255)
    ports_rect.strokeWidth = 0
    drawing.add(ports_rect)
    # Number: Bold, sans-serif, 32px, Blue (#007ACC)
    ports_number = String(120, 50, f'{len(ports)}', fontSize=32, fillColor=colors.Color(0x00/255, 0x7a/255, 0xcc/255), fontName='Helvetica-Bold', textAnchor='middle')
    drawing.add(ports_number)
    # Label: Regular, sans-serif, 16px, Dark blue (#003366)
    ports_label = String(120, 25, 'Open Ports', fontSize=16, fillColor=colors.Color(0x00/255, 0x33/255, 0x66/255), fontName='Helvetica', textAnchor='middle')
    drawing.add(ports_label)

    # Vulnerabilities box (right) - Rectangle
    vulns_rect = Rect(240, 0, 200, 80)
    vulns_rect.fillColor = colors.Color(0xff/255, 0xd6/255, 0xd6/255)
    vulns_rect.strokeWidth = 0
    drawing.add(vulns_rect)
    # Number: Bold, sans-serif, 32px, Red (#CC0000)
    vulns_number = String(340, 50, f'{total_vulnerabilities}', fontSize=32, fillColor=colors.Color(0xcc/255, 0x00/255, 0x00/255), fontName='Helvetica-Bold', textAnchor='middle')
    drawing.add(vulns_number)
    # Label: Regular, sans-serif, 16px, Dark red (#660000)
    vulns_label = String(340, 25, 'Vulnerabilities', fontSize=16, fillColor=colors.Color(0x66/255, 0x00/255, 0x00/255), fontName='Helvetica', textAnchor='middle')
    drawing.add(vulns_label)

    story.append(Spacer(1, 12))
    story.append(drawing)
    story.append(Spacer(1, 24))

    # Vulnerability Breakdown - Styled cards for each severity
    story.append(Paragraph("Vulnerability Breakdown", heading2_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.black))    
    story.append(Spacer(1, 12))

    # Critical vulnerabilities section
    if critical_vulns > 0:
        critical_data = [[
            Paragraph(f'<para><font size="12" color="red"><b>Critical</b></font> <font size="12" color="red">Immediate action required</font></para>', normal_style),
            Paragraph(f'<para align="right"><font size="18" color="red"><b>{critical_vulns}</b></font></para>', normal_style)
        ]]
        critical_table = Table(critical_data, colWidths=[420, 80])
        critical_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.Color(1, 0.95, 0.95)),  # Soft red
            ('BOX', (0, 0), (-1, -1), 1, colors.Color(0.83, 0.1, 0.1)),  # Deep Red border
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('PADDING', (0, 0), (-1, -1), 10),
        ]))
        story.append(critical_table)
        story.append(Spacer(1, 10))

    # High vulnerabilities section
    if high_vulns > 0:
        high_data = [[
            Paragraph(f'<para><font size="12" color="red"><b>High</b></font> <font size="12" color="red">High priority fixes needed</font></para>', normal_style),
            Paragraph(f'<para align="right"><font size="18" color="red"><b>{high_vulns}</b></font></para>', normal_style)
        ]]
        high_table = Table(high_data, colWidths=[420, 80])
        high_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.Color(1, 0.9, 0.9)),   # Light red-orange
            ('BOX', (0, 0), (-1, -1), 1, colors.Color(0.85, 0.25, 0.1)),  # Strong orange border
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('PADDING', (0, 0), (-1, -1), 10),
        ]))
        story.append(high_table)
        story.append(Spacer(1, 10))

    # Medium vulnerabilities section
    if medium_vulns > 0:
        medium_data = [[
            Paragraph(f'<para><font size="12" color="orange"><b>Medium</b></font> <font size="12" color="orange">Should be addressed soon</font></para>', normal_style),
            Paragraph(f'<para align="right"><font size="18" color="orange"><b>{medium_vulns}</b></font></para>', normal_style)
        ]]
        medium_table = Table(medium_data, colWidths=[420, 80])
        medium_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.Color(1, 0.98, 0.9)),  # Soft yellow 
            ('BOX', (0, 0), (-1, -1), 1, colors.Color(1, 0.75, 0.2)),  # Orange border
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('PADDING', (0, 0), (-1, -1), 10),
        ]))
        story.append(medium_table)
        story.append(Spacer(1, 8))

    # Low vulnerabilities section
    if low_vulns > 0:
        low_data = [[
            Paragraph(f'<para><font size="12" color="green"><b>Low</b></font> <font size="12" color="green">Monitor and plan fixes</font></para>', normal_style),
            Paragraph(f'<para align="right"><font size="18" color="green"><b>{low_vulns}</b></font></para>', normal_style)
        ]]
        low_table = Table(low_data, colWidths=[420, 80])
        low_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.Color(0.95, 1, 0.95)),  # Soft green 
            ('BOX', (0, 0), (-1, -1), 1, colors.Color(0.2, 0.7, 0.3)),  # Green border
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('PADDING', (0, 0), (-1, -1), 12),
        ]))
        story.append(low_table)
        story.append(Spacer(1, 10))

    if critical_vulns == 0 and high_vulns == 0 and medium_vulns == 0 and low_vulns == 0:
        story.append(Paragraph("No vulnerabilities detected", normal_style))

    story.append(Spacer(1, 12))

    # Scanned Ports Section - Table
    story.append(Paragraph("Scanned Ports", heading2_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.black))
    story.append(Spacer(1, 12))

    if ports:
        port_data = [['ID', 'Port', 'Service Name']]
        for idx, port in enumerate(ports, 1):
            port_data.append([
                str(idx),
                str(port.port_number),
                port.service_name or 'Unknown'
            ])
        port_table = Table(port_data, colWidths=[30, 50, 150])
        port_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.gray),  # Gray header
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),  # Alternating white and light gray
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('WORDWRAP', (0, 0), (-1, -1), True),
            ('ALIGN', (0, 0), (0, -1), 'CENTER'),  # Center align ID column
            ('ALIGN', (1, 0), (1, -1), 'CENTER'),  # Center align Port column
            ('ALIGN', (2, 0), (2, -1), 'LEFT'),   # Left align Service Name column
        ]))
        story.append(port_table)
    else:
        story.append(Paragraph("No ports detected", normal_style))
    story.append(Spacer(1, 12))

    # Matched Vulnerabilities Section - Table with bold CVE ID and severity
    story.append(Paragraph("Matched Vulnerabilities", heading2_style))
    story.append(HRFlowable(width="100%", thickness=1, color=colors.black))
    story.append(Spacer(1, 12))
   
    if all_vulnerabilities:
        vuln_data = [['ID', 'CVE ID', 'Severity', 'CVSS', 'Description', 'Remediation']]
        for idx, vuln in enumerate(all_vulnerabilities, 1):
            desc = vuln['description'] or 'N/A'
            if len(desc) > 100:
                desc = desc[:100] + '...'
            rem = vuln['remediation'] or 'N/A'
            if len(rem) > 100:
                rem = rem[:100] + '...'
            severity_color = "black"
            if vuln['severity'] == 'Critical':
                severity_color = "red"
            elif vuln['severity'] == 'High':
                severity_color = "red"
            elif vuln['severity'] == 'Medium':
                severity_color = "orange"
            elif vuln['severity'] == 'Low':
                severity_color = "green"
            vuln_data.append([
                str(idx),
                Paragraph(f'<font size="10"><b>{vuln["cve_id"]}</b> </font>'),
                Paragraph(f'<font color="{severity_color}" size="10">{vuln["severity"]}</font>'),
                str(vuln['cvss_score'] or 'N/A'),
                Paragraph(desc, normal_style),
                Paragraph(rem, normal_style)
                ])
        vuln_table = Table(vuln_data, colWidths=[20, 80, 60, 50, 150, 150])
        vuln_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.gray),  # Gray header
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),  # Alternating white and light gray
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('WORDWRAP', (0, 0), (-1, -1), True),
            ('ALIGN', (0, 0), (0, -1), 'CENTER'),  # Center align ID column
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),   # Left align CVE ID column
            ('ALIGN', (2, 0), (2, -1), 'LEFT'), # Center align Severity column
            ('ALIGN', (3, 0), (3, -1), 'CENTER'), # Left align CVSS Score column
            ('ALIGN', (4, 0), (4, -1), 'LEFT'),   # Left align Description column
            ('ALIGN', (5, 0), (5, -1), 'LEFT'),   # Left align Remediation column
        ]))
        story.append(vuln_table)
    else:
        story.append(Paragraph("No vulnerabilities detected", normal_style))
    story.append(Spacer(1, 12))

    # Footer - Updated styling
    story.append(HRFlowable(width="100%", thickness=1, color=colors.black))
    story.append(Spacer(1, 12))    
    story.append(Paragraph(f"Report generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", footer_style))
    story.append(Paragraph("Network Vulnerability Scanner v1.0", footer_style))

    doc.build(story)
    buffer.seek(0)
    return buffer.getvalue()
