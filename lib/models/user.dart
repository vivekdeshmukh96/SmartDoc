import 'package:collegeapplication/models/role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final Role role;
  final String? rollNumber;
  final String? className;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.rollNumber,
    this.className,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'],
      email: data['email'],
      role: Role.values.firstWhere((e) => e.name == data['role']),
      rollNumber: data['rollNumber'],
      className: data['className'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'rollNumber': rollNumber,
      'className': className,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    Role? role,
    String? rollNumber,
    String? className,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
    );
  }
}
