import 'package:flutter/material.dart';

class OtherToolsPage extends StatelessWidget {
  const OtherToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Other Tools',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coming Soon Banner
            Card(
              color: Colors.blue.shade900,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Additional Tools Coming Soon',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "We're developing more security utilities to complement your vulnerability scanning workflow.",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Network Utilities Section
            _buildSection(
              Icons.network_check,
              'Network Utilities',
              [
                _buildToolCard(context, Icons.show_chart, 'Ping Tool', 'Test network connectivity and latency'),
                _buildToolCard(context, Icons.search, 'DNS Lookup', 'Query DNS records and nameservers'),
                _buildToolCard(context, Icons.public, 'WHOIS Lookup', 'Domain registration information'),
                _buildToolCard(context, Icons.timeline, 'Traceroute', 'Trace network path to destination'),
              ],
            ),
            const SizedBox(height: 20),
            // Web & Security Utilities Section
            _buildSection(
              Icons.security,
              'Web & Security Utilities',
              [
                _buildToolCard(context, Icons.verified_user, 'SSL Certificate Checker', 'Analyze SSL certificate details'),
                _buildToolCard(context, Icons.search, 'Subdomain Scanner', 'Discover subdomains'),
                _buildToolCard(context, Icons.settings_input_antenna, 'Port Scanner', 'Quick port availability check', isNavigable: true),
                _buildToolCard(context, Icons.vpn_key, 'Password Generator', 'Generate secure passwords'),
              ],
            ),
            const SizedBox(height: 20),
            // Encoding & Token Tools Section
            _buildSection(
              Icons.code,
              'Encoding & Token Tools',
              [
                _buildToolCard(context, Icons.functions, 'Hash Generator', 'MD5, SHA1, SHA256 hash generation'),
                _buildToolCard(context, Icons.swap_horiz, 'Base64 Encoder/Decoder', 'Encode and decode Base64 strings'),
                _buildToolCard(context, Icons.link, 'URL Encoder/Decoder', 'URL encoding and decoding'),
                _buildToolCard(context, Icons.token, 'JWT Decoder', 'Decode JWT tokens'),
              ],
            ),
            const SizedBox(height: 40),
            // Footer Note
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'These tools will be available in a future update. Stay tuned!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(IconData icon, String title, List<Widget> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF0B6CF6), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(children: tools),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, IconData icon, String name, String description, {bool isNavigable = false}) {
    return Card(
      color: isNavigable ? Colors.blue.shade900 : Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: isNavigable ? () => Navigator.pushNamed(context, '/scan') : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNavigable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
