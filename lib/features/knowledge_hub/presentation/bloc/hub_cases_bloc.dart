import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../domain/entities/hub_case_entity.dart';
import '../../domain/repositories/hub_case_repository.dart';
import '../../domain/usecases/get_hub_cases_usecase.dart';
import '../../domain/usecases/like_hub_case_usecase.dart';
import 'hub_cases_event.dart';
import 'hub_cases_state.dart';

class HubCasesBloc extends Bloc<HubCasesEvent, HubCasesState> {
  final GetHubCasesUseCase _getHubCases;
  final LikeHubCaseUseCase _likeHubCase;
  final SearchHubCasesUseCase _searchHubCases;

  static const int _pageSize = 20;

  HubCasesBloc({
    required GetHubCasesUseCase getHubCases,
    required LikeHubCaseUseCase likeHubCase,
    required SearchHubCasesUseCase searchHubCases,
  })  : _getHubCases = getHubCases,
        _likeHubCase = likeHubCase,
        _searchHubCases = searchHubCases,
        super(const HubCasesInitial()) {
    on<LoadHubCasesEvent>(_onLoad);
    on<LoadMoreHubCasesEvent>(_onLoadMore, transformer: droppable());
    on<RefreshHubCasesEvent>(_onRefresh);
    on<FilterHubCasesEvent>(_onFilter);
    on<SearchHubCasesEvent>(_onSearch, transformer: restartable());
    on<LikeHubCaseEvent>(_onLike);
  }

  Future<void> _onLoad(LoadHubCasesEvent event, Emitter<HubCasesState> emit) async {
    emit(const HubCasesLoading());
    try {
      final cases = await _getHubCases(GetHubCasesParams(
        category: event.category,
        limit: _pageSize,
      ));
      emit(HubCasesLoaded(
        cases: cases,
        hasMore: cases.length >= _pageSize,
        activeCategory: event.category ?? HubCaseCategory.all,
      ));
    } on HubCaseException catch (e) {
      emit(HubCasesError(e.message));
    } catch (e) {
      emit(HubCasesError('Vakalar yuklenemedi. Lutfen tekrar deneyin.'));
    }
  }

  Future<void> _onLoadMore(LoadMoreHubCasesEvent event, Emitter<HubCasesState> emit) async {
    final current = state;
    if (current is! HubCasesLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final lastId = current.cases.isNotEmpty ? current.cases.last.id : null;
      final more = await _getHubCases(GetHubCasesParams(
        category: current.activeCategory == HubCaseCategory.all ? null : current.activeCategory,
        lastDocId: lastId,
        limit: _pageSize,
      ));
      emit(current.copyWith(
        cases: [...current.cases, ...more],
        hasMore: more.length >= _pageSize,
        isLoadingMore: false,
      ));
    } on HubCaseException catch (e) {
      emit(current.copyWith(isLoadingMore: false, errorMessage: e.message));
    }
  }

  Future<void> _onRefresh(RefreshHubCasesEvent event, Emitter<HubCasesState> emit) async {
    final current = state;
    final category = current is HubCasesLoaded ? current.activeCategory : null;
    add(LoadHubCasesEvent(category: category));
  }

  Future<void> _onFilter(FilterHubCasesEvent event, Emitter<HubCasesState> emit) async {
    emit(const HubCasesLoading());
    try {
      final cases = await _getHubCases(GetHubCasesParams(
        category: event.category == HubCaseCategory.all ? null : event.category,
        limit: _pageSize,
      ));
      emit(HubCasesLoaded(
        cases: cases,
        hasMore: cases.length >= _pageSize,
        activeCategory: event.category,
      ));
    } on HubCaseException catch (e) {
      emit(HubCasesError(e.message));
    } catch (e) {
      emit(HubCasesError('Vakalar filtrelenemedi. Lutfen tekrar deneyin.'));
    }
  }

  Future<void> _onSearch(SearchHubCasesEvent event, Emitter<HubCasesState> emit) async {
    if (event.query.isEmpty) {
      add(const LoadHubCasesEvent());
      return;
    }
    emit(const HubCasesLoading());
    try {
      final results = await _searchHubCases(event.query);
      emit(HubCasesLoaded(
        cases: results.cast<HubCaseEntity>(),
        hasMore: false,
        isSearchResult: true,
      ));
    } on HubCaseException catch (e) {
      emit(HubCasesError(e.message));
    } catch (e) {
      emit(HubCasesError('Arama basarisiz. Lutfen tekrar deneyin.'));
    }
  }

  Future<void> _onLike(LikeHubCaseEvent event, Emitter<HubCasesState> emit) async {
    final current = state;
    if (current is! HubCasesLoaded) return;

    // Optimistic update
    final updatedCases = current.cases.map((c) {
      if (c.id == event.caseId) {
        return c.copyWith(
          isLikedByCurrentUser: !event.isCurrentlyLiked,
          likeCount: c.likeCount + (event.isCurrentlyLiked ? -1 : 1),
        );
      }
      return c;
    }).toList();
    emit(current.copyWith(cases: updatedCases));

    try {
      await _likeHubCase(LikeHubCaseParams(
        caseId: event.caseId,
        isCurrentlyLiked: event.isCurrentlyLiked,
      ));
    } on HubCaseException {
      // Rollback
      emit(current);
    }
  }
}
