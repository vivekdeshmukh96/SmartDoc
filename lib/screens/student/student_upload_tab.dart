import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:collegeapplication/app_state.dart';
import 'package:collegeapplication/widgets/message_box.dart';

class StudentUploadTab extends StatefulWidget {
  const StudentUploadTab({super.key});

  @override
  State<StudentUploadTab> createState() => _StudentUploadTabState();
}

class _StudentUploadTabState extends State<StudentUploadTab> {
  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _extractedDateController = TextEditingController();
  String? _selectedCategory;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _extractedData;
  bool _isUploading = false;
  bool _isAILoading = false;
  String _aiStatusMessage = 'Scan or pick a document to start.';

  @override
  void dispose() {
    _docNameController.dispose();
    _extractedDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _extractedData = null;
        _aiStatusMessage = 'Image selected. Analyzing document...';
      });
      await _analyzeDocumentWithAI();
    }
  }

  Future<void> _analyzeDocumentWithAI() async {
    if (_imageBytes == null) return;

    setState(() {
      _isAILoading = true;
      _aiStatusMessage = 'AI performing V-OCR and categorization...';
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.getDocumentAnalysis(_imageBytes!);

      if (result != null) {
        setState(() {
          _extractedData = result;
          _docNameController.text = result['extractedName'] ?? 'Untitled Document';
          _extractedDateController.text = result['extractedDate'] ?? '';

          final suggestedCat = result['suggestedCategory'];
          if (appState.categories.contains(suggestedCat)) {
            _selectedCategory = suggestedCat;
            _aiStatusMessage = 'Analysis complete. Fields pre-filled. Confidence: ${(result['confidenceScore'] * 100).toStringAsFixed(0)}%';
          } else {
            _selectedCategory = null;
            _aiStatusMessage = 'AI suggested "$suggestedCat" (not in list). Please verify and select a category.';
          }
        });
      } else {
        setState(() {
          _aiStatusMessage = 'AI analysis failed or returned no data.';
        });
      }
    } catch (e) {
      debugPrint('Error during AI analysis: $e');
      setState(() {
        _aiStatusMessage = 'AI Error: Failed to process document. Please try again.';
      });
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  void _handleUpload() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      showMessageBox(context, 'Error', 'User not logged in.');
      return;
    }

    if (_docNameController.text.isEmpty || _selectedCategory == null || _imageBytes == null) {
      showMessageBox(context, 'Error', 'Please ensure document name, category, and image are provided.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final finalExtractedData = {
        ...?_extractedData,
        'finalName': _docNameController.text,
        'finalDate': _extractedDateController.text,
      };

      await appState.addDocument(
        _docNameController.text,
        _selectedCategory!,
        currentUser.id,
        _imageBytes!,
        finalExtractedData,
      );

      _docNameController.clear();
      _extractedDateController.clear();
      setState(() {
        _selectedCategory = null;
        _imageBytes = null;
        _extractedData = null;
        _aiStatusMessage = 'Document uploaded successfully!';
      });
      showMessageBox(context, 'Success', 'Document uploaded successfully and is pending verification.');
    } catch (e) {
      showMessageBox(context, 'Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
                'Upload & AI Categorization',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Image Picker Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
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
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick from Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Image Preview & AI Status
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _imageBytes != null ? Colors.blueAccent : Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: _isAILoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 3),
                      const SizedBox(height: 10),
                      Text(_aiStatusMessage, style: TextStyle(color: Colors.blueGrey)),
                    ],
                  ),
                )
                    : (_imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(_aiStatusMessage, style: TextStyle(color: Colors.grey[600])),
                  ],
                )),
              ),

              // Form Fields (editable by student, pre-filled by AI)
              Text(
                'Document Details (Verify AI Input):',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _docNameController,
                decoration: const InputDecoration(
                  labelText: 'Document Name (AI Extracted)',
                  hintText: 'e.g., Degree Certificate',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _extractedDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Primary Date (AI Extracted)',
                  hintText: 'e.g., 10/05/2023',
                  prefixIcon: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category (AI Suggested)',
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

              // Upload Button
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _imageBytes != null && !_isAILoading ? _handleUpload : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Submit Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
