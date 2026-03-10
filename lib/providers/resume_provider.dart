import 'dart:io';
import 'package:flutter/material.dart';
import '../models/resume_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ResumeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<ResumeModel> _resumes = [];
  bool _isLoading = false;
  String? _error;

  List<ResumeModel> get resumes => _resumes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ResumeModel? get defaultResume =>
      _resumes.where((r) => r.isDefault).firstOrNull;

  void listenToResumes(String userId) {
    _firestoreService
        .getResumesStream(userId)
        .listen(
          (resumes) {
            _resumes = resumes;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Failed to sync resumes: $e';
            notifyListeners();
          },
        );
  }

  Future<void> loadResumes(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _resumes = await _firestoreService.getResumes(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadResume({
    required String userId,
    required String name,
    required File file,
    required String fileName,
    bool setAsDefault = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload file to Firebase Storage
      final fileUrl = await _storageService.uploadResume(
        userId,
        fileName,
        file,
      );

      // Get file size
      final fileSize = await file.length();

      // Create resume model
      final resume = ResumeModel(
        id: const Uuid().v4(),
        userId: userId,
        name: name,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSizeBytes: fileSize,
        isDefault: setAsDefault,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createResume(resume);

      // If set as default, update all other resumes
      if (setAsDefault) {
        await _firestoreService.setDefaultResume(userId, resume.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResume(String userId, String resumeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final resume = _resumes.firstWhere((r) => r.id == resumeId);

      // Delete from Storage
      await _storageService.deleteResume(userId, resume.fileName);

      // Delete from Firestore
      await _firestoreService.deleteResume(userId, resumeId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setDefaultResume(String userId, String resumeId) async {
    try {
      await _firestoreService.setDefaultResume(userId, resumeId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateResume(ResumeModel resume) async {
    try {
      await _firestoreService.updateResume(resume);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
