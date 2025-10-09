import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'filter_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _scannedImage;
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_scannedImage != null)
              Image.file(
                _scannedImage!,
                height: 300,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startDocumentScan,
              child: _isScanning
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text('Scan Document'),
            ),
            const SizedBox(height: 20),
            if (_scannedImage != null)
              ElevatedButton(
                onPressed: () => _applyFilters(context),
                child: const Text('Apply Filters'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startDocumentScan() async {
    setState(() {
      _isScanning = true;
    });

    final DocumentScanner documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        mode: ScannerMode.full,
      ),
    );

    try {
      final DocumentScanningResult result = await documentScanner.scanDocument();

      if (result.images.isNotEmpty) {
        setState(() {
          _scannedImage = File(result.images.first);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning document: $e'),
        ),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _applyFilters(BuildContext context) {
    if (_scannedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterScreen(image: _scannedImage!),
        ),
      );
    }
  }
}
