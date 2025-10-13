import 'package:collegeapplication/models/document.dart';
import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final String? subtitle;

  const DocumentCard({super.key, required this.document, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildFileTypeIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    document.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  document.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  document.uploadedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeIcon() {
    IconData iconData;
    Color color;
    switch (document.fileType) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = Colors.grey;
    }
    return Icon(iconData, color: color, size: 40);
  }

  Color _getStatusColor() {
    switch (document.status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.resubmission:
        return Colors.blue;
    }
  }
}
