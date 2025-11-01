import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/job_application_model.dart';
import '../models/resume_model.dart';
import '../models/cover_letter_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }

  // ============ USER OPERATIONS ============

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(user.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteUserData(String uid) async {
    // Delete all user's job applications
    final jobsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('jobs')
        .get();

    for (var doc in jobsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all user's resumes
    final resumesSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('resumes')
        .get();

    for (var doc in resumesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete user document
    await _firestore.collection('users').doc(uid).delete();
  }

  // ============ JOB APPLICATION OPERATIONS ============

  Future<void> createJobApplication(JobApplicationModel job) async {
    await _firestore
        .collection('users')
        .doc(job.userId)
        .collection('jobs')
        .doc(job.id)
        .set(job.toJson());
  }

  Future<JobApplicationModel?> getJobApplication(
    String userId,
    String jobId,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobId)
        .get();

    if (doc.exists) {
      return JobApplicationModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<List<JobApplicationModel>> getJobApplicationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JobApplicationModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<List<JobApplicationModel>> getJobApplications(
    String userId, {
    ApplicationStage? stage,
    bool? isDraft,
  }) async {
    Query query = _firestore.collection('users').doc(userId).collection('jobs');

    if (stage != null) {
      query = query.where('stage', isEqualTo: stage.toString().split('.').last);
    }

    if (isDraft != null) {
      query = query.where('isDraft', isEqualTo: isDraft);
    }

    final snapshot = await query.orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map(
          (doc) =>
              JobApplicationModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> updateJobApplication(JobApplicationModel job) async {
    await _firestore
        .collection('users')
        .doc(job.userId)
        .collection('jobs')
        .doc(job.id)
        .update(job.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteJobApplication(String userId, String jobId) async {
    // Delete associated cover letters
    final coverLettersSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobId)
        .collection('coverLetters')
        .get();

    for (var doc in coverLettersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete job application
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobId)
        .delete();
  }

  // ============ RESUME OPERATIONS ============

  Future<void> createResume(ResumeModel resume) async {
    await _firestore
        .collection('users')
        .doc(resume.userId)
        .collection('resumes')
        .doc(resume.id)
        .set(resume.toJson());
  }

  Future<List<ResumeModel>> getResumes(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ResumeModel.fromJson(doc.data()))
        .toList();
  }

  Stream<List<ResumeModel>> getResumesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ResumeModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> updateResume(ResumeModel resume) async {
    await _firestore
        .collection('users')
        .doc(resume.userId)
        .collection('resumes')
        .doc(resume.id)
        .update(resume.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteResume(String userId, String resumeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('resumes')
        .doc(resumeId)
        .delete();
  }

  // Set default resume
  Future<void> setDefaultResume(String userId, String resumeId) async {
    // Get all resumes
    final resumes = await getResumes(userId);

    // Update all resumes to not be default
    for (var resume in resumes) {
      await updateResume(resume.copyWith(isDefault: false));
    }

    // Set the selected resume as default
    final selectedResume = resumes.firstWhere((r) => r.id == resumeId);
    await updateResume(selectedResume.copyWith(isDefault: true));

    // Update user's default resume ID
    await _firestore.collection('users').doc(userId).update({
      'defaultResumeId': resumeId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ============ COVER LETTER OPERATIONS ============

  Future<void> createCoverLetter(CoverLetterModel coverLetter) async {
    await _firestore
        .collection('users')
        .doc(coverLetter.userId)
        .collection('jobs')
        .doc(coverLetter.jobApplicationId)
        .collection('coverLetters')
        .doc(coverLetter.id)
        .set(coverLetter.toJson());
  }

  Future<List<CoverLetterModel>> getCoverLetters(
    String userId,
    String jobApplicationId,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobApplicationId)
        .collection('coverLetters')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CoverLetterModel.fromJson(doc.data()))
        .toList();
  }

  Stream<List<CoverLetterModel>> getCoverLettersStream(
    String userId,
    String jobApplicationId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobApplicationId)
        .collection('coverLetters')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoverLetterModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> updateCoverLetter(CoverLetterModel coverLetter) async {
    await _firestore
        .collection('users')
        .doc(coverLetter.userId)
        .collection('jobs')
        .doc(coverLetter.jobApplicationId)
        .collection('coverLetters')
        .doc(coverLetter.id)
        .update(coverLetter.copyWith(updatedAt: DateTime.now()).toJson());
  }

  Future<void> deleteCoverLetter(
    String userId,
    String jobApplicationId,
    String coverLetterId,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('jobs')
        .doc(jobApplicationId)
        .collection('coverLetters')
        .doc(coverLetterId)
        .delete();
  }
}
