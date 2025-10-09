import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;

  RegistrationScreen({required this.role});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Common fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Student specific fields
  final _studentNameController = TextEditingController();
  final _yearController = TextEditingController();
  final _sectionController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    _studentNameController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // First, validate the form.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // **THE FIX**: Read all values from controllers BEFORE the async gap.
    final email = _emailController.text;
    final password = _passwordController.text;
    final studentName = _studentNameController.text;
    final year = _yearController.text;
    final section = _sectionController.text;
    final studentId = _studentIdController.text;
    final role = widget.role;

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Prepare user data using the variables we captured earlier
        final userData = {
          'email': email,
          'role': role,
          if (role == 'Student') ...{
            'studentName': studentName,
            'year': year,
            'section': section,
            'studentId': studentId,
          }
        };
        
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);

        // Navigate back to the first screen if the widget is still mounted
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (widget.role == 'Student') ...[
                  TextFormField(
                    controller: _studentNameController,
                    decoration: InputDecoration(labelText: 'Student Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(labelText: 'Year'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your year' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _sectionController,
                    decoration: InputDecoration(labelText: 'Section'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your section' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(labelText: 'Student ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your student ID' : null,
                  ),
                  SizedBox(height: 8),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
