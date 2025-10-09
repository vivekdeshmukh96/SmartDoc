import 'package:collegeapplication/app_state.dart';
import 'package:collegeapplication/models/user.dart';
import 'package:collegeapplication/screens/admin/admin_dashboard_screen.dart';
import 'package:collegeapplication/screens/faculty/faculty_dashboard_screen.dart';
import 'package:collegeapplication/screens/login_screen.dart';
import 'package:collegeapplication/screens/role_selection_screen.dart';
import 'package:collegeapplication/screens/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collegeapplication/models/role.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (user == null) {
      return RoleSelectionScreen();
    }

    switch (user.role) {
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
}
