import os
import nmap

def run_nmap_scan(target_ip, scan_type='TCP', port_from=None, port_to=None):
    # Add nmap to PATH
    nmap_dir = r"C:\Program Files (x86)\Nmap"
    if nmap_dir not in os.environ['PATH']:
        os.environ['PATH'] += ";" + nmap_dir

    scanner = nmap.PortScanner()

    # Define scan arguments based on scan_type
    if scan_type == 'TCP':
        arguments = '-sT -sV -T4'  # TCP connect scan with version detection
    elif scan_type == 'SYN':
        arguments = '-sS -sV -T4'  # SYN scan (half-open) with version detection
    elif scan_type == 'UDP':
        arguments = '-sU -sV -T4'  # UDP scan with version detection
    else:
        arguments = '-sT -sV -T4'  # Default to TCP with version detection

    # Add port range if specified
    if port_from and port_to:
        arguments += f' -p{port_from}-{port_to}'
    else:
        arguments += ' -p1-10'  # Default port range if none specified



    scanner.scan(hosts=target_ip, arguments=arguments)

    results = []
    for host in scanner.all_hosts():
        for proto in scanner[host].all_protocols():
            ports = scanner[host][proto].keys()
            for port in ports:
                version_info = scanner[host][proto][port].get('version', '')
                product = scanner[host][proto][port].get('product', '')
                if product and version_info:
                    full_version = f"{product} {version_info}"
                elif product:
                    full_version = product
                else:
                    full_version = version_info

                results.append({
                    "port_number": port,
                    "protocol": proto,
                    "state": scanner[host][proto][port]['state'],
                    "service_name": scanner[host][proto][port].get('name', ''),
                    "version": full_version
                })
    return results
