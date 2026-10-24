import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_report_entity.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final List<MedicalReportEntity> reports;
  final int selectedYear;

  const ReportsLoaded({
    required this.reports,
    required this.selectedYear,
  });

  ReportsLoaded copyWith({
    List<MedicalReportEntity>? reports,
    int? selectedYear,
  }) =>
      ReportsLoaded(
        reports: reports ?? this.reports,
        selectedYear: selectedYear ?? this.selectedYear,
      );

  @override
  List<Object?> get props => [reports, selectedYear];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}
