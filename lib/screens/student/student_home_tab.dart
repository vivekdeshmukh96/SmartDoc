import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart';
import 'package:smart_doc/screens/student/document_detail_screen.dart';
import 'package:smart_doc/services/document_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  final DocumentStorageService _documentStorageService =
      DocumentStorageService();

  Future<void> _deleteDocument(String documentId) async {
    try {
      //Also delete from firestore
      await FirebaseFirestore.instance.collection('documents').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Documents',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('documents')
                    .where('uploadedByUserId', isEqualTo: currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'You haven\'t uploaded any documents yet.',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final documents = snapshot.data!.docs
                      .map((doc) => Document.fromFirestore(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(doc.name),
                          subtitle: Text('Uploaded on: ${doc.uploadedDate}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () async {
                                  if (doc.downloadUrl != null && await canLaunchUrl(Uri.parse(doc.downloadUrl!))) {
                                    await launchUrl(Uri.parse(doc.downloadUrl!));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not open document.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteDocument(doc.id),
                              ),
                            ],
                          ),
                           onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DocumentDetailScreen(document: doc),
                            ),
                          );
                        },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
