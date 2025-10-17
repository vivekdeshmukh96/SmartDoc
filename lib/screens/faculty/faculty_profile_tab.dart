import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_doc/models/faculty.dart';

class FacultyProfileTab extends StatefulWidget {
  const FacultyProfileTab({super.key});

  @override
  State<FacultyProfileTab> createState() => _FacultyProfileTabState();
}

class _FacultyProfileTabState extends State<FacultyProfileTab> {
  Faculty? _faculty;
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchFacultyData();
  }

  Future<void> _fetchFacultyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('faculty').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _faculty = Faculty.fromFirestore(doc);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final file = File(imageFile.path);
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '$_faculty!.id/$fileName';

    try {
      await _supabase.storage.from('profile_photos').upload(filePath, file);
      final imageUrl = _supabase.storage.from('profile_photos').getPublicUrl(filePath);

      await FirebaseFirestore.instance.collection('faculty').doc(_faculty!.id).update({
        'photoURL': imageUrl,
      });

      setState(() {
        _faculty!.photoURL = imageUrl;
      });
    } on StorageException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_faculty == null) {
      return const Center(child: Text('No profile data found.'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _faculty!.photoURL.isNotEmpty
                      ? NetworkImage(_faculty!.photoURL)
                      : null,
                  child: _faculty!.photoURL.isEmpty
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 30),
                    onPressed: _uploadProfilePicture,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blueAccent),
                title: const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_faculty!.fullName, style: const TextStyle(fontSize: 16)),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blueAccent),
                title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_faculty!.email, style: const TextStyle(fontSize: 16)),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.phone_outlined, color: Colors.blueAccent),
                title: const Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_faculty!.contactNumber, style: const TextStyle(fontSize: 16)),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.business_outlined, color: Colors.blueAccent),
                title: const Text('Department', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_faculty!.department, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
