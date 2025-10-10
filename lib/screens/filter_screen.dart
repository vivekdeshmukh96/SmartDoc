import 'dart:io';
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final File image;
  const FilterScreen({super.key, required this.image});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // In a real implementation, you would apply filters to the image.
  // For now, we will just display the image and provide a button to confirm.
  // This screen is a placeholder for your custom filter logic.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // When the user is done, pop the screen and return the image file.
              Navigator.of(context).pop(widget.image);
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.file(widget.image),
        ),
      ),
    );
  }
}
