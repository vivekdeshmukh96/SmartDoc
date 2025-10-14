import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadFile(File file, String name) async {
    final String path = '/documents/${_client.auth.currentUser!.id}/$name';
    await _client.storage.from('documents').upload(path, file);
    return _client.storage.from('documents').getPublicUrl(path);
  }
}
