
import 'package:flutter/material.dart';
import 'login_screen.dart';

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
                  MaterialPageRoute(builder: (context) => LoginScreen(role: 'Student')),
                );
              },
            ),
            ElevatedButton(
              child: Text('Faculty'),
              onPressed: () {
                // Navigate to Faculty login/registration
              },
            ),
            ElevatedButton(
              child: Text('Admin'),
              onPressed: () {
                // Navigate to Admin login/registration
              },
            ),
          ],
        ),
      ),
    );
  }
}
