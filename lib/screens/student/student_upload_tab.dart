import 'package:collegeapplication/screens/student/image_capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  Future<void> _getImage(ImageSource source) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCaptureScreen(source: source),
      ),
    );
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
