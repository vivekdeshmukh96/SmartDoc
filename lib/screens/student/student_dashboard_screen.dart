import 'package:collegeapplication/screens/student/student_home_tab.dart';
import 'package:collegeapplication/screens/student/student_notifications_tab.dart';
import 'package:collegeapplication/screens/student/student_profile_tab.dart';
import 'package:collegeapplication/screens/student/student_upload_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String userName = appState.currentUser?.name ?? 'Student';

    final List<Widget> _widgetOptions = <Widget>[
      StudentHomeTab(),
      StudentUploadTab(),
      StudentNotificationsTab(),
      StudentProfileTab(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Welcome, $userName!',
        showLogout: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}