import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // Color constants
  static const Color bgGradientStart = Color(0xFF0F172A); // slate-900 darker
  static const Color bgGradientEnd = Color(0xFF020617); // very dark
  static const Color cardBg = Color(0xFF1E293B); // card background
  static const Color textPrimary = Color(0xFFE2E8F0); // foreground
  static const Color textSecondary = Color(0xFF94A3B8); // muted-foreground
  static const Color primary = Color(0xFF0B6CF6); // #0B6CF6
  static const Color success = Color(0xFF10B981); // green-500
  static const Color helpCardBgDark = Color(0xFF1E3A8A); // blue-950/30

  // Typography styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.1,
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );
  static const TextStyle buttonStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield, size: 48, color: primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Network Vulnerability Scanner',
                                  style: headingStyle,
                                ),
                                Text(
                                  'Secure your network infrastructure',
                                  style: subtitleStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Action Buttons
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMainButton(
                            context,
                            'Start New Scan',
                            Icons.network_check,
                            primary,
                            () => Navigator.pushNamed(context, '/scan'),
                          ),
                          const SizedBox(height: 12),
                          _buildSecondaryButton(
                            context,
                            'Other Tools',
                            Icons.build,
                            () => Navigator.pushNamed(context, '/other_tools'),
                          ),
                          const SizedBox(height: 12),
                          _buildSecondaryButton(
                            context,
                            'Settings',
                            Icons.settings,
                            () => Navigator.pushNamed(context, '/settings'),
                          ),
                          const SizedBox(height: 12),
                          _buildHelpCard(context),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Future University — NVS v1.0',
                      style: captionStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return Card(
      color: cardBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: primary),
              const SizedBox(width: 12),
              Text(label, style: buttonStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label,
      IconData icon, VoidCallback onPressed) {
    return Card(
      color: cardBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: primary),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [const Color.fromARGB(255, 0, 0, 0), helpCardBgDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showHelpDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.help, size: 24, color: primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Help & Support',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromARGB(255, 255, 255, 255))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('New User?',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Get started with guides, tips, and support',
                          style: TextStyle(fontSize: 14, color: textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBg,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.help, size: 20, color: primary),
              ),
              const SizedBox(width: 12),
              Text('Help & Support Center',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 0, 0, 0))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Complete guide to using the Network Vulnerability Scanner and getting support when needed.',
                    style: TextStyle(color: textSecondary)),
                const SizedBox(height: 24),
                _buildHelpSection('Getting Started', [
                  'Step 1: Click "Start New Scan" to begin vulnerability assessment',
                  'Step 2: Enter target IP address or hostname',
                  'Step 3: Configure port range and scan options',
                  'Step 4: Review results and generate reports',
                ]),
                const SizedBox(height: 16),
                Text('Quick Tips',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 8),
                _buildTipCard(
                    'TCP Connect: Standard reliable scan (recommended for beginners)',
                    Colors.blue),
                _buildTipCard(
                    'SYN Stealth: Faster scanning with less visibility (requires root/admin privileges)',
                    Colors.purple),
                _buildTipCard(
                    'UDP Scan: Detects UDP services (slower but comprehensive for UDP ports)',
                    Colors.teal),
                _buildTipCard(
                    'CVE Lookup: Enable for comprehensive vulnerability detection',
                    Colors.green),
                _buildTipCard(
                    'Security: Only scan networks you own or have permission to test',
                    Colors.orange),
                const SizedBox(height: 16),
                Divider(color: textSecondary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.mail, size: 20, color: primary),
                    const SizedBox(width: 8),
                    Text('Need More Help?',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [const Color.fromARGB(255, 0, 0, 0), helpCardBgDark],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Contact our support team for technical assistance and advanced guidance.',
                          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.mail, size: 16, color: primary),
                          const SizedBox(width: 8),
                          Text('networkvscanner@gmail.com',
                              style: TextStyle(
                                  color: primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Response time: 24-48 hours',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpSection(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, size: 20, color: primary),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        step,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 14,
        ),
      ),
    );
  }
}
