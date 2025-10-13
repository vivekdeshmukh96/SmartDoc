import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/document.dart';
import 'package:collegeapplication/utils/string_extensions.dart';
import 'package:collegeapplication/widgets/document_card.dart';
import 'package:collegeapplication/widgets/message_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FacultyVerifyTab extends StatefulWidget {
  const FacultyVerifyTab({super.key});

  @override
  State<FacultyVerifyTab> createState() => _FacultyVerifyTabState();
}

class _FacultyVerifyTabState extends State<FacultyVerifyTab> {
  String? _selectedCategoryFilter;
  DocumentStatus? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showVerificationModal(BuildContext context, Document doc) {
    final TextEditingController commentsController = TextEditingController(text: doc.comments);
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text(
            'Verify Document',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document: ${doc.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Category: ${doc.category}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(doc.uploadedByUserId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Uploaded By: Loading...', style: TextStyle(fontSize: 14, color: Colors.grey));
                    }
                    return Text('Uploaded By: ${snapshot.data?['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey));
                  },
                ),
                const SizedBox(height: 8),
                Text('Current Status: ${doc.status.toString().split('.').last.capitalize()}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Comments (Optional)',
                    hintText: 'Add comments for verification...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('documents').doc(doc.id).update({
                        'status': DocumentStatus.approved.name,
                        'comments': commentsController.text,
                        'verifiedByUserId': currentUser?.uid,
                        'verificationDate': DateTime.now().toIso8601String(),
                      });
                      Navigator.of(context).pop();
                      showMessageBox(context, 'Success', 'Document approved.');
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('documents').doc(doc.id).update({
                        'status': DocumentStatus.rejected.name,
                        'comments': commentsController.text,
                        'verifiedByUserId': currentUser?.uid,
                        'verificationDate': DateTime.now().toIso8601String(),
                      });
                      Navigator.of(context).pop();
                      showMessageBox(context, 'Success', 'Document rejected.');
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Documents',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search by Name or Student ID',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var categories = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    hint: const Text('All Categories'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryFilter = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<DocumentStatus>(
                value: _selectedStatusFilter,
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                hint: const Text('All Statuses'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...DocumentStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name.capitalize()),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatusFilter = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('documents').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No documents found.'));
              }

              var documents = snapshot.data!.docs
                  .map((doc) => Document.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
                  .where((doc) {
                    final matchesCategory = _selectedCategoryFilter == null || doc.category == _selectedCategoryFilter;
                    final matchesStatus = _selectedStatusFilter == null || doc.status == _selectedStatusFilter;
                    final matchesSearch = _searchController.text.isEmpty ||
                        doc.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                        doc.uploadedByUserId.toLowerCase().contains(_searchController.text.toLowerCase());
                    return matchesCategory && matchesStatus && matchesSearch;
                  }).toList();

              if (documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No documents found matching criteria.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(doc.uploadedByUserId).get(),
                    builder: (context, userSnapshot) {
                      final uploadedBy = userSnapshot.data?['name'] ?? 'Loading...';
                      return DocumentCard(
                        document: doc,
                        subtitle: 'Uploaded by: $uploadedBy on ${doc.uploadedDate}',
                      );
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
