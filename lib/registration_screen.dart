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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          // Save additional user data to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'email': _emailController.text,
            'role': widget.role,
            if (widget.role == 'Student') ...{
              'studentName': _studentNameController.text,
              'year': _yearController.text,
              'section': _sectionController.text,
              'studentId': _studentIdController.text,
            }
          });

          // Navigate to a home screen or show success
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } on FirebaseAuthException catch (e) {
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
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(labelText: 'Year'),
                    validator: (value) => value!.isEmpty ? 'Please enter your year' : null,
                  ),
                  TextFormField(
                    controller: _sectionController,
                    decoration: InputDecoration(labelText: 'Section'),
                    validator: (value) => value!.isEmpty ? 'Please enter your section' : null,
                  ),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(labelText: 'Student ID'),
                    validator: (value) => value!.isEmpty ? 'Please enter your student ID' : null,
                  ),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
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
