import 'dart:io';
import 'package:collegeapplication/services/firebase_service.dart';
import 'package:collegeapplication/widgets/message_box.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Compress image
    );

    if (pickedFile != null) {
      // Copy the file to a safe directory
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File savedImage = await File(pickedFile.path).copy(newPath);
      return savedImage;
    }
    return null;
  }

  Future<File?> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Copy the file to a safe directory
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final File savedPdf = await File(result.files.single.path!).copy(newPath);
      return savedPdf;
    }
    return null;
  }

  Future<void> _pickAndUploadFile(Future<File?> Function() pickFunction) async {
    if (_isLoading) return;

    await _requestPermissions();

    setState(() => _isLoading = true);

    try {
      final file = await pickFunction();

      if (file != null) {
        _showUploadDialog(file);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showMessageBox(context, 'Error', 'Failed to pick file: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUploadDialog(File file) {
    final TextEditingController nameController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Document Name'),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var categories = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
                  return DropdownButtonFormField<String>(
                    hint: const Text('Select Category'),
                    value: selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Upload'),
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedCategory != null) {
                  Navigator.of(context).pop();
                  _uploadDocument(file, nameController.text, selectedCategory!);
                } else {
                  showMessageBox(context, 'Error', 'Please provide a name and category.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadDocument(File file, String name, String category) async {
    setState(() => _isLoading = true);

    try {
      final fileType = file.path.split('.').last;
      final fileUrl = await _firebaseService.uploadFile(file, name);
      await _firebaseService.saveDocumentMetadata(name, category, fileType, fileUrl);

      if (mounted) {
        showMessageBox(context, 'Success', 'Document uploaded successfully.');
      }
    } catch (e) {
      if (mounted) {
        showMessageBox(context, 'Error', 'Failed to upload document: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, size: 100, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              Text(
                'Upload a Document',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your document will be securely uploaded and sent for verification.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan with Camera'),
                onPressed: _isLoading ? null : () => _pickAndUploadFile(() => _pickImage(ImageSource.camera)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
                onPressed: _isLoading ? null : () => _pickAndUploadFile(() => _pickImage(ImageSource.gallery)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Upload PDF'),
                onPressed: _isLoading ? null : () => _pickAndUploadFile(_pickPdf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400, // Example color
                  foregroundColor: Colors.white, // Example color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
