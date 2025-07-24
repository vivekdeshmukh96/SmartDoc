import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/document.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final totalDocs = appState.getTotalDocuments();
        final approvedDocs = appState.getDocumentsByStatus(DocumentStatus.approved);
        final rejectedDocs = appState.getDocumentsByStatus(DocumentStatus.rejected);
        final pendingDocs = appState.getDocumentsByStatus(DocumentStatus.pending);
        final docsByCategory = appState.getDocumentsByCategory();

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
                      _buildAnalyticRow('Total Documents:', totalDocs.toString()),
                      _buildAnalyticRow('Approved:', approvedDocs.toString(), color: Colors.green),
                      _buildAnalyticRow('Rejected:', rejectedDocs.toString(), color: Colors.red),
                      _buildAnalyticRow('Pending:', pendingDocs.toString(), color: Colors.orange),
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

  Widget _buildAnalyticRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text(
          //   label,
          //   style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          // ),
          // Text(
          //   value,
          //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //     fontWeight: FontWeight.bold,
          //     color: color ?? Colors.blueGrey.shade800,
          //   ),
          // ),
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