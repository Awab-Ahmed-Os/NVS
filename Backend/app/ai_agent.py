import os
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '../.env'))

import google.generativeai as genai

# Configure Gemini with your API key
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-2.0-flash')
else:
    model = None

def generate_remediation(cve):
    """
    Generate short remediation advice for a given CVE using Gemini AI.
    """
    prompt = f"""
    CVE ID: {cve.cve_id}
    Description: {cve.description}
    CVSS Score: {cve.cvss_score}
    Severity: {cve.severity}
    Reference: {cve.reference_url}

    Give only a short remediation suggestion. Do not summarize the vulnerability.
    """

    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return f"Error generating remediation: {str(e)}"

# Fallback function for when API key is not available
def generate_remediation_fallback(cve):
    """
    Generate basic remediation advice when AI is not available.
    """
    return f"Update {cve.cve_id} affected software to the latest version and apply security patches."
