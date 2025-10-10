import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/message_box.dart';

class AdminCategoriesTab extends StatefulWidget {
  const AdminCategoriesTab({super.key});

  @override
  State<AdminCategoriesTab> createState() => _AdminCategoriesTabState();
}

class _AdminCategoriesTabState extends State<AdminCategoriesTab> {
  final TextEditingController _newCategoryController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _handleAddCategory() async {
    if (_newCategoryController.text.isEmpty) {
      if (!mounted) return;
      showMessageBox(context, 'Error', 'Category name cannot be empty.');
      return;
    }
    try {
      final categoryName = _newCategoryController.text;
      final querySnapshot = await _firestore.collection('categories').where('name', isEqualTo: categoryName).get();

      if (querySnapshot.docs.isNotEmpty) {
        if (!mounted) return;
        showMessageBox(context, 'Error', 'Category already exists.');
        return;
      }

      await _firestore.collection('categories').add({'name': categoryName});
      _newCategoryController.clear();
      if (!mounted) return;
      showMessageBox(context, 'Success', 'Category added successfully.');
    } catch (e) {
      if (!mounted) return;
      showMessageBox(context, 'Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'New Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _handleAddCategory,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['name']),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _firestore.collection('categories').doc(document.id).delete();
                          if (!mounted) return;
                          showMessageBox(context, 'Success', 'Category deleted successfully.');
                        } catch (e) {
                          if (!mounted) return;
                          showMessageBox(context, 'Error', e.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}