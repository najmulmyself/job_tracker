import 'package:flutter/material.dart';
import '../models/job_application_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class JobProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<JobApplicationModel> _jobs = [];
  List<JobApplicationModel> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  ApplicationStage? _filterStage;
  String _sortBy = 'updatedAt';
  bool _showDraftsOnly = false;

  List<JobApplicationModel> get jobs => _filteredJobs;
  List<JobApplicationModel> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ApplicationStage? get filterStage => _filterStage;
  String get sortBy => _sortBy;
  bool get showDraftsOnly => _showDraftsOnly;

  // Non-draft jobs for accurate statistics (interested stage is also treated as draft)
  List<JobApplicationModel> get _nonDraftJobs => _jobs
      .where((job) => !job.isDraft && job.stage != ApplicationStage.interested)
      .toList();

  int get totalJobs => _jobs.length;
  int get totalApplied => _nonDraftJobs.length;
  int get draftCount => _jobs.where((job) => job.isDraft).length;
  int get interestedCount => _nonDraftJobs
      .where((job) => job.stage == ApplicationStage.interested)
      .length;
  int get appliedCount => _nonDraftJobs
      .where((job) => job.stage == ApplicationStage.applied)
      .length;
  int get interviewCalledCount => _nonDraftJobs
      .where((job) => job.stage == ApplicationStage.interviewCalled)
      .length;
  int get interviewedCount => _nonDraftJobs
      .where((job) => job.stage == ApplicationStage.interviewed)
      .length;
  int get interviewCount => interviewCalledCount + interviewedCount;
  int get offerCount =>
      _nonDraftJobs.where((job) => job.stage == ApplicationStage.offer).length;
  int get rejectedCount => _nonDraftJobs
      .where((job) => job.stage == ApplicationStage.rejected)
      .length;

  /// Average days between applicationDate and interviewCallDate
  /// for jobs that have both dates set. Returns null if no data.
  double? get avgResponseDays {
    final jobsWithResponse = _nonDraftJobs.where(
      (job) => job.applicationDate != null && job.interviewCallDate != null,
    );
    if (jobsWithResponse.isEmpty) return null;

    final totalDays = jobsWithResponse.fold<double>(0, (sum, job) {
      return sum +
          job.interviewCallDate!.difference(job.applicationDate!).inDays.abs();
    });
    return totalDays / jobsWithResponse.length;
  }

  /// Interview rate: percentage of non-draft jobs that reached interview stage
  double get interviewRate {
    if (totalApplied == 0) return 0;
    return (interviewCount / totalApplied) * 100;
  }

  /// Offer rate: percentage of non-draft jobs that received offers
  double get offerRate {
    if (totalApplied == 0) return 0;
    return (offerCount / totalApplied) * 100;
  }

  /// Month-over-month growth percentage for non-draft jobs
  String get monthlyGrowth {
    final now = DateTime.now();
    final thisMonth = _nonDraftJobs.where(
      (job) =>
          job.createdAt.year == now.year && job.createdAt.month == now.month,
    );
    final lastMonth = _nonDraftJobs.where((job) {
      final lm = DateTime(now.year, now.month - 1);
      return job.createdAt.year == lm.year && job.createdAt.month == lm.month;
    });

    if (lastMonth.isEmpty) {
      return thisMonth.isEmpty ? '0%' : '+${thisMonth.length}';
    }
    final change =
        ((thisMonth.length - lastMonth.length) / lastMonth.length * 100);
    if (change >= 0) return '+${change.toStringAsFixed(0)}%';
    return '${change.toStringAsFixed(0)}%';
  }

  void listenToJobs(String userId) {
    _firestoreService
        .getJobApplicationsStream(userId)
        .listen(
          (jobs) {
            _jobs = jobs;
            _applyFiltersAndSort();
            notifyListeners();
          },
          onError: (e) {
            _error = 'Failed to sync jobs: $e';
            notifyListeners();
          },
        );
  }

  Future<void> loadJobs(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _jobs = await _firestoreService.getJobApplications(userId);
      _applyFiltersAndSort();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJob(JobApplicationModel job) async {
    try {
      await _firestoreService.createJobApplication(job);

      // Schedule notification if deadline is set and not a draft
      if (!job.isDraft && job.deadline != null) {
        await _notificationService.scheduleDeadlineReminder(
          id: job.id.hashCode,
          companyName: job.companyName,
          jobTitle: job.jobTitle,
          deadline: job.deadline!,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateJob(JobApplicationModel job) async {
    try {
      await _firestoreService.updateJobApplication(job);

      // Update notification if deadline changed
      if (!job.isDraft && job.deadline != null) {
        await _notificationService.cancelNotification(job.id.hashCode);
        await _notificationService.scheduleDeadlineReminder(
          id: job.id.hashCode,
          companyName: job.companyName,
          jobTitle: job.jobTitle,
          deadline: job.deadline!,
        );
      } else {
        await _notificationService.cancelNotification(job.id.hashCode);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteJob(String userId, String jobId) async {
    try {
      await _firestoreService.deleteJobApplication(userId, jobId);
      await _notificationService.cancelNotification(jobId.hashCode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<JobApplicationModel?> getJob(String userId, String jobId) async {
    try {
      return await _firestoreService.getJobApplication(userId, jobId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Auto-save draft
  Future<void> saveDraft(JobApplicationModel job) async {
    try {
      final draftJob = job.copyWith(isDraft: true, updatedAt: DateTime.now());

      if (_jobs.any((j) => j.id == job.id)) {
        await updateJob(draftJob);
      } else {
        await createJob(draftJob);
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // Filter and sort
  void setFilterStage(ApplicationStage? stage) {
    _filterStage = stage;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleDraftsOnly() {
    _showDraftsOnly = !_showDraftsOnly;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _filterStage = null;
    _showDraftsOnly = false;
    _sortBy = 'updatedAt';
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    _filteredJobs = List.from(_jobs);

    // Apply stage filter
    if (_filterStage != null) {
      _filteredJobs = _filteredJobs
          .where((job) => job.stage == _filterStage)
          .toList();
    }

    // Apply draft filter (only interested stage counts as draft)
    if (_showDraftsOnly) {
      _filteredJobs = _filteredJobs
          .where((job) => job.stage == ApplicationStage.interested)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'updatedAt':
        _filteredJobs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'createdAt':
        _filteredJobs.sort((a, b) {
          final aDate = a.applicationDate ?? a.createdAt;
          final bDate = b.applicationDate ?? b.createdAt;
          return bDate.compareTo(aDate);
        });
        break;
      case 'deadline':
        _filteredJobs.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case 'company':
        _filteredJobs.sort((a, b) => a.companyName.compareTo(b.companyName));
        break;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
