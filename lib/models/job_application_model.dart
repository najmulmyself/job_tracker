enum ApplicationStage {
  interested,
  applied,
  interviewCalled,
  interviewed,
  offer,
  rejected,
}

enum JobSource {
  linkedin,
  indeed,
  email,
  referral,
  companyWebsite,
  wellfound,
  remoteOk,
  other,
}

class JobApplicationModel {
  final String id;
  final String userId;
  final String companyName;
  final String jobTitle;
  final JobSource source;
  final String? salaryRange;
  final String? expectedSalary;
  final String jobDescription;
  final ApplicationStage stage;
  final DateTime? applicationDate;
  final DateTime? deadline;
  final String? resumeId;
  final String notes;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Interview call tracking
  final DateTime? interviewCallDate;
  final String? interviewCallNotes;
  final DateTime? interviewScheduledDate;
  final String? interviewType; // phone, video, in-person
  final bool interviewReminderEnabled;

  JobApplicationModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.jobTitle,
    required this.source,
    this.salaryRange,
    this.expectedSalary,
    required this.jobDescription,
    required this.stage,
    this.applicationDate,
    this.deadline,
    this.resumeId,
    this.notes = '',
    this.isDraft = false,
    required this.createdAt,
    required this.updatedAt,
    this.interviewCallDate,
    this.interviewCallNotes,
    this.interviewScheduledDate,
    this.interviewType,
    this.interviewReminderEnabled = false,
  });

  // Helper method to parse stage with backward compatibility
  static ApplicationStage _parseStage(String stageStr) {
    // Handle old "interview" stage by converting to "interviewCalled"
    if (stageStr == 'interview') {
      return ApplicationStage.interviewCalled;
    }

    return ApplicationStage.values.firstWhere(
      (e) => e.toString() == 'ApplicationStage.$stageStr',
      orElse: () => ApplicationStage.interested,
    );
  }

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyName: json['companyName'] as String,
      jobTitle: json['jobTitle'] as String,
      source: JobSource.values.firstWhere(
        (e) => e.toString() == 'JobSource.${json['source']}',
        orElse: () => JobSource.other,
      ),
      salaryRange: json['salaryRange'] as String?,
      expectedSalary: json['expectedSalary'] as String?,
      jobDescription: json['jobDescription'] as String,
      stage: _parseStage(json['stage'] as String),
      applicationDate: json['applicationDate'] != null
          ? DateTime.parse(json['applicationDate'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      resumeId: json['resumeId'] as String?,
      notes: json['notes'] as String? ?? '',
      isDraft: json['isDraft'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      interviewCallDate: json['interviewCallDate'] != null
          ? DateTime.parse(json['interviewCallDate'] as String)
          : null,
      interviewCallNotes: json['interviewCallNotes'] as String?,
      interviewScheduledDate: json['interviewScheduledDate'] != null
          ? DateTime.parse(json['interviewScheduledDate'] as String)
          : null,
      interviewType: json['interviewType'] as String?,
      interviewReminderEnabled:
          json['interviewReminderEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'source': source.toString().split('.').last,
      'salaryRange': salaryRange,
      'expectedSalary': expectedSalary,
      'jobDescription': jobDescription,
      'stage': stage.toString().split('.').last,
      'applicationDate': applicationDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'resumeId': resumeId,
      'notes': notes,
      'isDraft': isDraft,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'interviewCallDate': interviewCallDate?.toIso8601String(),
      'interviewCallNotes': interviewCallNotes,
      'interviewScheduledDate': interviewScheduledDate?.toIso8601String(),
      'interviewType': interviewType,
      'interviewReminderEnabled': interviewReminderEnabled,
    };
  }

  JobApplicationModel copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? jobTitle,
    JobSource? source,
    String? salaryRange,
    String? expectedSalary,
    String? jobDescription,
    ApplicationStage? stage,
    DateTime? applicationDate,
    DateTime? deadline,
    String? resumeId,
    String? notes,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? interviewCallDate,
    String? interviewCallNotes,
    DateTime? interviewScheduledDate,
    String? interviewType,
    bool? interviewReminderEnabled,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      source: source ?? this.source,
      salaryRange: salaryRange ?? this.salaryRange,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      jobDescription: jobDescription ?? this.jobDescription,
      stage: stage ?? this.stage,
      applicationDate: applicationDate ?? this.applicationDate,
      deadline: deadline ?? this.deadline,
      resumeId: resumeId ?? this.resumeId,
      notes: notes ?? this.notes,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      interviewCallDate: interviewCallDate ?? this.interviewCallDate,
      interviewCallNotes: interviewCallNotes ?? this.interviewCallNotes,
      interviewScheduledDate:
          interviewScheduledDate ?? this.interviewScheduledDate,
      interviewType: interviewType ?? this.interviewType,
      interviewReminderEnabled:
          interviewReminderEnabled ?? this.interviewReminderEnabled,
    );
  }
}

// Extension for UI display
extension ApplicationStageExtension on ApplicationStage {
  String get displayName {
    switch (this) {
      case ApplicationStage.interested:
        return 'Interested';
      case ApplicationStage.applied:
        return 'Applied';
      case ApplicationStage.interviewCalled:
        return 'Interview Called';
      case ApplicationStage.interviewed:
        return 'Interviewed';
      case ApplicationStage.offer:
        return 'Offer';
      case ApplicationStage.rejected:
        return 'Rejected';
    }
  }
}

extension JobSourceExtension on JobSource {
  String get displayName {
    switch (this) {
      case JobSource.linkedin:
        return 'LinkedIn';
      case JobSource.indeed:
        return 'Indeed';
      case JobSource.email:
        return 'Email';
      case JobSource.referral:
        return 'Referral';
      case JobSource.companyWebsite:
        return 'Company Website';
      case JobSource.wellfound:
        return 'Wellfound';
      case JobSource.remoteOk:
        return 'RemoteOK';
      case JobSource.other:
        return 'Other';
    }
  }
}
