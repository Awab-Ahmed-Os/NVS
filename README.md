# Network Vulnerability Scanner (NVS)

A full-stack network security tool that automates open port detection, looks up known vulnerabilities (CVEs) in real time, scores their risk with CVSS, and gives network administrators AI-powered remediation guidance, all from an Android app.

> Graduation project, BSc (Hons) Information Technology, The Future University, Sudan (2025).

![Python](https://img.shields.io/badge/Python-3.x-blue)
![Flask](https://img.shields.io/badge/Flask-API-black)
![Flutter](https://img.shields.io/badge/Flutter-Android-02569B)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-336791)

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [How Risk Scoring Works](#how-risk-scoring-works)
- [Project Structure](#project-structure)
- [Legal and Ethical Use](#legal-and-ethical-use)
- [Limitations and Future Work](#limitations-and-future-work)
- [Author](#author)

---

## Overview

Checking a network for vulnerabilities by hand means running a scanner, searching each service version for CVEs, working out which ones matter most, and then researching fixes. NVS automates that whole workflow:

1. The administrator starts a scan from the mobile app.
2. The Flask backend scans the target with Nmap to find open ports and running services.
3. Detected services are matched against known CVEs.
4. Each finding gets a CVSS-based severity score so the most dangerous issues are handled first.
5. The app shows the results with AI-generated remediation advice.

## Features

- **Open port and service detection** using `python-nmap`
- **Real-time CVE lookup** for detected services and versions
- **CVSS-based risk scoring** to rank findings by severity
- **AI-powered remediation guidance** with clear steps for each finding
- **Android app** built with Flutter for starting scans and viewing results
- **Persistent scan history** stored in PostgreSQL through SQLAlchemy
- **REST API** built with Flask, connecting the app, scanner and database

## Architecture

```
+----------------+      HTTP/JSON      +-------------------+
|  Flutter app   | <-----------------> |    Flask API      |
|  (Android)     |                     |                   |
+----------------+                     |  - Scan manager   |
                                       |  - CVE lookup     |
                                       |  - CVSS scoring   |
                                       |  - AI remediation |
                                       +---------+---------+
                                                 |
                          +----------------------+----------------------+
                          |                      |                      |
                    +-----v-----+        +-------v-------+      +-------v-------+
                    |   Nmap    |        |  CVE data     |      |  PostgreSQL   |
                    | (scanner) |        |  source/API   |      | (SQLAlchemy)  |
                    +-----------+        +---------------+      +---------------+
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile app | Flutter (Dart), Android |
| Backend | Python, Flask |
| Scanning | Nmap, `python-nmap` |
| Risk scoring | CVSSLib (CVSS) |
| Database | PostgreSQL, SQLAlchemy |
| CVE data | [NVD / other source - fill in] |
| AI guidance | [AI model or API used - fill in] |

## Getting Started

> Adjust the commands below to match your repository.

### Prerequisites

- Python 3.9 or later
- [Nmap](https://nmap.org/download.html) installed and available on your PATH
- PostgreSQL 13 or later
- Flutter SDK and Android Studio (or a physical Android device)

### 1. Clone the repository

```bash
git clone https://github.com/AwabAhmed-Os/[repository-name].git
cd [repository-name]
```

### 2. Set up the backend

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Configure environment variables

Create a `.env` file in the backend folder:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/nvs_db
SECRET_KEY=your_secret_key
AI_API_KEY=your_ai_api_key
```

Never commit your `.env` file. Make sure it is listed in `.gitignore`.

### 4. Create the database

```bash
createdb nvs_db
flask db upgrade     # or the command your project uses to create tables
```

### 5. Run the API

```bash
flask run --host=0.0.0.0 --port=5000
```

### 6. Run the mobile app

```bash
cd mobile
flutter pub get
flutter run
```

Set the API base URL in the app's configuration to the IP address of the machine running the backend, for example `http://192.168.1.10:5000`.

## Usage

1. Open the app and enter the target IP address or range.
2. Start the scan and wait for the results.
3. Review the findings, sorted from highest to lowest risk.
4. Open any finding to see its CVE details, CVSS score and recommended fix.
5. Check the history screen to compare past scans.

## How Risk Scoring Works

Each CVE found is scored with the Common Vulnerability Scoring System (CVSS) and grouped by severity:

| CVSS score | Severity |
|------------|----------|
| 0.0 | None |
| 0.1 - 3.9 | Low |
| 4.0 - 6.9 | Medium |
| 7.0 - 8.9 | High |
| 9.0 - 10.0 | Critical |

Results are sorted so administrators can fix critical and high-severity issues first.

## Project Structure

```
[repository-name]/
|-- backend/
|   |-- app/
|   |   |-- routes/          # API endpoints
|   |   |-- models/          # SQLAlchemy models
|   |   |-- services/        # Scanning, CVE lookup, scoring, AI guidance
|   |-- requirements.txt
|   |-- .env.example
|-- mobile/                  # Flutter Android app
|-- docs/
|   |-- screenshots/
|-- README.md
```

## Legal and Ethical Use

Only scan networks and devices that you own or have written permission to test. Scanning systems without authorization may be illegal. This project is built for educational use and for authorized security assessments. The author accepts no responsibility for misuse.

## Limitations and Future Work

- CVE matching depends on accurate service and version detection, so results can include false positives or miss issues.
- AI-generated remediation advice should be reviewed by a qualified person before it is applied.
- Planned improvements:
  - [ ] Exportable PDF scan reports
  - [ ] Scheduled and recurring scans
  - [ ] User accounts and role-based access
  - [ ] iOS support
  - [ ] Dashboard with risk trends over time

## Author

**Awab Ahmed Osman Mohamed**
- LinkedIn: https://www.linkedin.com/in/awab-ahmed-720b743a7/
- GitHub: https://github.com/AwabAhmed-Os
- Portfolio: https://awab-ahmed-os.github.io/Portfolio/
- Email: awabahmed987@gmail.com
