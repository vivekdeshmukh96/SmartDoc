import 'dart:io';
import 'dart:typed_data';

import 'package:collegeapplication/screens/filter_screen.dart';
import 'package:collegeapplication/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  static const _tempImagePathKey = 'temp_image_path';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverAndNavigate();
    });
  }

  Future<void> _recoverAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_tempImagePathKey);

    if (imagePath != null) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        // The file exists, read it into bytes and navigate to the FilterScreen.
        final imageBytes = await imageFile.readAsBytes();
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilterScreen(
                imageBytes: imageBytes,
                onDispose: () async {
                  // This callback runs when FilterScreen is disposed.
                  await prefs.remove(_tempImagePathKey);
                  await imageFile.delete();
                },
              ),
            ),
          );
        }
      } else {
        // The file path was saved, but the file no longer exists. Clean up.
        await prefs.remove(_tempImagePathKey);
      }
    }
  }

  Future<void> _processImageAndNavigate(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final imageFile = File(imagePath);

    if (await imageFile.exists()) {
      // Persist the image path in case the app is killed.
      await prefs.setString(_tempImagePathKey, imageFile.path);

      final imageBytes = await imageFile.readAsBytes();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(
              imageBytes: imageBytes,
              onDispose: () async {
                // This callback runs when FilterScreen is disposed.
                await prefs.remove(_tempImagePathKey);
                await imageFile.delete();
              },
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Image file not found.')),
        );
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    String? imagePath;

    if (source == ImageSource.camera) {
      // ScannerScreen now returns a file path.
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()),
      );
      if (result is String) {
        imagePath = result;
      }
    } else {
      // ImagePicker returns a file path.
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        imagePath = pickedFile.path;
      }
    }

    if (imagePath != null) {
      await _processImageAndNavigate(imagePath);
    } else {
      // User cancelled the operation.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected or scan cancelled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePicker(),
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
          child: const Center(
            child: Text('Select an image to start', style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Document'),
                onPressed: () => _getImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload from Gallery'),
                onPressed: () => _getImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
