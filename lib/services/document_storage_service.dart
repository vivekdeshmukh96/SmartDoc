import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/document_model.dart';

class DocumentStorageService {
  static const _documentsKey = 'documents';

  Future<Directory> get _documentsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(path.join(appDir.path, 'documents'));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir;
  }

  Future<List<Document>> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getStringList(_documentsKey) ?? [];
    return documentsJson
        .map((docJson) => Document.fromJson(docJson))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveDocument(String tempPath) async {
    final docsDir = await _documentsDir;
    final fileName = '${const Uuid().v4()}.jpg';
    final newPath = path.join(docsDir.path, fileName);

    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.copy(newPath);
    }

    final document = Document(
      id: const Uuid().v4(),
      filePath: newPath,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final documents = await getDocuments();
    documents.add(document);

    await prefs.setStringList(
      _documentsKey,
      documents.map((doc) => doc.toJson()).toList(),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await getDocuments();

    final docToDelete = documents.firstWhere((doc) => doc.id == documentId);
    final file = File(docToDelete.filePath);

    if (await file.exists()) {
      await file.delete();
    }

    documents.removeWhere((doc) => doc.id == documentId);

    await prefs.setStringList(
      _documentsKey,
      documents.map((doc) => doc.toJson()).toList(),
    );
  }
}
