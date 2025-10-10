import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilterScreen extends StatefulWidget {
  final String imagePath;
  final Future<void> Function()? onDispose;

  const FilterScreen({
    super.key,
    required this.imagePath,
    this.onDispose,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _isUploading = false;

  Future<void> _uploadToFirebase() async {
    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final file = File(widget.imagePath);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("user_docs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // The 'mounted' check is crucial to prevent crashes.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Uploaded Successfully!\nURL: $downloadUrl")),
        );
        // Only pop the navigator if the widget is still in the tree.
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    } finally {
      // Always delete the temp file, even on failure.
      if (widget.onDispose != null) {
        await widget.onDispose!();
      }
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply Filter & Upload")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use a flexible container to prevent overflow.
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(File(widget.imagePath)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadToFirebase,
            child: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Next → Upload to Firebase"),
          ),
        ],
      ),
    );
  }
}
