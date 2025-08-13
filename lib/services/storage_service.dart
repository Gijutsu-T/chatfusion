import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import './supabase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  final _uuid = Uuid();

  // Upload avatar image
  Future<String> uploadAvatar(XFile imageFile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$userId/avatar.${fileExtension}';

      final file = File(imageFile.path);
      await _client.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (error) {
      throw Exception('Avatar upload failed: $error');
    }
  }

  // Upload chat file
  Future<Map<String, dynamic>> uploadChatFile(File file, String chatId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '$chatId/${_uuid.v4()}.$fileExtension';

      await _client.storage.from('chat-files').upload(uniqueFileName, file);

      final publicUrl =
          _client.storage.from('chat-files').getPublicUrl(uniqueFileName);

      final fileStats = await file.stat();

      return {
        'file_url': publicUrl,
        'bucket_id': 'chat-files',
 'bucket_id': 'chat-files',
        'file_name': fileName,
        'file_size': fileStats.size,
        'file_type': _getFileType(fileExtension),
        'storage_path': uniqueFileName,
      };
    } catch (error) {
      throw Exception('File upload failed: $error');
    }
  }

  // Upload voice message
  Future<Map<String, dynamic>> uploadVoiceMessage(
      File audioFile, String chatId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = audioFile.path.split('/').last;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '$chatId/voice_${_uuid.v4()}.$fileExtension';

      await _client.storage
          .from('voice-messages')
          .upload(uniqueFileName, audioFile);

      final publicUrl =
          _client.storage.from('voice-messages').getPublicUrl(uniqueFileName);

      final fileStats = await audioFile.stat();

      return {
        'file_url': publicUrl,
        'bucket_id': 'voice-messages',
        'file_name': 'Voice Message',
        'file_size': fileStats.size,
        'file_type': 'voice',
        'storage_path': uniqueFileName,
      };
    } catch (error) {
      throw Exception('Voice message upload failed: $error');
    }
  }

  // Pick and upload image
  Future<Map<String, dynamic>?> pickAndUploadImage(String chatId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      return await uploadChatFile(file, chatId);
    } catch (error) {
      throw Exception('Image picker failed: $error');
    }
  }

  // Pick and upload file
  Future<Map<String, dynamic>?> pickAndUploadFile(String chatId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'ppt', 'pptx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.first.path!);
      return await uploadChatFile(file, chatId);
    } catch (error) {
      throw Exception('File picker failed: $error');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (error) {
      throw Exception('File deletion failed: $error');
    }
  }

  // Download file
  Future<Uint8List> downloadFile(String bucket, String path) async {
    try {
      return await _client.storage.from(bucket).download(path);
    } catch (error) {
      throw Exception('File download failed: $error');
    }
  }

  // Get file public URL
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // Helper method to determine file type
  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'ogg':
        return 'audio';
      case 'pdf':
        return 'document';
      case 'doc':
      case 'docx':
        return 'document';
      case 'xls':
      case 'xlsx':
        return 'document';
      case 'ppt':
      case 'pptx':
        return 'document';
      default:
        return 'file';
    }
  }
}
