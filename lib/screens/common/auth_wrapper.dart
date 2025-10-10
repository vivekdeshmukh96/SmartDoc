import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/role.dart';
import 'package:collegeapplication/models/user.dart';
import 'package:collegeapplication/screens/admin/admin_dashboard_screen.dart';
import 'package:collegeapplication/screens/faculty/faculty_dashboard_screen.dart';
import 'package:collegeapplication/screens/login_screen.dart';
import 'package:collegeapplication/screens/role_selection_screen.dart';
import 'package:collegeapplication/screens/student/student_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = User.fromFirestore(userSnapshot.data!);
                switch (userData.role) {
                  case Role.admin:
                    return const AdminDashboardScreen();
                  case Role.faculty:
                    return const FacultyDashboardScreen();
                  case Role.student:
                    return const StudentDashboardScreen();
                  default:
                    return RoleSelectionScreen();
                }
              } 
              
              return RoleSelectionScreen();
            },
          );
        }
        
        return RoleSelectionScreen();
      },
    );
  }
}
