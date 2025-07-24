import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
// No specific notifications for faculty in this prototype,
// but this tab is here for future expansion (e.g., new pending documents).

class FacultyNotificationsTab extends StatelessWidget {
  const FacultyNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // In a real app, this would show notifications like:
        // - "New document uploaded by [Student Name]"
        // - "Document [Doc Name] requires your attention (e.g., resubmission request)"
        // For now, it's a placeholder.
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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No new notifications for faculty at this time.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
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
}