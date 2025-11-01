import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload resume file
  Future<String> uploadResume(String userId, String fileName, File file) async {
    try {
      final String path = 'users/$userId/resumes/$fileName';
      final Reference ref = _storage.ref().child(path);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading resume: $e');
      rethrow;
    }
  }

  // Delete resume file
  Future<void> deleteResume(String userId, String fileName) async {
    try {
      final String path = 'users/$userId/resumes/$fileName';
      final Reference ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting resume: $e');
      rethrow;
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  // Delete all user files
  Future<void> deleteUserFiles(String userId) async {
    try {
      final Reference ref = _storage.ref().child('users/$userId');
      final ListResult result = await ref.listAll();

      // Delete all files
      for (var item in result.items) {
        await item.delete();
      }

      // Recursively delete all subdirectories
      for (var prefix in result.prefixes) {
        await _deleteDirectory(prefix);
      }
    } catch (e) {
      print('Error deleting user files: $e');
      rethrow;
    }
  }

  // Helper method to recursively delete directories
  Future<void> _deleteDirectory(Reference ref) async {
    final ListResult result = await ref.listAll();

    for (var item in result.items) {
      await item.delete();
    }

    for (var prefix in result.prefixes) {
      await _deleteDirectory(prefix);
    }
  }
}
