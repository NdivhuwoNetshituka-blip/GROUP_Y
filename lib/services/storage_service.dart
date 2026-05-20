// storage_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Upload a file (from a local path) and return a signed URL
  Future<String> uploadFile(String bucket, String path, String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'uploadFile(path) is not supported on web. Use uploadBytes instead.',
      );
    }

    final file = File(filePath);
    await _client.storage
        .from(bucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    // ✅ Return signed URL instead of public URL (for private buckets)
    return _client.storage.from(bucket).createSignedUrl(path, 3600);
  }

  /// Upload raw bytes and return a signed URL. Works on every platform.
  Future<String> uploadBytes(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
  }) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    // ✅ Return signed URL instead of public URL (for private buckets)
    return _client.storage.from(bucket).createSignedUrl(path, 3600);
  }

  /// Delete a file from a storage bucket
  Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  /// Get a signed URL for an existing file
  Future<String> getSignedUrl(String bucket, String path) async {
    return _client.storage.from(bucket).createSignedUrl(path, 3600);
  }
}
