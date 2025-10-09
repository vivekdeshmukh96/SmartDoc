
import 'package:collegeapplication/screens/placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:collegeapplication/models/role.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Student'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(role: Role.student)),
                );
              },
            ),
            ElevatedButton(
              child: Text('Faculty'),
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Faculty')),
                );
              },
            ),
            ElevatedButton(
              child: Text('Admin'),
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceholderScreen(title: 'Admin')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
