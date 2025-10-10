import 'package:collegeapplication/screens/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../widgets/document_card.dart';
import 'document_detail_screen.dart';

class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final studentDocuments = appState.documents
            .where((doc) => doc.uploadedByUserId == appState.currentUser?.id)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Documents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (studentDocuments.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No documents uploaded yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to the upload tab
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentDashboardScreen(initialIndex: 1)));
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scan Document'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: studentDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = studentDocuments[index];
                      return DocumentCard(
                        document: doc,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentDetailScreen(document: doc),
                            ),
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
