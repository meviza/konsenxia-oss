import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medical_report_entity.dart';
import '../repositories/reports_repository.dart';

class UploadReportUseCase
    implements UseCase<MedicalReportEntity, UploadReportParams> {
  final ReportsRepository repository;
  const UploadReportUseCase(this.repository);

  @override
  Future<MedicalReportEntity> call(UploadReportParams params) =>
      repository.uploadReport(
        title: params.title,
        summary: params.summary,
        detail: params.detail,
        institution: params.institution,
        type: params.type,
        date: params.date,
        isAbnormal: params.isAbnormal,
        fileUrl: params.fileUrl,
      );
}

class UploadReportParams extends Equatable {
  final String title;
  final String summary;
  final String detail;
  final String institution;
  final ReportType type;
  final DateTime date;
  final bool isAbnormal;
  final String? fileUrl;

  const UploadReportParams({
    required this.title,
    required this.summary,
    required this.detail,
    required this.institution,
    required this.type,
    required this.date,
    required this.isAbnormal,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [title, summary, detail, institution, type, date, isAbnormal, fileUrl];
}
