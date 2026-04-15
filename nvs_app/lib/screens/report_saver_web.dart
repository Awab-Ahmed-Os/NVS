import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:typed_data';

Future<void> savePdf(Uint8List pdfBytes, int scanId, BuildContext context) async {
  try {
    // For web, use browser download
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'scan_report_$scanId.pdf';
    anchor.click();
    html.Url.revokeObjectUrl(url);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF download started')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }
}
