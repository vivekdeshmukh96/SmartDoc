import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapplication/models/document.dart';
import 'package:collegeapplication/screens/student/document_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import '../../extensions/string_extension.dart';

class StudentHomeTab extends StatefulWidget {
  const StudentHomeTab({super.key});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Documents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _startDocumentScan,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Document'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('uploadedByUserId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
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
                  );
                }

                final documents = snapshot.data!.docs.map((doc) => Document.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(doc.name),
                        subtitle: Text('Status: ${doc.status.name.capitalize()}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocumentDetailScreen(document: doc),
                            ),
                          );
                        },
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
  }

  Future<void> _startDocumentScan() async {
    final DocumentScannerOptions options = DocumentScannerOptions(
      mode: ScannerMode.full,
      isGalleryImportAllowed: true,
      pageLimit: 5,
    );

    final DocumentScanner documentScanner = DocumentScanner(options: options);

    try {
      final DocumentScanResult result = await documentScanner.scanDocument();

      final Directory tempDir = await getTemporaryDirectory();
      for (final photo in result.images) {
        final File imageFile = File(photo);
        // Here you can save the file to local storage or upload it to a server
        // For now, let's just print the path
        print('Scanned document saved at: ${imageFile.path}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documents scanned successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning document: $e'),
        ),
      );
    }
  }
}
