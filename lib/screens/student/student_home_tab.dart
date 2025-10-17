import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_doc/models/document.dart';
import 'package:smart_doc/screens/student/document_detail_screen.dart';
import 'package:smart_doc/services/document_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  final DocumentStorageService _documentStorageService = DocumentStorageService();

  Future<void> _deleteDocument(String documentId) async {
    try {
      await _documentStorageService.deleteDocument(documentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = Provider.of<List<Document>>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Documents',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: documents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'You haven\'t uploaded any documents yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(doc.name),
                            subtitle: Text('Uploaded on: ${doc.uploadedDate}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () async {
                                    if (doc.downloadUrl != null &&
                                        await canLaunchUrl(Uri.parse(doc.downloadUrl!))) {
                                      await launchUrl(Uri.parse(doc.downloadUrl!));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Could not open document.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Document'),
                                          content: const Text(
                                              'Are you sure you want to delete this document?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                _deleteDocument(doc.id);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DocumentDetailScreen(document: doc),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
