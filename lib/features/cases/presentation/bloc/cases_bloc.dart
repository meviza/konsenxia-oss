import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../../domain/usecases/get_cases_usecase.dart';
import '../../domain/usecases/search_cases_usecase.dart';
import '../../domain/usecases/watch_recent_cases_usecase.dart';

part 'cases_event.dart';
part 'cases_state.dart';

/// CasesBloc — vaka listesi, filtreleme, arama, pagination, global feed
class CasesBloc extends Bloc<CasesEvent, CasesState> {
  final GetCasesUseCase _getCases;
  final SearchCasesUseCase _searchCases;
  final WatchRecentCasesUseCase _watchFeed;
  final CaseRepository _repository;

  CasesBloc({
    required GetCasesUseCase getCases,
    required SearchCasesUseCase searchCases,
    required WatchRecentCasesUseCase watchFeed,
    required CaseRepository repository,
  })  : _getCases = getCases,
        _searchCases = searchCases,
        _watchFeed = watchFeed,
        _repository = repository,
        super(const CasesInitial()) {
    on<LoadCasesEvent>(_onLoad);
    on<LoadMoreCasesEvent>(_onLoadMore);
    on<FilterCasesEvent>(_onFilter);
    on<SearchCasesEvent>(_onSearch);
    on<RefreshCasesEvent>(_onRefresh);
    on<WatchFeedEvent>(_onWatchFeed);
    on<LoadUserCasesEvent>(_onLoadUserCases);
    on<ToggleLikeCaseEvent>(_onToggleLike);
    on<ToggleBookmarkCaseEvent>(_onToggleBookmark);
  }

  Future<void> _onLoad(
    LoadCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    emit(const CasesLoading());
    try {
      final cases = await _getCases(limit: 20);
      emit(CasesLoaded(cases: cases, hasMore: cases.length == 20));
    } catch (e) {
      emit(CasesError(_errorMessage(e)));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    if (state is! CasesLoaded) return;
    final current = state as CasesLoaded;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final lastId = current.cases.last.id;
      final more = await _getCases(
        specialtyFilter: current.activeFilter,
        limit: 20,
        lastCaseId: lastId,
      );
      emit(current.copyWith(
        cases: [...current.cases, ...more],
        hasMore: more.length == 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false, errorMessage: _errorMessage(e)));
    }
  }

  Future<void> _onFilter(
    FilterCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    emit(const CasesLoading());
    try {
      final cases = await _getCases(
        specialtyFilter: event.specialty,
        urgencyFilter: event.urgency,
        statusFilter: event.status,
        limit: 20,
      );
      emit(CasesLoaded(
        cases: cases,
        hasMore: cases.length == 20,
        activeFilter: event.specialty,
      ));
    } catch (e) {
      emit(CasesError(_errorMessage(e)));
    }
  }

  Future<void> _onSearch(
    SearchCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const LoadCasesEvent());
      return;
    }
    emit(const CasesLoading());
    try {
      final cases = await _searchCases(event.query.trim());
      emit(CasesLoaded(cases: cases, hasMore: false, isSearchResult: true));
    } catch (e) {
      emit(CasesError(_errorMessage(e)));
    }
  }

  Future<void> _onRefresh(
    RefreshCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    if (state is CasesLoaded) {
      final current = state as CasesLoaded;
      try {
        final cases = await _getCases(
          specialtyFilter: current.activeFilter,
          limit: 20,
        );
        emit(current.copyWith(
          cases: cases,
          hasMore: cases.length == 20,
          errorMessage: null,
        ));
      } catch (e) {
        // Keep existing data on refresh fail
        emit(current.copyWith(errorMessage: _errorMessage(e)));
      }
    } else {
      add(const LoadCasesEvent());
    }
  }

  /// Global feed — Firestore snapshot listener (real-time)
  Future<void> _onWatchFeed(
    WatchFeedEvent event,
    Emitter<CasesState> emit,
  ) async {
    emit(const CasesLoading());
    await emit.forEach(
      _watchFeed(limit: 30),
      onData: (cases) =>
          CasesLoaded(cases: cases, hasMore: false, isLiveFeed: true),
      onError: (e, _) => CasesError(_errorMessage(e)),
    );
  }

  Future<void> _onLoadUserCases(
    LoadUserCasesEvent event,
    Emitter<CasesState> emit,
  ) async {
    emit(const CasesLoading());
    try {
      final cases = await _repository.getUserCases(event.userId);
      emit(CasesLoaded(cases: cases, hasMore: false));
    } catch (e) {
      emit(CasesError(_errorMessage(e)));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeCaseEvent event,
    Emitter<CasesState> emit,
  ) async {
    try {
      if (event.isCurrentlyLiked) {
        await _repository.unlikeCase(event.caseId);
      } else {
        await _repository.likeCase(event.caseId);
      }
      // Refresh if we have loaded state
      if (state is CasesLoaded) {
        add(const RefreshCasesEvent());
      }
    } catch (_) {
      // Like failure is non-critical — swallow
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkCaseEvent event,
    Emitter<CasesState> emit,
  ) async {
    try {
      if (event.isCurrentlyBookmarked) {
        await _repository.unbookmarkCase(event.caseId);
      } else {
        await _repository.bookmarkCase(event.caseId);
      }
      if (state is CasesLoaded) {
        add(const RefreshCasesEvent());
      }
    } catch (_) {
      // Bookmark failure is non-critical — swallow
    }
  }

  String _errorMessage(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Bir hata oluştu';
  }
}
