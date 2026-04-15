import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000'; // For web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000'; // For Android emulator
    } else {
      return 'http://127.0.0.1:5000'; // For desktop
    }
  }

  Future<Map<String, dynamic>> startScan(String targetIp, String scanType, {String? portFrom, String? portTo}) async {
    final body = {
      'target_ip': targetIp,
      'scan_type': scanType,
      if (portFrom != null) 'port_from': portFrom,
      if (portTo != null) 'port_to': portTo,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start scan');
    }
  }

  Future<Map<String, dynamic>> getResults(int scanId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Load from cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('results_$scanId');
      if (cached != null) {
        return jsonDecode(cached) as Map<String, dynamic>;
      } else {
        throw Exception('No internet connection and no cached data');
      }
    } else {
      final response = await http.get(Uri.parse('$baseUrl/scan/$scanId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache the data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('results_$scanId', jsonEncode(data));
        return data;
      } else {
        throw Exception('Failed to get results');
      }
    }
  }

  Future<List<dynamic>> getVulnerabilities(int scanId) async {
    final response = await http.get(Uri.parse('$baseUrl/scan/$scanId/vulnerabilities'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to get vulnerabilities');
    }
  }

  Future<List<dynamic>> getHistory() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Load from cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('history');
      if (cached != null) {
        return jsonDecode(cached) as List<dynamic>;
      } else {
        throw Exception('No internet connection and no cached data');
      }
    } else {
      final response = await http.get(Uri.parse('$baseUrl/history'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        // Cache the data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('history', jsonEncode(data));
        return data;
      } else {
        throw Exception('Failed to get history');
      }
    }
  }

  Future<Map<String, dynamic>> getReport(int scanId) async {
    final response = await http.get(Uri.parse('$baseUrl/scan/$scanId/report'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get report');
    }
  }

  Future<Uint8List> downloadPdfReport(int scanId) async {
    final response = await http.get(Uri.parse('$baseUrl/scan/$scanId/report'));
    if (response.statusCode == 200) {
      return response.bodyBytes; // Return bytes for PDF
    } else {
      // Try to parse error message from response
      String errorMessage = 'Failed to download PDF report';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
      } catch (e) {
        // If parsing fails, use default message
      }
      throw Exception(errorMessage);
    }
  }
}
