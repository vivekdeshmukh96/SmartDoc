import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_doc/models/user.dart' as AppUser;

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _sendTo = 'All Students';
  String? _selectedStudentId;
  List<AppUser.User> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final students = snapshot.docs
          .map((doc) => AppUser.User.fromFirestore(doc.data(), doc.id))
          .toList();
      setState(() {
        _students = students;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final faculty = FirebaseAuth.instance.currentUser;
      if (faculty == null) {
        // Handle not logged in
        return;
      }

      String targetType = _sendTo == 'All Students' ? 'all' : _selectedStudentId!;

      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': _titleController.text,
          'message': _messageController.text,
          'senderId': faculty.uid,
          'target': targetType,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(labelText: 'Message'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _sendTo,
                      items: ['All Students', 'Specific Student']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sendTo = value!;
                          _selectedStudentId = null;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Send To'),
                    ),
                    if (_sendTo == 'Specific Student') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStudentId,
                        hint: const Text('Select Student'),
                        items: _students
                            .map((student) => DropdownMenuItem(
                                  value: student.id,
                                  child: Text(student.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                          });
                        },
                        validator: (value) {
                          if (_sendTo == 'Specific Student' && value == null) {
                            return 'Please select a student';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _sendNotification,
                        child: const Text('Send Notification'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
