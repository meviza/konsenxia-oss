import 'package:equatable/equatable.dart';

class MedicalReportEntity extends Equatable {
  final String id;
  final DateTime date;
  final ReportType type;
  final String title;
  final String summary;
  final String detail;
  final String institution;
  final bool isAbnormal;
  final String? fileUrl;
  final DateTime createdAt;

  const MedicalReportEntity({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.summary,
    required this.detail,
    required this.institution,
    required this.isAbnormal,
    this.fileUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, date, type, title, summary, detail,
        institution, isAbnormal, fileUrl, createdAt,
      ];
}

enum ReportType {
  labResult,
  imaging,
  diagnosis,
  report,
  procedure,
  vaccination;

  String get label => switch (this) {
        ReportType.labResult   => 'Lab Sonucu',
        ReportType.imaging     => 'Görüntüleme',
        ReportType.diagnosis   => 'Tanı',
        ReportType.report      => 'Rapor',
        ReportType.procedure   => 'Girişim',
        ReportType.vaccination => 'Aşı',
      };

  static ReportType fromValue(String v) => switch (v) {
        'imaging'     => ReportType.imaging,
        'diagnosis'   => ReportType.diagnosis,
        'procedure'   => ReportType.procedure,
        'vaccination' => ReportType.vaccination,
        'report'      => ReportType.report,
        _             => ReportType.labResult,
      };
}
