import 'dart:io';
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

    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilterScreen(
                imagePath: imagePath,
                onDispose: () async {
                  await prefs.remove(_tempImagePathKey);
                  await imageFile.delete();
                },
              ),
            ),
          );
        }
      } else {
        await prefs.remove(_tempImagePathKey);
      }
    }
  }

  Future<void> _processImageAndNavigate(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final imageFile = File(imagePath);

    if (await imageFile.exists()) {
      await prefs.setString(_tempImagePathKey, imageFile.path);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(
              imagePath: imagePath,
              onDispose: () async {
                await prefs.remove(_tempImagePathKey);
                try {
                  if (await imageFile.exists()) {
                    await imageFile.delete();
                  }
                } catch (e) {
                  print('Error deleting temp file: $e');
                }
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
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()),
      );
      if (result != null && result.isNotEmpty) {
        imagePath = result;
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        // To ensure consistency, we copy the gallery image to our temp directory
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(await pickedFile.readAsBytes());
        imagePath = tempFile.path;
      }
    }

    if (imagePath != null) {
      await _processImageAndNavigate(imagePath);
    } else {
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
