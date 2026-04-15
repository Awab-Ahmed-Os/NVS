import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ResultsPage extends StatefulWidget {
  final int? scanId;
  final String? originalTarget;
  final String? portFrom;
  final String? portTo;

  const ResultsPage({super.key, this.scanId, this.originalTarget, this.portFrom, this.portTo});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<dynamic> _ports = [];
  List<dynamic> _vulnerabilities = [];
  bool _isLoading = true;
  String _targetIp = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _targetIp = widget.originalTarget ?? '';
    if (widget.scanId != null) {
      _fetchResults(widget.scanId!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchResults(int scanId) async {
    try {
      final response = await _apiService.getResults(scanId);
      final vulnerabilities = await _apiService.getVulnerabilities(scanId);
      final allPorts = response['ports'] ?? [];

      // Filter to only open ports
      final ports = allPorts.where((p) => p['state'] == 'open').toList();

      // Sort ports by highest CVSS score of associated vulnerabilities (descending)
      ports.sort((a, b) {
        final portAVulns = vulnerabilities.where((v) => v['port_number'] == a['port_number']).toList();
        final portBVulns = vulnerabilities.where((v) => v['port_number'] == b['port_number']).toList();

        final scoresA = portAVulns.map((v) => (v['cvss_score'] as num?)?.toDouble() ?? 0.0).cast<double>();
        final scoresB = portBVulns.map((v) => (v['cvss_score'] as num?)?.toDouble() ?? 0.0).cast<double>();

        final maxScoreA = scoresA.isNotEmpty ? scoresA.reduce((a, b) => a > b ? a : b) : 0.0;
        final maxScoreB = scoresB.isNotEmpty ? scoresB.reduce((a, b) => a > b ? a : b) : 0.0;

        return maxScoreB.compareTo(maxScoreA); // Descending order
      });

      // Remove duplicate vulnerabilities based on CVE_ID
      final uniqueVulnerabilities = <String, dynamic>{};
      for (var vuln in vulnerabilities) {
        uniqueVulnerabilities[vuln['cve_id']] = vuln;
      }
      final deduplicatedVulnerabilities = uniqueVulnerabilities.values.toList();

      setState(() {
        _ports = ports;
        _vulnerabilities = deduplicatedVulnerabilities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching results: $e')),
        );
      });
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
  int get _criticalVulns => _vulnerabilities.where((v) => v['severity'].toString().toLowerCase() == 'critical').length;
  int get _totalPorts => _ports.length;

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
                    'Scan Results',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Host Info Card
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Host: $_targetIp',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white54, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Scanned on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Open Ports: $_totalPorts',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Vulnerabilities: $_totalVulnerabilities',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Critical Vulnerabilities Warning
              if (_criticalVulns > 0)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1B1B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE53935)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFE53935), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$_criticalVulns critical vulnerabilities found!',
                        style: const TextStyle(color: Color(0xFFE53935), fontSize: 14),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Results List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0B6CF6)))
                    : _ports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No open ports found on $_targetIp',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The scan completed successfully, but no open ports were detected in the specified range.',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _ports.length,
                            itemBuilder: (context, index) {
                              final port = _ports[index];
                              final portVulns = _vulnerabilities.where((v) => v['port_number'] == port['port_number']).toList();

                              return Card(
                                color: const Color(0xFF1E1E1E),
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Port ${port['port_number']}',
                                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                port['service_name'] ?? 'Unknown',
                                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                                              ),
                                              if (port['version'] != null && port['version'].isNotEmpty)
                                                Text(
                                                  'Version: ${port['version']}',
                                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                                ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: port['state'] == 'open' ? (portVulns.isNotEmpty ? const Color(0xFFE53935) : const Color(0xFF00C853)) : Colors.grey,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  port['state'] == 'open' ? 'Open' : 'Closed',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                                ),
                                              ),
                                              if (portVulns.isNotEmpty)
                                                Text(
                                                  '${portVulns.length} vuln${portVulns.length > 1 ? 's' : ''}',
                                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      if (portVulns.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Vulnerabilities:',
                                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        ...portVulns.map((vuln) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      vuln['cve_id'],
                                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: _getSeverityColor(vuln['severity']),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Text(
                                                          vuln['severity'],
                                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF0B6CF6),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Text(
                                                          'CVSS: ${vuln['cvss_score']?.toStringAsFixed(1) ?? 'N/A'}',
                                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                vuln['description'],
                                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/report', arguments: {
                          'scanId': widget.scanId,
                          'targetIp': _targetIp,
                          'portFrom': widget.portFrom,
                          'portTo': widget.portTo,
                        });
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.rotate_left),
                      label: const Text('Rescan'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0B6CF6)),
                        foregroundColor: const Color(0xFF0B6CF6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
