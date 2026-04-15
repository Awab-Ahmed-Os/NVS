import 'dart:html' as html;
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<void> downloadPdf(List<int> pdfBytes, String fileName, BuildContext context) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF is being downloaded...')),
    );
  }
}
