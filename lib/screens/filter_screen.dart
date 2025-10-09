import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class FilterScreen extends StatefulWidget {
  final File image;

  const FilterScreen({super.key, required this.image});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late File _image;
  File? _filteredImage;
  bool _isFiltering = false;

  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Filters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => Navigator.pop(context, _filteredImage ?? _image),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_filteredImage != null)
              Image.file(
                _filteredImage!,
                height: 300,
              )
            else
              Image.file(
                _image,
                height: 300,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyContrast,
                  child: const Text('Contrast'),
                ),
                ElevatedButton(
                  onPressed: _applyBrightness,
                  child: const Text('Brightness'),
                ),
                ElevatedButton(
                  onPressed: _applyGrayscale,
                  child: const Text('Grayscale'),
                ),
              ],
            ),
            if (_isFiltering)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyContrast() async {
    setState(() {
      _isFiltering = true;
    });
    final imageBytes = await _image.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      final filtered = img.contrast(image, contrast: 150);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/filtered.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(filtered));
      setState(() {
        _filteredImage = tempFile;
      });
    }
    setState(() {
      _isFiltering = false;
    });
  }

  Future<void> _applyBrightness() async {
    setState(() {
      _isFiltering = true;
    });
    final imageBytes = await _image.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      final filtered = img.adjustColor(image, brightness: 1.25);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/filtered.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(filtered));
      setState(() {
        _filteredImage = tempFile;
      });
    }
    setState(() {
      _isFiltering = false;
    });
  }

  Future<void> _applyGrayscale() async {
    setState(() {
      _isFiltering = true;
    });
    final imageBytes = await _image.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      final filtered = img.grayscale(image);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/filtered.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(filtered));
      setState(() {
        _filteredImage = tempFile;
      });
    }
    setState(() {
      _isFiltering = false;
    });
  }
}
