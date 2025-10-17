import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final String department;
  String photoURL;

  Faculty({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.department,
    this.photoURL = '',
  });

  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      department: data['department'] ?? '',
      photoURL: data['photoURL'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'contactNumber': contactNumber,
      'department': department,
      'photoURL': photoURL,
    };
  }
}
