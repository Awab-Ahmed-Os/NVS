import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../services/api_service.dart';

class LoadingPage extends StatefulWidget {
  final String ip;
  final String scanType;
  final String portFrom;
  final String portTo;

  const LoadingPage(
      {super.key,
      required this.ip,
      required this.scanType,
      required this.portFrom,
      required this.portTo});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  double _progress = 0.0;
  late AnimationController _pulseController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _startScan(widget.ip, widget.scanType);
    _startProgressSimulation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startScan(String ip, String scanType) async {
    try {
      final response = await _apiService.startScan(ip, scanType,
          portFrom: widget.portFrom, portTo: widget.portTo);
      int scanId = response['scan_id'];
      // Poll for scan completion
      await _pollScanCompletion(scanId);
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pollScanCompletion(int scanId) async {
    const pollInterval = Duration(seconds: 2);
    const maxPolls = 60; // Max 2 minutes
    int pollCount = 0;

    while (pollCount < maxPolls) {
      try {
        final result = await _apiService.getResults(scanId);
        String status = result['status'];
        if (status == 'success') {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/results', arguments: {
              'scanId': scanId,
              'originalTarget': widget.ip,
              'portFrom': widget.portFrom,
              'portTo': widget.portTo
            });
          }
          return;
        } else if (status == 'error') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scan failed')),
            );
            Navigator.of(context).pop();
          }
          return;
        }
        // Still running, continue polling
        await Future.delayed(pollInterval);
        pollCount++;
      } catch (e) {
        // Handle polling error, perhaps retry or show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Polling error: $e')),
          );
          Navigator.of(context).pop();
        }
        return;
      }
    }
    // Timeout
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan timed out')),
      );
      Navigator.of(context).pop();
    }
  }

  void _startProgressSimulation() {
    const totalSteps = 100;
    const duration = Duration(seconds: 120); // Match max poll time
    const stepDuration =
        Duration(milliseconds: 1200); // 120 seconds / 100 steps

    _timer = Timer.periodic(stepDuration, (timer) {
      setState(() {
        _progress += 1.0 / totalSteps;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Scanning...',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.5 + 0.5 * _pulseController.value,
                          child: Icon(
                            Icons.shield,
                            size: 80,
                            color: const Color(0xFF0B6CF6),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0B6CF6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Scanning ${widget.ip} (${(_progress * 100).toInt()}%)',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
