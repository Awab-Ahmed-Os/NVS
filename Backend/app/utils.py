import re
from .models import Vulnerability, ScanVulnerability, Remediation, db
from .ai_agent import generate_remediation, generate_remediation_fallback

def calculate_match_confidence(service_name, version, description):
    """
    Calculate confidence level for vulnerability matching based on service and version info.
    Returns: 'high', 'medium', 'low'
    """
    service_lower = service_name.lower() if service_name else ""
    version_lower = version.lower() if version else ""
    desc_lower = description.lower()

    # High confidence: exact service name + version match in description
    if service_lower and version_lower:
        if service_lower in desc_lower and version_lower in desc_lower:
            return "high"

    # Medium confidence: service name match (with or without version)
    if service_lower and service_lower in desc_lower:
        return "medium"

    # Low confidence: partial keyword matches
    keywords = service_lower.split()
    if any(keyword in desc_lower for keyword in keywords if len(keyword) > 3):
        return "low"

    return "low"  # Default to low if no matches

def match_vulnerabilities(scan_id, ports):
    for port in ports:
        service = port.service_name.lower() if port.service_name else ""

        # Build search terms
        search_terms = []
        if service:
            search_terms.append(service)

        if not search_terms:
            continue

        # Create regex pattern for more flexible matching
        pattern = r'|'.join(re.escape(term) for term in search_terms)
        matches = Vulnerability.query.filter(Vulnerability.description.op('~')(pattern)).all()

        # Also try partial matches for better coverage
        if not matches:
            for term in search_terms:
                partial_matches = Vulnerability.query.filter(Vulnerability.description.ilike(f"%{term}%")).all()
                matches.extend(partial_matches)

        # Remove duplicates
        seen = set()
        unique_matches = []
        for vuln in matches:
            if vuln.vuln_id not in seen:
                seen.add(vuln.vuln_id)
                unique_matches.append(vuln)

        for vuln in unique_matches:
            confidence = calculate_match_confidence(port.service_name, None, vuln.description)
            match = ScanVulnerability(
                scan_id=scan_id,
                port_id=port.port_id,
                vuln_id=vuln.vuln_id,
                match_confidence=confidence
            )
            db.session.add(match)

            # Generate and insert AI remediation if not exists
            existing_remediation = Remediation.query.filter_by(vuln_id=vuln.vuln_id).first()
            if not existing_remediation:
                try:
                    ai_remediation = generate_remediation(vuln)
                    # Only insert if AI call succeeds (no exception)
                    new_remediation = Remediation(
                        vuln_id=vuln.vuln_id,
                        recommendation=ai_remediation
                    )
                    db.session.add(new_remediation)
                except Exception as e:
                    print(f"Error generating AI remediation for {vuln.cve_id}: {str(e)}")
                    # Do not insert anything if AI fails

    db.session.commit()
