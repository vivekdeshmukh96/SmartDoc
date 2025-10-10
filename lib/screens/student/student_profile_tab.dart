import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collegeapplication/models/user.dart' as AppUser;

import '../../utils/string_extensions.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After logout, you might want to navigate to the login screen
    // or some other initial screen of your app.
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAuth = FirebaseAuth.instance.currentUser;

    if (currentUserAuth == null) {
      // Handle the case where the user is not logged in
      return const Center(child: Text('Not logged in.'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserAuth.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Error fetching user data.'));
        }

        final currentUser = AppUser.User.fromFirestore(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, currentUser),
              const SizedBox(height: 30),
              _buildProfileInfoCard(currentUser),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser.User? currentUser) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 80, color: Colors.blueAccent),
        ),
        const SizedBox(height: 16),
        Text(
          currentUser?.name ?? 'N/A',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          currentUser?.role.toString().split('.').last.capitalize() ?? 'N/A',
          style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(AppUser.User? currentUser) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const Divider(height: 30, thickness: 1),
            _buildInfoRow(Icons.email, 'Email', currentUser?.email ?? 'N/A'),
            _buildInfoRow(Icons.school, 'Roll Number', currentUser?.rollNumber ?? 'N/A'),
            _buildInfoRow(Icons.class_, 'Class', currentUser?.className ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
