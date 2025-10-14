
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _documentBucket = 'Document Bucket';

  Future<String> uploadFile(File file, String name, String userId) async {
    final String path = 'documents/$userId/$name';
    await _client.storage.from(_documentBucket).upload(path, file);
    return _client.storage.from(_documentBucket).getPublicUrl(path);
  }

  Future<String> uploadProfilePhoto(File file, String fileName, String userId) async {
    final String path = 'profile_photos/$userId/$fileName';
    await _client.storage.from(_documentBucket).upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    return _client.storage.from(_documentBucket).getPublicUrl(path);
  }
}
