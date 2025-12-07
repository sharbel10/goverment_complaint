import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatelessWidget {
  final File file;
  const PdfViewPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض الملف PDF'),
        backgroundColor: const Color(0xFF003832),
      ),
      body: SfPdfViewer.file(file),
    );
  }
}
