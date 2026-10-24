import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoad);
    on<RefreshAnalyticsEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    try {
      final data = await _repository.getAnalytics();
      emit(AnalyticsLoaded(data: data));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(
    RefreshAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final data = await _repository.getAnalytics();
      emit(AnalyticsLoaded(data: data));
    } catch (e) {
      emit(AnalyticsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
