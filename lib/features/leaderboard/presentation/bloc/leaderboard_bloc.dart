import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase _getLeaderboard;

  LeaderboardBloc({required GetLeaderboardUseCase getLeaderboard})
      : _getLeaderboard = getLeaderboard,
        super(const LeaderboardInitial()) {
    on<LoadLeaderboardEvent>(_onLoad);
    on<FilterLeaderboardEvent>(_onFilter);
    on<RefreshLeaderboardEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final entries = await _getLeaderboard(limit: 50);
      emit(LeaderboardLoaded(entries: entries));
    } catch (e) {
      emit(LeaderboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFilter(
    FilterLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final entries = await _getLeaderboard(
        period: event.period,
        specialtyFilter: event.specialty,
        limit: 50,
      );
      emit(LeaderboardLoaded(
        entries: entries,
        activePeriod: event.period,
        activeSpecialty: event.specialty,
      ));
    } catch (e) {
      emit(LeaderboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(
    RefreshLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (state is LeaderboardLoaded) {
      final current = state as LeaderboardLoaded;
      try {
        final entries = await _getLeaderboard(
          period: current.activePeriod,
          specialtyFilter: current.activeSpecialty,
          limit: 50,
        );
        emit(current.copyWith(entries: entries));
      } catch (_) {
        // silently fail refresh
      }
    } else {
      add(const LoadLeaderboardEvent());
    }
  }
}
