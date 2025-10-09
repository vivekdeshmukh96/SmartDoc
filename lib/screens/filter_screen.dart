
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FilterScreen extends StatefulWidget {
  final File image;

  const FilterScreen({super.key, required this.image});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late img.Image _image;
  img.Image? _filteredImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _image = img.decodeImage(widget.image.readAsBytesSync())!;
    _filteredImage = _image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : () => _saveAsPdf(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_filteredImage != null)
              Image.memory(
                Uint8List.fromList(img.encodeJpg(_filteredImage!)),
                height: 300,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyBlackAndWhiteFilter,
                  child: const Text('B&W'),
                ),
                ElevatedButton(
                  onPressed: _applyContrastBoost,
                  child: const Text('Contrast'),
                ),
                ElevatedButton(
                  onPressed: _applyBrightnessAdjustment,
                  child: const Text('Brightness'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyBlackAndWhiteFilter() {
    setState(() {
      _filteredImage = img.grayscale(_image);
    });
  }

  void _applyContrastBoost() {
    setState(() {
      _filteredImage = img.contrast(_image, 150);
    });
  }

  void _applyBrightnessAdjustment() {
    setState(() {
      _filteredImage = img.brightness(_image, 50);
    });
  }

  Future<void> _saveAsPdf(BuildContext context) async {
    if (_filteredImage == null) return;

    setState(() {
      _isSaving = true;
    });

    final pw.Document pdf = pw.Document();

    final pdfImage = pw.MemoryImage(
      Uint8List.fromList(img.encodeJpg(_filteredImage!)),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pdfImage),
          );
        },
      ),
    );

    try {
      final Directory outputDir = await getTemporaryDirectory();
      final String outputPath = '${outputDir.path}/scanned_document.pdf';
      final File file = File(outputPath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to: $outputPath'),
        ),
      );

      await _uploadToFirebase(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PDF: $e'),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _uploadToFirebase(File file) async {
    try {
      final String fileName = path.basename(file.path);
      final Reference storageRef = FirebaseStorage.instance.ref().child('scanned_documents/$fileName');
      await storageRef.putFile(file);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded to Firebase Storage'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading to Firebase: $e'),
        ),
      );
    }
  }
}
