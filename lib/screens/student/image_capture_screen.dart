import 'dart:io';
import 'package:collegeapplication/screens/filter_screen.dart';
import 'package:collegeapplication/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageCaptureScreen extends StatefulWidget {
  final ImageSource source;
  const ImageCaptureScreen({super.key, required this.source});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImage();
    });
  }

  Future<void> _getImage() async {
    if (widget.source == ImageSource.camera) {
      final scannedImageBytes = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()),
      );
      if (scannedImageBytes != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(imageBytes: scannedImageBytes),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: widget.source);
      if (pickedFile != null && mounted) {
        final bytes = await pickedFile.readAsBytes();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FilterScreen(imageBytes: bytes),
          ),
        );
      } else {
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
