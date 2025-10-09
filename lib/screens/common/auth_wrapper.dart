import 'package:collegeapplication/models/role.dart';
import 'package:collegeapplication/screens/login_screen.dart';
import 'package:collegeapplication/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/user.dart';
import 'admin/admin_dashboard_screen.dart';
import 'faculty/faculty_dashboard_screen.dart';
import 'student/student_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (user == null) {
      return const LoginScreen(
        role: Role.student,
      );
    }

    switch (user.role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.faculty:
        return const FacultyDashboardScreen();
      case UserRole.student:
        return const StudentDashboardScreen();
      default:
        return RoleSelectionScreen();
    }
  }
}
