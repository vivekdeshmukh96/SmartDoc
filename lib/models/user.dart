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
}
