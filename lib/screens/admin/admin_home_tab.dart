import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/document.dart';
import '../../widgets/status_badge.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final totalDocs = appState.getTotalDocuments();
        final approvedDocs = appState.getDocumentsByStatus(DocumentStatus.approved);
        final rejectedDocs = appState.getDocumentsByStatus(DocumentStatus.rejected);
        final pendingDocs = appState.getDocumentsByStatus(DocumentStatus.pending);

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
              if (appState.documents.isEmpty)
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
                  itemCount: appState.documents.length,
                  itemBuilder: (context, index) {
                    final doc = appState.documents[index];
                    final uploadedBy = appState.users.firstWhere((user) => user.id == doc.uploadedByUserId).name;
                    final verifiedBy = doc.verifiedByUserId != null
                        ? appState.users.firstWhere((user) => user.id == doc.verifiedByUserId!).name
                        : 'N/A';
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
                              Text(
                                'Verified by: $verifiedBy on ${doc.verificationDate}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
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