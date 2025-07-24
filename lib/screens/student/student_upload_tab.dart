import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../../widgets/message_box.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  final TextEditingController _docNameController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _docNameController.dispose();
    super.dispose();
  }

  void _handleUpload() {
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      showMessageBox(context, 'Error', 'User not logged in.');
      return;
    }

    if (_docNameController.text.isEmpty || _selectedCategory == null) {
      showMessageBox(context, 'Error', 'Please enter document name and select a category.');
      return;
    }

    try {
      appState.addDocument(_docNameController.text, _selectedCategory!, currentUser.id);
      _docNameController.clear();
      setState(() {
        _selectedCategory = null;
      });
      showMessageBox(context, 'Success', 'Document uploaded successfully and is pending verification.');
    } catch (e) {
      showMessageBox(context, 'Error', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _handleScan() {
    showMessageBox(context, 'Scan Document', 'Simulating document scanning. In a real app, this would open the camera or gallery.');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload New Document',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _docNameController,
                decoration: const InputDecoration(
                  labelText: 'Document Name',
                  hintText: 'e.g., Degree Certificate',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                hint: const Text('Select a category'),
                items: appState.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleScan,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleUpload,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}