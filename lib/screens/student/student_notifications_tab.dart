import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/document.dart';

class StudentNotificationsTab extends StatelessWidget {
  const StudentNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final currentUser = appState.currentUser;
        if (currentUser == null) {
          return const Center(child: Text('Please log in to view notifications.'));
        }

        final notifications = appState.documents
            .where((doc) => doc.uploadedByUserId == currentUser.id)
            .map((doc) {
          String message = '';
          IconData icon = Icons.info_outline;
          Color color = Colors.blue;

          switch (doc.status) {
            case DocumentStatus.approved:
              message = 'Your document "${doc.name}" has been APPROVED.';
              icon = Icons.check_circle;
              color = Colors.green;
              break;
            case DocumentStatus.rejected:
              message = 'Your document "${doc.name}" has been REJECTED. Comments: ${doc.comments ?? 'N/A'}';
              icon = Icons.cancel;
              color = Colors.red;
              break;
            case DocumentStatus.resubmission:
              message = 'Your document "${doc.name}" requires RESUBMISSION. Comments: ${doc.comments ?? 'N/A'}';
              icon = Icons.refresh;
              color = Colors.orange;
              break;
            case DocumentStatus.pending:
            // Pending documents are not typically "notifications" in this context
              return null; // Filter out pending documents
          }
          return {'message': message, 'icon': icon, 'color': color, 'date': doc.verificationDate ?? doc.uploadedDate};
        })
            .where((notification) => notification != null)
            .toList();

        // Sort notifications by date, most recent first
        notifications.sort((a, b) {
          final DateTime dateA = DateFormat('dd/MM/yyyy').parse(a!['date']);
          final DateTime dateB = DateFormat('dd/MM/yyyy').parse(b!['date']);
          return dateB.compareTo(dateA);
        });

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No new notifications.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(notification['icon'] as IconData?, color: notification['color'] as Color?, size: 30),
                          title: Text(
                            notification['message'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Date: ${notification['date']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
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
