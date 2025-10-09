enum UserRole {
  student,
  faculty,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final String password; 
  final UserRole role;
  final String? rollNumber;
  final String? className;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = 'password', 
    required this.role,
    this.rollNumber,
    this.className,
  });
}
