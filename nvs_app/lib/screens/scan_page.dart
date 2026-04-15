import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portFromController = TextEditingController(text: '1');
  final TextEditingController _portToController = TextEditingController(text: '1000');
  String _scanType = 'TCP';
  bool _cveLookup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scanType = prefs.getString('defaultScanType') ?? 'TCP';
      String portRange = prefs.getString('defaultPortRange') ?? '1-10';
      List<String> ports = portRange.split('-');
      if (ports.length == 2) {
        _portFromController.text = ports[0];
        _portToController.text = ports[1];
      }
    });
  }

  Future<bool> _isValidIpOrHostname(String input) async {
    // Check if it's a valid IP address (IPv4)
    final ipRegex = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');
    if (ipRegex.hasMatch(input)) {
      return true;
    }

    // Check if it's a valid hostname (relaxed validation)
    final hostnameRegex = RegExp(r'^[a-zA-Z0-9_]([a-zA-Z0-9_.-]*[a-zA-Z0-9_])?$');
    if (hostnameRegex.hasMatch(input)) {
      // For hostname, try to resolve it, but don't fail if lookup fails (network issues)
      try {
        final result = await InternetAddress.lookup(input);
        return result.isNotEmpty;
      } catch (e) {
        // Allow hostname even if lookup fails (might be due to network/firewall)
        return true;
      }
    }

    return false;
  }

  void _startScan() async {
    String input = _ipController.text.trim();
    if (input.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a target IP address or hostname')),
        );
      });
      return;
    }

    bool isValid = await _isValidIpOrHostname(input);
    if (!isValid) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid IP address or hostname')),
        );
      });
      return;
    }

    Navigator.pushNamed(context, '/loading', arguments: {
      'ip': input,
      'scanType': _scanType,
      'portFrom': _portFromController.text,
      'portTo': _portToController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Configuration',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Target IP
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target IP Address & Hostname',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ipController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'e.g., 192.168.1.1 or example.com',
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Port Range
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Port Range',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'From',
                                      style: TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    TextFormField(
                                      controller: _portFromController,
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white70),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'To',
                                      style: TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                    TextFormField(
                                      controller: _portToController,
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white70),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
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
                  // Scan Type
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan Type',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _scanType,
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: Colors.grey[900],
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _scanType = newValue!;
                              });
                            },
                            items: <String>['TCP', 'SYN', 'UDP']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CVE Lookup
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVE Lookup',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const Text(
                                'Check for known vulnerabilities',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          Switch(
                            value: _cveLookup,
                            onChanged: (value) {
                              setState(() {
                                _cveLookup = value;
                              });
                            },
                            activeThumbColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hint
                  Card(
                    color: Colors.blue[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Recommended: run scans during low-traffic hours',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
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
          // Start Scan Button
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6CF6),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
