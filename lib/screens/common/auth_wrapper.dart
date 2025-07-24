import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/user.dart';
import '../admin/admin_dashboard_screen.dart';
import '../faculty/faculty_dashboard_screen.dart';
import '../login_screen.dart';
import '../student/student_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.currentUser == null) {
          // User is not logged in, go to login screen
          return const LoginScreen();
        } else {
          // User is logged in, navigate to appropriate dashboard
          switch (appState.currentUser!.role) {
            case UserRole.student:
              return const StudentDashboardScreen();
            case UserRole.faculty:
              return const FacultyDashboardScreen();
            case UserRole.admin:
              return const AdminDashboardScreen();
          }
        }
      },
    );
  }
}