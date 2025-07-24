import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../models/document.dart';
import '../../widgets/document_card.dart';
import '../../widgets/message_box.dart';

class FacultyVerifyTab extends StatefulWidget {
  const FacultyVerifyTab({super.key});

  @override
  State<FacultyVerifyTab> createState() => _FacultyVerifyTabState();
}

class _FacultyVerifyTabState extends State<FacultyVerifyTab> {
  String? _selectedCategoryFilter;
  DocumentStatus? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showVerificationModal(BuildContext context, Document doc, AppState appState) {
    final TextEditingController commentsController = TextEditingController(text: doc.comments);
    final currentUser = appState.currentUser;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text(
            'Verify Document',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document: ${doc.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Category: ${doc.category}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Uploaded By: ${appState.users.firstWhere((user) => user.id == doc.uploadedByUserId).name}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Current Status: ${doc.status.toString().split('.').last.capitalize()}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Comments (Optional)',
                    hintText: 'Add comments for verification...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.updateDocumentStatus(doc.id, DocumentStatus.approved,
                          comments: commentsController.text, verifiedByUserId: currentUser?.id);
                      Navigator.of(context).pop();
                      showMessageBox(context, 'Success', 'Document approved.');
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.updateDocumentStatus(doc.id, DocumentStatus.rejected,
                          comments: commentsController.text, verifiedByUserId: currentUser?.id);
                      Navigator.of(context).pop();
                      showMessageBox(context, 'Success', 'Document rejected.');
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final allDocuments = appState.documents;

        final filteredDocuments = allDocuments.where((doc) {
          final matchesCategory = _selectedCategoryFilter == null || doc.category == _selectedCategoryFilter;
          final matchesStatus = _selectedStatusFilter == null || doc.status == _selectedStatusFilter;
          final matchesSearch = _searchText.isEmpty ||
              doc.name.toLowerCase().contains(_searchText.toLowerCase()) ||
              appState.users.firstWhere((user) => user.id == doc.uploadedByUserId).name.toLowerCase().contains(_searchText.toLowerCase()) ||
              doc.id.toLowerCase().contains(_searchText.toLowerCase()); // Search by ID

          return matchesCategory && matchesStatus && matchesSearch;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Documents',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Search and Filter
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Name or Student ID',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      hint: const Text('All Categories'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...appState.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryFilter = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<DocumentStatus>(
                      value: _selectedStatusFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      hint: const Text('All Statuses'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Statuses')),
                        ...DocumentStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last.capitalize()),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusFilter = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: filteredDocuments.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No documents found matching criteria.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocuments[index];
                    final uploadedBy = appState.users.firstWhere((user) => user.id == doc.uploadedByUserId).name;
                    return DocumentCard(
                      document: doc,
                      subtitle: 'Uploaded by: $uploadedBy on ${doc.uploadedDate}',
                      trailing: ElevatedButton(
                        onPressed: () => _showVerificationModal(context, doc, appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text('Review'),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}