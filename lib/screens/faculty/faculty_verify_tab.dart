import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart' as doc;
import 'package:url_launcher/url_launcher.dart';

class FacultyVerifyTab extends StatefulWidget {
  const FacultyVerifyTab({super.key});

  @override
  State<FacultyVerifyTab> createState() => _FacultyVerifyTabState();
}

class _FacultyVerifyTabState extends State<FacultyVerifyTab> {
  Future<void> _updateDocumentStatus(doc.Document document, String status) async {
    // Get the reference to the document
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(document.uploadedByUserId)
        .collection('documents')
        .doc(document.id);

    // Update the status
    await docRef.update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Documents'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('documents')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No documents to verify.'),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final docData = snapshot.data!.docs[index];
              final document = doc.Document.fromFirestore(
                  docData.data() as Map<String, dynamic>, docData.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text(document.name),
                      subtitle: Text('Status: ${document.status.name}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        if (document.url != null) {
                          final Uri url = Uri.parse(document.url!);
                          try {
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not launch $url'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error launching document: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _updateDocumentStatus(document, 'approved');
                            },
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _updateDocumentStatus(document, 'rejected');
                            },
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
