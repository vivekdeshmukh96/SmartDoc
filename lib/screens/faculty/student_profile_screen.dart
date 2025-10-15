
import 'package:flutter/material.dart';
import 'package:smart_doc/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart' as doc;

class StudentProfileScreen extends StatelessWidget {
  final User user;

  const StudentProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name ?? 'Student Profile'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.photoURL ?? ''),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name ?? 'No Name',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${user.year ?? ''} - ${user.section ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '${user.department ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '${user.sapid ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '${user.enrollnment ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '${user.dob ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                 Text(
                  '${user.email ?? ''}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),


              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Documents',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .collection('documents')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No documents found.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final docData = snapshot.data!.docs[index];
                    final document = doc.Document.fromFirestore(docData.data() as Map<String, dynamic>, docData.id);

                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(document.name ?? 'No Name'),
                      onTap: () {
                        // TODO: Handle document tap
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
