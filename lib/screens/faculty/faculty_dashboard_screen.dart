import 'package:flutter/material.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome, Faculty!'),
      ),
    );
  }
}
