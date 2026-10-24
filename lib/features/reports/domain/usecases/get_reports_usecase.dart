import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medical_report_entity.dart';
import '../repositories/reports_repository.dart';

class GetReportsUseCase implements UseCase<List<MedicalReportEntity>, GetReportsParams> {
  final ReportsRepository repository;
  const GetReportsUseCase(this.repository);

  @override
  Future<List<MedicalReportEntity>> call(GetReportsParams params) =>
      repository.getReports(year: params.year);
}

class GetReportsParams extends Equatable {
  final int? year;
  const GetReportsParams({this.year});
  @override
  List<Object?> get props => [year];
}
