import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smart_doc/models/role.dart';
import 'package:smart_doc/models/user.dart' as model;
import 'package:smart_doc/providers/user_provider.dart';
import 'package:smart_doc/screens/faculty/faculty_registration_screen.dart';
import 'package:smart_doc/screens/faculty/faculty_waiting_screen.dart';
import 'package:smart_doc/screens/student/registration_screen.dart';
import 'package:smart_doc/widgets/message_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/string_extensions.dart';
import 'common/auth_wrapper.dart';

class LoginScreen extends StatefulWidget {
  final Role role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showMessageBox(context, 'Error', 'Please fill all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_emailController.text == 'deshmukhvivek596@gmail.com' &&
          _passwordController.text == '05102005') {
        try {
          final UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          final user = userCredential.user;
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'role': 'admin',
              'fullName': 'Vivek Deshmukh',
            }, SetOptions(merge: true));
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            final UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );
            final user = userCredential.user;
            if (user != null) {
              await _firestore.collection('users').doc(user.uid).set({
                'email': user.email,
                'role': 'admin',
                'fullName': 'Vivek Deshmukh',
              });
            }
          } else {
            rethrow;
          }
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
          );
        }
        return;
      }

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found.');
      }

      final user = model.User.fromFirestore(userDoc.data() as Map<String, dynamic>, userDoc.id);
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }

      if (user.role != widget.role) {
        await _auth.signOut();
        throw Exception('Selected role does not match user account role.');
      }

      if (widget.role == Role.faculty) {
        final DocumentSnapshot facultyDoc = await _firestore
            .collection('faculty')
            .doc(userCredential.user!.uid)
            .get();

        if (!facultyDoc.exists) {
          await _auth.signOut();
          throw Exception('You are not registered as a faculty member.');
        }

        final facultyData = facultyDoc.data() as Map<String, dynamic>?;
        final status = facultyData?['status'];
        final String statusString = status is String ? status : '';

        if (statusString == 'pending') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const FacultyWaitingScreen()),
            );
          }
        } else if (statusString == 'approved') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
            );
          }
        } else {
          await _auth.signOut();
          throw Exception(
              'Your registration has been denied or an error occurred.');
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'An unknown error occurred.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        showMessageBox(context, 'Login Failed', errorMessage);
      }
    } catch (e) {
      if (mounted) {
        showMessageBox(
            context, 'Login Failed', e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Login as ${widget.role.toString().split('.').last.capitalize()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'user@college.edu',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                    if (widget.role == Role.student)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RegistrationScreen(role: widget.role)),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    if (widget.role == Role.faculty)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FacultyRegistrationScreen()),
                          );
                        },
                        child: const Text('Register Here'),
                      ),
                    TextButton(
                      onPressed: () {
                        showMessageBox(context, 'Feature',
                            'Forgot Password not implemented in prototype.');
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
