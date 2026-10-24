import '../entities/medical_report_entity.dart';

class ReportException implements Exception {
  final String message;
  const ReportException(this.message);
  @override
  String toString() => 'ReportException: $message';
}

abstract interface class ReportsRepository {
  Future<List<MedicalReportEntity>> getReports({int? year});
  Future<MedicalReportEntity> getReportById(String reportId);
  Future<MedicalReportEntity> uploadReport({
    required String title,
    required String summary,
    required String detail,
    required String institution,
    required ReportType type,
    required DateTime date,
    required bool isAbnormal,
    String? fileUrl,
  });
}
