import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<void> downloadPdf(List<int> pdfBytes, String fileName, BuildContext context) async {
    Directory? directory;
    String directoryName = 'Downloads';
    try {
      directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads directory not available');
      }
    } catch (e) {
      print(
          'Downloads directory not available, using documents directory: $e');
      directory = await getApplicationDocumentsDirectory();
      directoryName = 'Documents';
    }

    final filePath = '${directory.path}/$fileName';
    print('Saving to: $filePath');

    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    print('File written successfully');

    final exists = await file.exists();
    print('File exists: $exists');

    if (exists) {
      final result = await OpenFile.open(filePath);
      print('OpenFile result: ${result.type}');
      if (result.type == ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'PDF saved to $directoryName and opened successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to $directoryName: $filePath')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('PDF saved but file not found at $filePath')),
      );
    }
  }
}
