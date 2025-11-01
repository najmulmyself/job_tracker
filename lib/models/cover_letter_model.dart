enum CoverLetterStatus { draft, generated, submitted }

class CoverLetterModel {
  final String id;
  final String userId;
  final String jobApplicationId;
  final String content;
  final CoverLetterStatus status;
  final bool isAiGenerated;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoverLetterModel({
    required this.id,
    required this.userId,
    required this.jobApplicationId,
    required this.content,
    required this.status,
    this.isAiGenerated = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoverLetterModel.fromJson(Map<String, dynamic> json) {
    return CoverLetterModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobApplicationId: json['jobApplicationId'] as String,
      content: json['content'] as String,
      status: CoverLetterStatus.values.firstWhere(
        (e) => e.toString() == 'CoverLetterStatus.${json['status']}',
        orElse: () => CoverLetterStatus.draft,
      ),
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'jobApplicationId': jobApplicationId,
      'content': content,
      'status': status.toString().split('.').last,
      'isAiGenerated': isAiGenerated,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CoverLetterModel copyWith({
    String? id,
    String? userId,
    String? jobApplicationId,
    String? content,
    CoverLetterStatus? status,
    bool? isAiGenerated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CoverLetterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobApplicationId: jobApplicationId ?? this.jobApplicationId,
      content: content ?? this.content,
      status: status ?? this.status,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension CoverLetterStatusExtension on CoverLetterStatus {
  String get displayName {
    switch (this) {
      case CoverLetterStatus.draft:
        return 'Draft';
      case CoverLetterStatus.generated:
        return 'Generated';
      case CoverLetterStatus.submitted:
        return 'Submitted';
    }
  }
}
