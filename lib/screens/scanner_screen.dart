import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDocumentScan();
    });
  }

  Future<void> _startDocumentScan() async {
    final DocumentScanner documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        mode: ScannerMode.full,
      ),
    );

    try {
      final DocumentScanningResult result = await documentScanner.scanDocument();

      if (result.images.isNotEmpty) {
        // Save the scanned image to a temporary file immediately.
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final imageBytes = await File(result.images.first).readAsBytes();
        await tempFile.writeAsBytes(imageBytes);

        // Return the path to the saved file.
        if (mounted) {
          Navigator.of(context).pop(tempFile.path);
        }
      } else {
        // User cancelled the scan, pop with null.
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning document: $e'),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
