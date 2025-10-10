import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/message_box.dart';

class FilterScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback? onDispose;
  const FilterScreen({super.key, required this.imageBytes, this.onDispose});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _analyzeDocument();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  Future<void> _analyzeDocument() async {
    if (widget.imageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.getDocumentAnalysis(widget.imageBytes!);
      setState(() {
        _nameController.text = result['name'] ?? '';
        _selectedCategory = result['category'];
      });
    } catch (e) {
      if (mounted) {
        showMessageBox(context, 'Error', 'Failed to analyze document: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<File> _createPdfFromImage(Uint8List imageBytes) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        );
      },
    ));

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${_nameController.text.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  void _uploadDocument() async {
    if (widget.imageBytes == null || _nameController.text.isEmpty || _selectedCategory == null) {
      showMessageBox(context, 'Error', 'Please select an image, name, and category.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // Create a PDF from the image and save it to a file.
      final pdfFile = await _createPdfFromImage(widget.imageBytes);

      // Instead of passing image bytes, we now pass the PDF file to be uploaded.
      // NOTE: The AppState.addDocument method needs to be adapted to handle file uploads to Firebase Storage.
      // Since this is a UI-only example, we'll continue to pass the image bytes for now,
      // but in a real application, you would pass the pdfFile.path and handle the upload there.

      await appState.addDocument(
        _nameController.text,
        _selectedCategory!,
        await pdfFile.readAsBytes(), // In a real app, you'd upload the file and pass a URL.
      );

      if (mounted) {
        showMessageBox(context, 'Success', 'Document uploaded for verification.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showMessageBox(context, 'Error', 'Failed to upload document: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),
            _buildDocumentForm(appState),
            const SizedBox(height: 30),
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Document'),
              onPressed: _uploadDocument,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentForm(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Document Name'),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Category'),
          items: appState.categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }
}
