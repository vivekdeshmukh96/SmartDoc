import 'dart:typed_data';
import 'package:collegeapplication/screens/filter_screen.dart';
import 'package:collegeapplication/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../widgets/message_box.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  Uint8List? _imageBytes;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  bool _isProcessing = false;

  Future<void> _getImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final scannedImage = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()),
      );
      if (scannedImage != null) {
        final filteredImage = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(imageBytes: scannedImage),
          ),
        );
        if (filteredImage != null) {
          setState(() {
            _imageBytes = filteredImage;
          });
          _analyzeDocument();
        }
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        _analyzeDocument();
      }
    }
  }

  Future<void> _analyzeDocument() async {
    if (_imageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.getDocumentAnalysis(_imageBytes!);
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

  void _uploadDocument() async {
    if (_imageBytes == null || _nameController.text.isEmpty || _selectedCategory == null) {
      showMessageBox(context, 'Error', 'Please select an image, name, and category.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.addDocument(
        _nameController.text,
        _selectedCategory!,
        _imageBytes!,
      );
      if (mounted) {
        showMessageBox(context, 'Success', 'Document uploaded for verification.');
        setState(() {
          _imageBytes = null;
          _nameController.clear();
          _selectedCategory = null;
        });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePicker(),
          const SizedBox(height: 30),
          if (_imageBytes != null) ...[
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
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: _imageBytes != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
          )
              : const Center(
            child: Text('Select an image to start', style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Document'),
              onPressed: () => _getImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload from Gallery'),
              onPressed: () => _getImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ],
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
