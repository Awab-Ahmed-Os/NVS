import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> savePdf(
  Uint8List pdfBytes,
  int scanId,
  BuildContext context,
) async {
  try {
    // For mobile/desktop, use file system
    // Try to use downloads directory, fallback to documents directory
    Directory? directory;
    String directoryName = 'Downloads';
    try {
      directory = await getDownloadsDirectory();
    } catch (e) {
      print('Downloads directory not available, using documents directory: $e');
      directory = await getApplicationDocumentsDirectory();
      directoryName = 'Documents';
    }

    final String? dirPath = directory?.path;
    if (dirPath == null) {
      throw Exception('Directory path is null');
    }

    final filePath = '$dirPath/scan_report_$scanId.pdf';
    print('Saving to: $filePath');

    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    print('File written successfully');

    // Check if file exists
    final exists = await file.exists();
    print('File exists: $exists');

    if (exists) {
      final result = await OpenFile.open(filePath);
      print('OpenFile result: ${result.type}');
      if (result.type == ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PDF saved to $directoryName and opened successfully',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to $directoryName: $filePath')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved but file not found at $filePath')),
        );
      }
    }
  } catch (e) {
    print('Error downloading PDF: $e');
    // Handle specific path_provider errors
    if (e.toString().contains('MissingPluginException') ||
        e.toString().contains('path_provider')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Plugin not initialized. Please restart the app and try again.',
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
      }
    }
  }
}
