import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportsUseCase _getReports;

  ReportsBloc({required GetReportsUseCase getReports})
      : _getReports = getReports,
        super(const ReportsInitial()) {
    on<LoadReportsEvent>(_onLoad);
    on<ChangeReportsYearEvent>(_onChangeYear);
  }

  Future<void> _onLoad(
      LoadReportsEvent event, Emitter<ReportsState> emit) async {
    emit(const ReportsLoading());
    try {
      final year = event.year ?? DateTime.now().year;
      final reports = await _getReports(GetReportsParams(year: year));
      emit(ReportsLoaded(reports: reports, selectedYear: year));
    } on ReportException catch (e) {
      emit(ReportsError(e.message));
    }
  }

  Future<void> _onChangeYear(
      ChangeReportsYearEvent event, Emitter<ReportsState> emit) async {
    emit(const ReportsLoading());
    try {
      final reports = await _getReports(GetReportsParams(year: event.year));
      emit(ReportsLoaded(reports: reports, selectedYear: event.year));
    } on ReportException catch (e) {
      emit(ReportsError(e.message));
    }
  }
}
