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
  bool _isLoading = false;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recovered an unfinished scan.')),
          );
          await _navigateToFilterScreen(imagePath);
        }
      } else {
        await prefs.remove(_tempImagePathKey);
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    String? imagePath;
    try {
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
          final tempDir = await getTemporaryDirectory();
          final tempPath = path.join(tempDir.path, '${const Uuid().v4()}.jpg');
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(await pickedFile.readAsBytes());
          imagePath = tempFile.path;
        }
      }

      if (imagePath != null) {
        await _navigateToFilterScreen(imagePath);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected or scan cancelled.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToFilterScreen(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final imageFile = File(imagePath);

    if (!await imageFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Image file not found.')),
        );
      }
      return;
    }

    await prefs.setString(_tempImagePathKey, imagePath);

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterScreen(imagePath: imagePath),
        ),
      );
    }
    // Cleanup is handled in FilterScreen after permanent save
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
                'Scan or Upload a Document',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your document will be processed and saved securely.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Scan with Camera'),
                onPressed: _isLoading ? null : () => _getImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
                onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
