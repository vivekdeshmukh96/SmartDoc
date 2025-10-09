import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../login_screen.dart';
import 'package:collegeapplication/utils/string_extensions.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final currentUser = appState.currentUser;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentUser?.name ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentUser?.email ?? 'N/A',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          currentUser?.role.toString().split('.').last.capitalize() ?? 'N/A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.blueAccent.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      const SizedBox(height: 30),
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
                        title: const Text('User ID'),
                        subtitle: Text(currentUser?.id ?? 'N/A'),
                      ),
                      // Add more profile details here if needed
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    appState.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
