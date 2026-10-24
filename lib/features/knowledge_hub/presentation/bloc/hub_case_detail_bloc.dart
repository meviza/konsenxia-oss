import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/hub_case_repository.dart';
import '../../domain/usecases/get_hub_case_detail_usecase.dart';
import '../../domain/usecases/like_hub_case_usecase.dart';
import 'hub_case_detail_event.dart';
import 'hub_case_detail_state.dart';

class HubCaseDetailBloc extends Bloc<HubCaseDetailEvent, HubCaseDetailState> {
  final GetHubCaseDetailUseCase _getDetail;
  final LikeHubCaseUseCase _like;
  final HubCaseRepository _repository;

  HubCaseDetailBloc({
    required GetHubCaseDetailUseCase getDetail,
    required LikeHubCaseUseCase like,
    required HubCaseRepository repository,
  })  : _getDetail = getDetail,
        _like = like,
        _repository = repository,
        super(const HubCaseDetailInitial()) {
    on<LoadHubCaseDetailEvent>(_onLoad);
    on<LikeHubCaseDetailEvent>(_onLike);
    on<BookmarkHubCaseDetailEvent>(_onBookmark);
  }

  Future<void> _onLoad(LoadHubCaseDetailEvent event, Emitter<HubCaseDetailState> emit) async {
    emit(const HubCaseDetailLoading());
    try {
      final hubCase = await _getDetail(event.caseId);
      await _repository.incrementViewCount(event.caseId);
      emit(HubCaseDetailLoaded(hubCase));
    } on HubCaseException catch (e) {
      emit(HubCaseDetailError(e.message));
    }
  }

  Future<void> _onLike(LikeHubCaseDetailEvent event, Emitter<HubCaseDetailState> emit) async {
    final current = state;
    if (current is! HubCaseDetailLoaded) return;
    final c = current.hubCase;
    // Optimistic update
    final updated = c.copyWith(
      isLikedByCurrentUser: !c.isLikedByCurrentUser,
      likeCount: c.likeCount + (c.isLikedByCurrentUser ? -1 : 1),
    );
    emit(HubCaseDetailLoaded(updated));
    try {
      await _like(LikeHubCaseParams(
        caseId: c.id,
        isCurrentlyLiked: c.isLikedByCurrentUser,
      ));
    } catch (e) {
      // For seed data cases or Firestore failures, keep optimistic state
      // instead of rolling back — the local state is the source of truth
      debugPrint('[HubCaseDetailBloc] Like Firestore sync failed (keeping optimistic state): $e');
    }
  }

  Future<void> _onBookmark(BookmarkHubCaseDetailEvent event, Emitter<HubCaseDetailState> emit) async {
    final current = state;
    if (current is! HubCaseDetailLoaded) return;
    final c = current.hubCase;
    // Optimistic update
    final updated = c.copyWith(
      isBookmarkedByCurrentUser: !c.isBookmarkedByCurrentUser,
    );
    emit(HubCaseDetailLoaded(updated));
    try {
      if (c.isBookmarkedByCurrentUser) {
        await _repository.unbookmarkHubCase(c.id);
      } else {
        await _repository.bookmarkHubCase(c.id);
      }
    } catch (e) {
      // For seed data cases or Firestore failures, keep optimistic state
      debugPrint('[HubCaseDetailBloc] Bookmark Firestore sync failed (keeping optimistic state): $e');
    }
  }
}
