import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/role.dart';

class User {
  final String id;
  final String? name;
  final String email;
  final Role role;
  final String? rollNumber;
  final String? className;
  final String? photoURL;
  final String? year;
  final String? section;
  final String? department;
  final String? studentId;
  final String? dob;
  final String? contactNo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.rollNumber,
    this.className,
    this.photoURL,
    this.year,
    this.section,
    this.department,
    this.studentId,
    this.dob,
    this.contactNo,
  });

  factory User.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      id: snap.id,
      name: snapshot['name'],
      email: snapshot['email'],
      role: Role.values.firstWhere((e) => e.name == snapshot['role']),
      rollNumber: snapshot['rollNumber'],
      className: snapshot['className'],
      photoURL: snapshot['photoURL'],
      year: snapshot['year'],
      section: snapshot['section'],
      department: snapshot['department'],
      studentId: snapshot['studentId'],
      dob: snapshot['dob'] is Timestamp ? (snapshot['dob'] as Timestamp).toDate().toString().substring(0, 10) : snapshot['dob'],
      contactNo: snapshot['contactNo'],
    );
  }

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'],
      email: data['email'],
      role: Role.values.firstWhere((e) => e.name == data['role']),
      rollNumber: data['rollNumber'],
      className: data['className'],
      photoURL: data['photoURL'],
      year: data['year'],
      section: data['section'],
      department: data['department'],
      studentId: data['studentId'],
      dob: data['dob'] is Timestamp ? (data['dob'] as Timestamp).toDate().toString().substring(0, 10) : data['dob'],
      contactNo: data['contactNo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'rollNumber': rollNumber,
      'className': className,
      'photoURL': photoURL,
      'year': year,
      'section': section,
      'department': department,
      'studentId': studentId,
      'dob': dob,
      'contactNo': contactNo,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    Role? role,
    String? rollNumber,
    String? className,
    String? photoURL,
    String? year,
    String? section,
    String? department,
    String? studentId,
    String? dob,
    String? contactNo,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      photoURL: photoURL ?? this.photoURL,
      year: year ?? this.year,
      section: section ?? this.section,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      dob: dob ?? this.dob,
      contactNo: contactNo ?? this.contactNo,
    );
  }

  String get fullName => name ?? "N/A";
}
