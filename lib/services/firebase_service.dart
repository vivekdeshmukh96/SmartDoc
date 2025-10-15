
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

  Future<void> registerFaculty({
    required String email,
    required String password,
    required String name,
    required String department,
    String? contactNumber,
  }) async {
    try {
      // Create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add custom claims to the user
      await userCredential.user!.updateDisplayName(name);

      // Store faculty details in Firestore
      await _firestore.collection('faculty').doc(userCredential.user!.uid).set({
        'fullName': name,
        'email': email,
        'department': department,
        'contactNumber': contactNumber,
        'status': 'pending',
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('An error occurred while registering the faculty.');
    }
  }
}
