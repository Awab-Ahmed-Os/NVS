import 'package:flutter/material.dart';
import 'screens/main_page.dart';
import 'screens/scan_page.dart';
import 'screens/loading_page.dart';
import 'screens/results_page.dart';
import 'screens/report_page.dart';
import 'screens/settings_page.dart';
import 'screens/other_tools_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Vulnerability Scanner',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/scan':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ScanPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          case '/loading':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                final Map<String, dynamic> args =
                    settings.arguments as Map<String, dynamic>;
                return LoadingPage(
                    ip: args['ip'],
                    scanType: args['scanType'],
                    portFrom: args['portFrom'],
                    portTo: args['portTo']);
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          case '/results':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                final args = settings.arguments as Map<String, dynamic>?;
                return ResultsPage(
                  scanId: args?['scanId'],
                  originalTarget: args?['originalTarget'],
                  portFrom: args?['portFrom'],
                  portTo: args?['portTo'],
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          case '/report':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                final args = settings.arguments as Map<String, dynamic>?;
                return ReportPage(
                  scanId: args?['scanId'] ?? 0,
                  targetIp: args?['targetIp'] ?? '',
                  portFrom: args?['portFrom'],
                  portTo: args?['portTo'],
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          case '/settings':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SettingsPage(onToggleTheme: _toggleTheme),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );

          case '/other_tools':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const OtherToolsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          default:
            return null;
        }
      },
    );
  }
}
