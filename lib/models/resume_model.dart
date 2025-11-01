class ResumeModel {
  final String id;
  final String userId;
  final String name;
  final String fileUrl;
  final String fileName;
  final int fileSizeBytes;
  final bool isDefault;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  ResumeModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.fileUrl,
    required this.fileName,
    required this.fileSizeBytes,
    this.isDefault = false,
    required this.uploadedAt,
    required this.updatedAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'isDefault': isDefault,
      'uploadedAt': uploadedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ResumeModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? fileUrl,
    String? fileName,
    int? fileSizeBytes,
    bool? isDefault,
    DateTime? uploadedAt,
    DateTime? updatedAt,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isDefault: isDefault ?? this.isDefault,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
