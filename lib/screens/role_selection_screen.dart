import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:collegeapplication/models/role.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Student'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen(role: Role.student)),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Faculty'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen(role: Role.faculty)),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Admin'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen(role: Role.admin)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
