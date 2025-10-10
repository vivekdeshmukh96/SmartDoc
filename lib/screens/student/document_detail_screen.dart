import 'package:collegeapplication/models/document.dart';
import 'package:collegeapplication/utils/string_extensions.dart';
import 'package:flutter/material.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final comments = document.comments;

    return Scaffold(
      appBar: AppBar(title: Text(document.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${document.status.name.capitalize()}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (comments != null && comments.isNotEmpty)
              Text('Comments: $comments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: InteractiveViewer(
                child: Center(
                  child: Image.network(document.downloadUrl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
