
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/user.dart';
import 'package:smart_doc/screens/faculty/student_profile_screen.dart';

class FacultyHomeTab extends StatefulWidget {
  const FacultyHomeTab({super.key});

  @override
  _FacultyHomeTabState createState() => _FacultyHomeTabState();
}

class _FacultyHomeTabState extends State<FacultyHomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by name, year, or section',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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

              final filteredDocs = snapshot.data!.docs.where((doc) {
                final user = User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                final query = _searchQuery.toLowerCase();
                return (user.name ?? '').toLowerCase().contains(query) ||
                       (user.year ?? '').toLowerCase().contains(query) ||
                       (user.section ?? '').toLowerCase().contains(query);
              }).toList();

              return ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final user = User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL ?? ''),
                    ),
                    title: Text(user.name ?? 'No Name'),
                    subtitle: Text('${user.year ?? ''} - ${user.section ?? ''}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentProfileScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
