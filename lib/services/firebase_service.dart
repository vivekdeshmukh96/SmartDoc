
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/document.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadFile(File file, String documentName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final fileName =
          '${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$documentName';
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> saveDocumentMetadata(
      String documentName, String category, String fileType, String fileUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final document = Document(
        id: '', // Firestore will generate this
        name: documentName,
        category: category,
        fileType: fileType,
        url: fileUrl,
        uploadedAt: DateTime.now(),
        status: DocumentStatus.pending,
        uploadedByUserId: user.uid,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('documents')
          .add(document.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving document metadata: $e');
      }
      rethrow;
    }
  }
}
