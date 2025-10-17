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

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    final dobValue = data['DoB'] ?? data['dob'];
    return User(
      id: id,
      name: data['studentName'] ?? data['name'],
      email: data['email'] ?? data['email11'] ?? '',
      role: Role.values.firstWhere((e) => e.name == data['role'], orElse: () => Role.student),
      rollNumber: data['rollNumber'],
      className: data['className'],
      photoURL: data['photoURL'],
      year: data['year'],
      section: data['section'],
      department: data['Department'] ?? data['department'],
      studentId: data['studentId'],
      dob: dobValue is Timestamp ? dobValue.toDate().toString().substring(0, 10) : dobValue,
      contactNo: data['ContactNo'] ?? data['contactNo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': name,
      'email': email,
      'role': role.name,
      'rollNumber': rollNumber,
      'className': className,
      'photoURL': photoURL,
      'year': year,
      'section': section,
      'Department': department,
      'studentId': studentId,
      'DoB': dob,
      'ContactNo': contactNo,
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
