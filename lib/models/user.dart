enum UserRole {
  student,
  faculty,
  admin,
}

class User {
  final String id;
  final String name;
  final String email;
  final String password; // In a real app, this would be hashed
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = 'password', // Default password for simulation
    required this.role,
  });
}