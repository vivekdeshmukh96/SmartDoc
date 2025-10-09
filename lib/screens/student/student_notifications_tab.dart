import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentNotificationsTab extends StatelessWidget {
  const StudentNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated notifications data
    final List<Map<String, Object>> notifications = [
      {
        'title': 'Fee Reminder',
        'message': 'Your semester fee is due on 25th July 2024.',
        'date': '15/07/2024',
        'isRead': false,
      },
      {
        'title': 'Exam Schedule',
        'message': 'Your final year exam schedule has been released.',
        'date': '10/07/2024',
        'isRead': true,
      },
      {
        'title': 'Holiday Notice',
        'message': 'The college will be closed on 15th August 2024.',
        'date': '01/07/2024',
        'isRead': true,
      },
    ];

    // Sort notifications by date (most recent first)
    notifications.sort((a, b) {
      try {
        final DateFormat format = DateFormat('dd/MM/yyyy');
        final DateTime dateA = format.parse(a['date'] as String);
        final DateTime dateB = format.parse(b['date'] as String);
        return dateB.compareTo(dateA); // Use compareTo for proper sorting
      } catch (e) {
        // Handle potential parsing errors gracefully
        return 0;
      }
    });


    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: !(notification['isRead'] as bool) ? Theme.of(context).primaryColor : Colors.grey,
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text(
              notification['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: !(notification['isRead'] as bool) ? Colors.black87 : Colors.grey[600],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: TextStyle(
                    color: !(notification['isRead'] as bool) ? Colors.black54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['date'] as String,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              // TODO: Mark as read and navigate to notification details
            },
          ),
        );
      },
    );
  }
}
