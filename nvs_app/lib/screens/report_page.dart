import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/download_helper.dart';

class ReportPage extends StatefulWidget {
  final int scanId;
  final String targetIp;
  final String? portFrom;
  final String? portTo;

  const ReportPage({
    super.key,
    required this.scanId,
    required this.targetIp,
    this.portFrom,
    this.portTo,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<dynamic> _ports = [];
  List<dynamic> _vulnerabilities = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      final response = await _apiService.getResults(widget.scanId);
      final vulnerabilities = await _apiService.getVulnerabilities(
        widget.scanId,
      );
      final allPorts = response['ports'] ?? [];

      // Filter to only open ports
      final ports = allPorts.where((p) => p['state'] == 'open').toList();

      setState(() {
        _ports = ports;
        _vulnerabilities = vulnerabilities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading report: $e')));
    }
  }

  Future<void> _downloadPdf() async {
    try {
      print('Starting PDF download for scan ${widget.scanId}');
      final pdfBytes = await _apiService.downloadPdfReport(widget.scanId);
      print('Received ${pdfBytes.length} bytes from backend');

      final fileName = 'scan_report_${widget.scanId}.pdf';
      await DownloadHelper.downloadPdf(pdfBytes, fileName, context);

    } catch (e) {
      print('Error downloading PDF: $e');
      // Handle specific path_provider errors
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('path_provider')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Plugin not initialized. Please restart the app and try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
        );
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFE53935);
      case 'high':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFFFAB00);
      case 'low':
        return const Color(0xFF00C853);
      default:
        return Colors.grey;
    }
  }

  int get _totalVulnerabilities => _vulnerabilities.length;
  int get _criticalVulns =>
      _vulnerabilities
          .where((v) => v['severity'].toString().toLowerCase() == 'critical')
          .length;
  int get _highVulns =>
      _vulnerabilities
          .where((v) => v['severity'].toString().toLowerCase() == 'high')
          .length;
  int get _mediumVulns =>
      _vulnerabilities
          .where((v) => v['severity'].toString().toLowerCase() == 'medium')
          .length;
  int get _lowVulns =>
      _vulnerabilities
          .where((v) => v['severity'].toString().toLowerCase() == 'low')
          .length;
  int get _totalPorts => _ports.length;

  List<String> get _recommendations => [
    "Update SSH to the latest version to patch known vulnerabilities",
    "Implement strong authentication mechanisms for database access",
    "Configure firewall rules to restrict unnecessary port access",
    "Enable SSL/TLS encryption for HTTP services",
    "Regularly update system packages and security patches",
    "Monitor network traffic for suspicious activities",
    "Implement intrusion detection systems",
    "Use VPN for remote access to sensitive services",
    "Disable unused services and ports",
    "Regular security audits and penetration testing",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Security Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0B6CF6),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Report Header
                              Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.description,
                                            color: Color(0xFF0B6CF6),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Network Security Assessment',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Generated on ${DateTime.now().toString().split('.')[0]}',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 24,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Target Host',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  widget.targetIp,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Scan Type',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Text(
                                                  'TCP Connect',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Port Range',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${widget.portFrom ?? '1'}-${widget.portTo ?? '1000'}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'CVE Lookup',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Text(
                                                  'Enabled',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Executive Summary
                              Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Executive Summary',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A2A2A),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '$_totalPorts',
                                                    style: const TextStyle(
                                                      color: Color(0xFF0B6CF6),
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Open Ports',
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A2A2A),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '$_totalVulnerabilities',
                                                    style: const TextStyle(
                                                      color: Color(0xFFE53935),
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Vulnerabilities',
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_totalVulnerabilities > 0) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D1B1B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Color(0xFFE53935),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.warning,
                                                color: Color(0xFFE53935),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'This system has $_totalVulnerabilities known vulnerabilities that require immediate attention.',
                                                  style: const TextStyle(
                                                    color: Color(0xFFE53935),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Vulnerability Breakdown
                              Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Vulnerability Breakdown',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (_criticalVulns > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D1B1B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE53935,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Critical',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Immediate action required',
                                                    style: TextStyle(
                                                      color: Color(0xFFE53935),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '$_criticalVulns',
                                                style: const TextStyle(
                                                  color: Color(0xFFE53935),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (_highVulns > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D1B1B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE53935,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'High',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'High priority fixes needed',
                                                    style: TextStyle(
                                                      color: Color(0xFFE53935),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '$_highVulns',
                                                style: const TextStyle(
                                                  color: Color(0xFFE53935),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (_mediumVulns > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2D2A1B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFAB00,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Medium',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Should be addressed soon',
                                                    style: TextStyle(
                                                      color: Color(0xFFFFAB00),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '$_mediumVulns',
                                                style: const TextStyle(
                                                  color: Color(0xFFFFAB00),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (_lowVulns > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1B2D1B),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF00C853,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Low',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Monitor and plan fixes',
                                                    style: TextStyle(
                                                      color: Color(0xFF00C853),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '$_lowVulns',
                                                style: const TextStyle(
                                                  color: Color(0xFF00C853),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Detailed Findings
                              Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detailed Findings',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._ports.map((port) {
                                        final portVulns =
                                            _vulnerabilities
                                                .where(
                                                  (v) =>
                                                      v['port_number'] ==
                                                      port['port_number'],
                                                )
                                                .toList();
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Port ${port['port_number']} (${port['service_name'] ?? 'Unknown'})',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          portVulns.isNotEmpty
                                                              ? Colors.red
                                                              : Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${portVulns.length} issues',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ...portVulns.map(
                                                (vuln) => Container(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                    left: 8,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1E1E1E,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            vuln['cve_id'],
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'monospace',
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: _getSeverityColor(
                                                                vuln['severity'],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              vuln['severity'],
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        vuln['description'],
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Security Recommendations
                              Card(
                                color: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Security Recommendations',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._recommendations.map(
                                        (recommendation) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.shield,
                                                color: Color(0xFF0B6CF6),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  recommendation,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
              ),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _downloadPdf,
                      icon: const Icon(Icons.download),
                      label: const Text('Save PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Report'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0B6CF6)),
                        foregroundColor: const Color(0xFF0B6CF6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
