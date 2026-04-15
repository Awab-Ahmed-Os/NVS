import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SettingsPage({super.key, required this.onToggleTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _defaultScanType = 'TCP';
  String _defaultPortRange = '1-1000';
  double _scanTimeout = 30.0;
  bool _enableCVELookup = true;
  bool _autoSaveResults = true;
  String _reportFormat = 'PDF';
  bool _includeRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultScanType = prefs.getString('defaultScanType') ?? 'TCP';
      _defaultPortRange = prefs.getString('defaultPortRange') ?? '1-1000';
      _scanTimeout = prefs.getDouble('scanTimeout') ?? 30.0;
      _enableCVELookup = prefs.getBool('enableCVELookup') ?? true;
      _autoSaveResults = prefs.getBool('autoSaveResults') ?? true;
      _reportFormat = prefs.getString('reportFormat') ?? 'PDF';
      _includeRecommendations = prefs.getBool('includeRecommendations') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultScanType', _defaultScanType);
    await prefs.setString('defaultPortRange', _defaultPortRange);
    await prefs.setDouble('scanTimeout', _scanTimeout);
    await prefs.setBool('enableCVELookup', _enableCVELookup);
    await prefs.setBool('autoSaveResults', _autoSaveResults);
    await prefs.setString('reportFormat', _reportFormat);
    await prefs.setBool('includeRecommendations', _includeRecommendations);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan Preferences Section
              Row(
                children: [
                  const Icon(
                    Icons.network_check,
                    color: Color(0xFF0B6CF6),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Default Scan Type
                      Row(
                        children: [
                          const Icon(
                            Icons.shield,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Default Scan Type',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _defaultScanType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _defaultScanType = newValue!;
                          });
                        },
                        items: <String>['TCP', 'SYN', 'UDP']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'TCP'
                                  ? 'TCP Connect'
                                  : value == 'SYN'
                                      ? 'SYN Stealth'
                                      : 'UDP Scan',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Colors.grey[800],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      // Default Port Range
                      const Text(
                        'Default Port Range',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller:
                            TextEditingController(text: _defaultPortRange),
                        onChanged: (value) {
                          _defaultPortRange = value;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'e.g., 1-1000, 80,443,22',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      // Scan Timeout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Scan Timeout (seconds)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            '${_scanTimeout.toInt()}s',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Slider(
                        value: _scanTimeout,
                        min: 5,
                        max: 120,
                        divisions: 23,
                        onChanged: (double value) {
                          setState(() {
                            _scanTimeout = value;
                          });
                        },
                        activeColor: const Color(0xFF0B6CF6),
                      ),
                      const Divider(color: Colors.grey),
                      // Toggle Settings
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Enable CVE Lookup',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Automatically check for known vulnerabilities',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _enableCVELookup,
                        onChanged: (bool value) {
                          setState(() {
                            _enableCVELookup = value;
                          });
                          // Save immediately when toggled
                          _saveSettings();
                        },
                        secondary: const SizedBox.shrink(),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Auto-save Results',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Automatically save scan results',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _autoSaveResults,
                        onChanged: (bool value) {
                          setState(() {
                            _autoSaveResults = value;
                          });
                        },
                        secondary: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Report Settings Section
              Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Color(0xFF0B6CF6),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Report Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Report Format
                      const Text(
                        'Default Report Format',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _reportFormat,
                        onChanged: (String? newValue) {
                          setState(() {
                            _reportFormat = newValue!;
                          });
                        },
                        items: <String>['PDF', 'HTML', 'JSON', 'CSV']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'PDF'
                                  ? 'PDF Document'
                                  : value == 'HTML'
                                      ? 'HTML Report'
                                      : value == 'JSON'
                                          ? 'JSON Data'
                                          : 'CSV Export',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Colors.grey[800],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      // Include Recommendations
                      SwitchListTile(
                        title: const Text(
                          'Include Recommendations',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Add security recommendations to reports',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _includeRecommendations,
                        onChanged: (bool value) {
                          setState(() {
                            _includeRecommendations = value;
                          });
                        },
                        secondary: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Application Info Section
              Row(
                children: [
                  const Icon(
                    Icons.shield,
                    color: Color(0xFF0B6CF6),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Application Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.grey[900],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Version',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '1.0.0',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Updated',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Nov 2025',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Database Version',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'CVE-2025.10',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Help & Support Section

              const SizedBox(height: 30),
              // Save Button
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6CF6),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
