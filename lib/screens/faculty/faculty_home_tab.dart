
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/user.dart';

class FacultyHomeTab extends StatefulWidget {
  const FacultyHomeTab({super.key});

  @override
  _FacultyHomeTabState createState() => _FacultyHomeTabState();
}

class _FacultyHomeTabState extends State<FacultyHomeTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No students found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final user = User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
              title: Text(user.name ?? 'No Name'),
              subtitle: Text(user.className ?? 'No Class'),
              onTap: () {
                // TODO: Navigate to student documents screen
              },
            );
          },
        );
      },
    );
  }
}
