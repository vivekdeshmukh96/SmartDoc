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

  // fromMap method to create a User object from a map (e.g., from Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: Role.values.firstWhere((e) => e.toString() == 'Role.' + map['role']),
      rollNumber: map['rollNumber'],
      className: map['className'],
    );
  }

  // toMap method to convert a User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'rollNumber': rollNumber,
      'className': className,
    };
  }
}
