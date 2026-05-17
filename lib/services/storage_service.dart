import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Upload a file to a storage bucket
  Future<String> uploadFile(String bucket, String path, String filePath) async {
    final file = File(filePath);
    await _client.storage.from(bucket).upload(path, file);

    // Return the public URL
    final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  /// Delete a file from a storage bucket
  Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
