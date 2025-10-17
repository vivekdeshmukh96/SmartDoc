import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id;
  final String fullName;
  final String email;
  String profileImageUrl;

  Faculty({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl = '',
  });

  factory Faculty.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Faculty(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}
