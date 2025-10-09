import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'models/document.dart';
import 'models/user.dart';
import 'models/role.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  final List<Document> _documents = [];
  final List<String> _categories = ['ID Card', 'Marksheet', 'Bonafide', 'Fee Receipt', 'Certificate'];
  final List<User> _users = [
    User(id: 'student1', email: 'student@college.edu', role: Role.student, name: 'Alice Student', rollNumber: '12345', className: 'CS101'),
    User(id: 'faculty1', email: 'faculty@college.edu', role: Role.faculty, name: 'Dr. Bob Faculty'),
    User(id: 'admin1', email: 'admin@college.edu', role: Role.admin, name: 'Ms. Carol Admin'),
  ];
  final Uuid _uuid = const Uuid();

  User? get currentUser => _currentUser;
  List<Document> get documents => List.unmodifiable(_documents);
  List<String> get categories => List.unmodifiable(_categories);
  List<User> get users => List.unmodifiable(_users);

  // --- Authentication ---
  void login(String email, String password) {
    // Simulate authentication
    final user = _users.firstWhere(
          (u) => u.email == email, // In real app, hash password
      orElse: () => throw Exception('Invalid credentials'),
    );
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void registerUser(User newUser, String password) {
    if (_users.any((user) => user.email == newUser.email)) {
      throw Exception('User with this email already exists.');
    }
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
  }


  // --- Document Management ---
  Future<Map<String, String>> getDocumentAnalysis(Uint8List imageBytes) async {
    // Simulate AI document analysis (e.g., calling a cloud service)
    await Future.delayed(const Duration(seconds: 2)); 

    // Simulated result
    return {
      'name': 'Scanned_Document_123.pdf',
      'category': 'Marksheet',
    };
  }

  Future<void> addDocument(String name, String category, Uint8List imageBytes) async {
    if (name.isEmpty || category.isEmpty) {
      throw Exception('Document name and category cannot be empty.');
    }
    final newDoc = Document(
      id: _uuid.v4(),
      name: name,
      category: category,
      status: DocumentStatus.pending,
      uploadedByUserId: _currentUser!.id,
      uploadedDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      // imageBytes: imageBytes, // If you want to store the image bytes
    );
    _documents.add(newDoc);
    notifyListeners();
  }

  void updateDocumentStatus(String docId, DocumentStatus status, {String? comments, String? verifiedByUserId}) {
    final index = _documents.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        status: status,
        comments: comments,
        verifiedByUserId: verifiedByUserId,
        verificationDate: status != DocumentStatus.pending ? DateFormat('dd/MM/yyyy').format(DateTime.now()) : null,
      );
      notifyListeners();
    }
  }

  // --- Category Management ---
  void addCategory(String newCategory) {
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      _categories.add(newCategory);
      notifyListeners();
    } else {
      throw Exception('Category already exists or is empty.');
    }
  }

  void deleteCategory(String categoryToDelete) {
    if (_categories.contains(categoryToDelete)) {
      _categories.remove(categoryToDelete);
      notifyListeners();
    } else {
      throw Exception('Category not found.');
    }
  }

  // --- User Management (Simplified) ---
  void addUser(String name, String email, String password, Role role, {String? rollNumber, String? className}) {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('All fields are required.');
    }
    if (_users.any((user) => user.email == email)) {
      throw Exception('User with this email already exists.');
    }
    _users.add(User(id: _uuid.v4(), name: name, email: email, role: role, rollNumber: rollNumber, className: className));
    notifyListeners();
  }

  void removeUser(String userId) {
    if (_currentUser?.id == userId) {
      throw Exception('Cannot remove current logged-in user.');
    }
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  // --- Analytics (Simplified) ---
  int getTotalDocuments() => _documents.length;

  int getDocumentsByStatus(DocumentStatus status) {
    return _documents.where((doc) => doc.status == status).length;
  }

  Map<String, int> getDocumentsByCategory() {
    final Map<String, int> counts = {};
    for (var category in _categories) {
      counts[category] = _documents.where((doc) => doc.category == category).length;
    }
    return counts;
  }
}
