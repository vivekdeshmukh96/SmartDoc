import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/document.dart';
import '../../widgets/document_card.dart';

class FacultyHomeTab extends StatelessWidget {
  const FacultyHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final pendingDocuments = appState.documents
            .where((doc) => doc.status == DocumentStatus.pending)
            .toList();

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
              if (pendingDocuments.isEmpty)
                Expanded(
                  child: Center(
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
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: pendingDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = pendingDocuments[index];
                      final uploadedBy = appState.users.firstWhere((user) => user.id == doc.uploadedByUserId).name;
                      return DocumentCard(
                        document: doc,
                        subtitle: 'Uploaded by: $uploadedBy on ${doc.uploadedDate}',
                        onTap: () {
                          // Navigate to verification tab or open modal directly
                          // For now, let's just show a message or navigate to a dedicated verify screen
                          // A better approach would be to open the verification modal here directly
                          // or switch to the verify tab and pre-select the document.
                          // For simplicity, we'll just show a message.
                          // The actual verification logic is in FacultyVerifyTab
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tap "Verify" tab to review this document.')),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}