import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class MedicalFile extends Equatable {
  final String id;
  final String originalName;
  final String fileName;
  final String mimeType;
  final int size;
  final FileCategory category;
  final String? thumbnailUrl;
  final String fileUrl;
  final int? width;
  final int? height;
  final String? notes;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? caseId;

  const MedicalFile({
    required this.id,
    required this.originalName,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.category,
    this.thumbnailUrl,
    required this.fileUrl,
    this.width,
    this.height,
    this.notes,
    required this.uploadedBy,
    required this.uploadedAt,
    this.caseId,
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';

  String get sizeText {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [id];
}

enum FileCategory {
  labResult('Laboratuvar', 'lab_result'),
  xray('Rontgen', 'xray'),
  ct('BT (Tomografi)', 'ct'),
  mri('MR', 'mri'),
  ultrasound('Ultrason', 'ultrasound'),
  ecg('EKG', 'ecg'),
  pathology('Patoloji', 'pathology'),
  other('Diger', 'other');

  final String label;
  final String apiValue;
  const FileCategory(this.label, this.apiValue);

  static FileCategory fromApi(String value) {
    return FileCategory.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => FileCategory.other,
    );
  }

  IconData get icon {
    switch (this) {
      case FileCategory.labResult:
        return Icons.science_rounded;
      case FileCategory.xray:
        return Icons.radio_button_checked;
      case FileCategory.ct:
        return Icons.view_in_ar_rounded;
      case FileCategory.mri:
        return Icons.blur_circular_rounded;
      case FileCategory.ultrasound:
        return Icons.waves_rounded;
      case FileCategory.ecg:
        return Icons.monitor_heart_rounded;
      case FileCategory.pathology:
        return Icons.biotech_rounded;
      case FileCategory.other:
        return Icons.attach_file_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FileCategory.labResult:
        return const Color(0xFF00C4B0);
      case FileCategory.xray:
        return const Color(0xFF3B82F6);
      case FileCategory.ct:
        return const Color(0xFF60A5FA);
      case FileCategory.mri:
        return const Color(0xFFA78BFA);
      case FileCategory.ultrasound:
        return const Color(0xFF34D399);
      case FileCategory.ecg:
        return const Color(0xFFEF4444);
      case FileCategory.pathology:
        return const Color(0xFFF59E0B);
      case FileCategory.other:
        return const Color(0xFF94A3B8);
    }
  }
}
