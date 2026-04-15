from . import db

# Table 1: Scans
class Scan(db.Model):
    __tablename__ = 'scans'
    scan_id = db.Column(db.Integer, primary_key=True)
    target_ip = db.Column(db.String, nullable=False)
    scan_type = db.Column(db.String, nullable=False)
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime)
    status = db.Column(db.String, default='pending')

    ports = db.relationship('Port', backref='scan', lazy=True)
    scan_vulnerabilities = db.relationship('ScanVulnerability', backref='scan', lazy=True)

# Table 2: Ports
class Port(db.Model):
    __tablename__ = 'ports'
    port_id = db.Column(db.Integer, primary_key=True)
    scan_id = db.Column(db.Integer, db.ForeignKey('scans.scan_id'), nullable=False)
    port_number = db.Column(db.Integer, nullable=False)
    protocol = db.Column(db.String, nullable=False)
    states = db.Column(db.String, nullable=False)
    service_name = db.Column(db.String)

    scan_vulnerabilities = db.relationship('ScanVulnerability', backref='port', lazy=True)

# Table 3: Vulnerabilities
class Vulnerability(db.Model):
    __tablename__ = 'vulnerabilities'
    vuln_id = db.Column(db.Integer, primary_key=True)
    cve_id = db.Column(db.String, unique=True, nullable=False)
    description = db.Column(db.Text, nullable=False)
    cvss_score = db.Column(db.Numeric(3, 1), nullable=True)
    severity = db.Column(db.String, nullable=True)
    published_date = db.Column(db.Date)
    reference_url = db.Column(db.Text)

    remediation = db.relationship('Remediation', backref='vulnerability', lazy=True)
    scan_vulnerabilities = db.relationship('ScanVulnerability', backref='vulnerability', lazy=True)

# Table 4: Remediation
class Remediation(db.Model):
    __tablename__ = 'remediation'
    remediation_id = db.Column(db.Integer, primary_key=True)
    vuln_id = db.Column(db.Integer, db.ForeignKey('vulnerabilities.vuln_id'), nullable=False)
    recommendation = db.Column(db.Text, nullable=False)

# Table 5: ScanVulnerabilities
class ScanVulnerability(db.Model):
    __tablename__ = 'scan_vulnerabilities'
    id = db.Column(db.Integer, primary_key=True)
    scan_id = db.Column(db.Integer, db.ForeignKey('scans.scan_id'), nullable=False)
    port_id = db.Column(db.Integer, db.ForeignKey('ports.port_id'), nullable=False)
    vuln_id = db.Column(db.Integer, db.ForeignKey('vulnerabilities.vuln_id'), nullable=False)
    match_confidence = db.Column(db.String, nullable=False)
