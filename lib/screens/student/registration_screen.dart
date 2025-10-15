import 'dart:io';

import 'package:smart_doc/screens/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:smart_doc/models/role.dart';

class RegistrationScreen extends StatefulWidget {
  final Role role;

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

  File? _studentIdCard;
  bool _isOcrInProgress = false;

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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _studentIdCard = File(pickedFile.path);
      });
    }
  }

  Future<void> _performOcr() async {
    if (_studentIdCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
     if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isOcrInProgress = true;
    });

    final inputImage = InputImage.fromFile(_studentIdCard!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    final expectedName = _studentNameController.text.trim().toLowerCase();
    final expectedId =
        _studentIdController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');

    bool isNameFound = false;
    bool isIdFound = false;

    // Check for name: A simple contains check on the whole lowercased text is a good start.
    if (recognizedText.text.toLowerCase().contains(expectedName)) {
      isNameFound = true;
    }

    // Check for ID: More robust check by normalizing the OCR text
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        // Normalize the OCR line text by keeping only numbers
        final ocrLineNumeric = line.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (ocrLineNumeric.contains(expectedId)) {
          isIdFound = true;
          break; // Found the ID, no need to check other lines in this block
        }
      }
      if (isIdFound) {
        break; // Found the ID, no need to check other blocks
      }
    }

    textRecognizer.close();

    setState(() {
      _isOcrInProgress = false;
    });

    if (isNameFound && isIdFound) {
      _register();
    } else {
      // Construct a specific error message
      String errorMessage = 'OCR validation failed. ';
      if (!isNameFound && !isIdFound) {
        errorMessage += 'Could not find your name or student ID on the card.';
      } else if (!isNameFound) {
        errorMessage += 'Could not find your name on the card.';
      } else {
        errorMessage += 'Could not find your student ID on the card.';
      }
      errorMessage += ' Please check the details and the uploaded image.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _register() async {
    // The form is already validated in _performOcr for students
    if (widget.role != Role.student && !_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;
    final studentName = _studentNameController.text;
    final year = _yearController.text;
    final section = _sectionController.text;
    final studentId = _studentIdController.text;
    final role = widget.role.toString().split('.').last;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        final userData = {
          'id': user.uid,
          'email': email,
          'role': role,
          'name': studentName,
          if (widget.role == Role.student) ...{
            'studentName': studentName,
            'year': year,
            'section': section,
            'studentId': studentId,
          }
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentDashboardScreen(initialIndex: 1),
            ),
            (route) => false,
          );
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
        title: Text('${widget.role.toString().split('.').last} Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (widget.role == Role.student) ...[
                  TextFormField(
                    controller: _studentNameController,
                    decoration: InputDecoration(labelText: 'Student Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(labelText: 'Student ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your student ID' : null,
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
                  _studentIdCard == null
                      ? Text('No image selected.')
                      : Image.file(_studentIdCard!),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Student ID Card'),
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
                _isOcrInProgress
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed:
                            widget.role == Role.student ? _performOcr : _register,
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
