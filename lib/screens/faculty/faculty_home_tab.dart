import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/document.dart';
import 'package:collegeapplication/widgets/document_card.dart';
import 'package:flutter/material.dart';

class FacultyHomeTab extends StatelessWidget {
  const FacultyHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents Pending Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('status', isEqualTo: DocumentStatus.pending.name)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No documents pending verification.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final docData = snapshot.data!.docs[index];
                    final doc = Document.fromFirestore(docData.data() as Map<String, dynamic>, docData.id);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(doc.uploadedByUserId).get(),
                      builder: (context, userSnapshot) {
                        String uploadedBy = 'Loading...';
                        if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                          uploadedBy = userSnapshot.data!['name'] ?? 'Unknown User';
                        }

                        return DocumentCard(
                          document: doc,
                          subtitle: 'Uploaded by: $uploadedBy on ${doc.uploadedDate}',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tap "Verify" tab to review this document.')),
                            );
                          },
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
