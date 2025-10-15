import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart';
import 'package:smart_doc/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('documents').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No documents found.'));
        }

        final documents = snapshot.data!.docs
            .map((doc) => Document.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        final totalDocs = documents.length;
        final approvedDocs = documents
            .where((doc) => doc.status == DocumentStatus.approved)
            .length;
        final rejectedDocs = documents
            .where((doc) => doc.status == DocumentStatus.rejected)
            .length;
        final pendingDocs = documents
            .where((doc) => doc.status == DocumentStatus.pending)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildMetricCard(context, 'Total Documents', totalDocs.toString(), Colors.blue),
              _buildMetricCard(context, 'Approved Documents', approvedDocs.toString(), Colors.green),
              _buildMetricCard(context, 'Rejected Documents', rejectedDocs.toString(), Colors.red),
              _buildMetricCard(context, 'Pending Documents', pendingDocs.toString(), Colors.orange),
              const SizedBox(height: 24),
              Text(
                'All Documents in System',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (documents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No documents in the system yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(doc.uploadedByUserId).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text('User not found'));
                        }
                        final uploadedBy = userSnapshot.data!['name'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Category: ${doc.category}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Status: ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                    StatusBadge(status: doc.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Uploaded by: $uploadedBy on ${doc.uploadedDate}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                if (doc.verifiedByUserId != null) ...[
                                  const SizedBox(height: 4),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(doc.verifiedByUserId!).get(),
                                    builder: (context, verifiedBySnapshot) {
                                      if (verifiedBySnapshot.connectionState == ConnectionState.waiting) {
                                        return const Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.grey));
                                      }
                                      if (!verifiedBySnapshot.hasData) {
                                        return const Text('N/A', style: TextStyle(fontSize: 14, color: Colors.grey));
                                      }
                                      final verifiedBy = verifiedBySnapshot.data!['name'];
                                      return Text(
                                        'Verified by: $verifiedBy on ${doc.verificationDate}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ],
                                if (doc.comments != null && doc.comments!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Comments: ${doc.comments}',
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
