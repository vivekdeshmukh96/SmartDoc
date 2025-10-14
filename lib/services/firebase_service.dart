
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/document.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        downloadUrl: fileUrl, // This is the Supabase URL
        uploadedDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        status: DocumentStatus.pending,
        uploadedByUserId: user.uid,
      );

      await _firestore
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
