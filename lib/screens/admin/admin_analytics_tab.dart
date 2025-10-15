import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_doc/models/document.dart';
import 'package:flutter/material.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

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

        final Map<String, int> docsByCategory = {};
        for (var doc in documents) {
          docsByCategory.update(doc.category, (value) => value + 1,
              ifAbsent: () => 1);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics & Reports',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Document Status Summary
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Status Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildAnalyticRow(context, 'Total Documents:', totalDocs.toString()),
                      _buildAnalyticRow(context, 'Approved:', approvedDocs.toString(), color: Colors.green),
                      _buildAnalyticRow(context, 'Rejected:', rejectedDocs.toString(), color: Colors.red),
                      _buildAnalyticRow(context, 'Pending:', pendingDocs.toString(), color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Documents by Category
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documents by Category',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      if (docsByCategory.isEmpty)
                        const Text('No categories with documents yet.', style: TextStyle(color: Colors.grey))
                      else
                        ...docsByCategory.entries.map((entry) => _buildAnalyticRow(
                          context,
                          '${entry.key}:',
                          entry.value.toString(),
                        )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // System Logs/Reports (Simulated)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Logs/Reports (Simulated)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),
                      Text(
                        'This section would display detailed system activities, such as user logins, document uploads, verification actions, and errors. For this prototype, it\'s a placeholder.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recent Activities:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildLogEntry('User Alice Student uploaded a new document (ID Card).'),
                      _buildLogEntry('Faculty Dr. Bob Faculty approved document "Degree Certificate".'),
                      _buildLogEntry('Admin Ms. Carol Admin added new category "Scholarship".'),
                      _buildLogEntry('User Alice Student viewed document "Marksheet".'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blueGrey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_note, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
