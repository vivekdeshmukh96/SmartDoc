
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String senderId;
  final String senderName; // Added senderName
  final String target;
  final Timestamp timestamp;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.senderId,
    required this.senderName, // Added to constructor
    required this.target,
    required this.timestamp,
  });

  factory Notification.fromFirestore(Map<String, dynamic> data, String id) {
    return Notification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'N/A', // Added with default value
      target: data['target'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
