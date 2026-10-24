import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/usecases/get_case_by_id_usecase.dart';
import '../../domain/usecases/contribute_to_case_usecase.dart';
import '../../domain/repositories/case_repository.dart';

part 'case_detail_event.dart';
part 'case_detail_state.dart';

/// CaseDetailBloc — vaka detay, yorumlar, sosyal aksiyonlar
class CaseDetailBloc extends Bloc<CaseDetailEvent, CaseDetailState> {
  final GetCaseByIdUseCase _getCaseById;
  final ContributeToCaseUseCase _contribute;
  final CaseRepository _repository;

  CaseDetailBloc({
    required GetCaseByIdUseCase getCaseById,
    required ContributeToCaseUseCase contribute,
    required CaseRepository repository,
  })  : _getCaseById = getCaseById,
        _contribute = contribute,
        _repository = repository,
        super(const CaseDetailInitial()) {
    on<LoadCaseDetailEvent>(_onLoad);
    on<LikeCaseEvent>(_onLikeCase);
    on<BookmarkCaseEvent>(_onBookmark);
    on<SubmitCommentEvent>(_onSubmitComment);
    on<LikeCommentEvent>(_onLikeComment);
  }

  Future<void> _onLoad(
    LoadCaseDetailEvent event,
    Emitter<CaseDetailState> emit,
  ) async {
    emit(const CaseDetailLoading());
    try {
      final kase = await _getCaseById(event.caseId);
      emit(CaseDetailLoaded(kase: kase));
      _repository.incrementViewCount(event.caseId).ignore();
    } catch (e) {
      emit(CaseDetailError(_msg(e)));
    }
  }

  Future<void> _onLikeCase(
    LikeCaseEvent event,
    Emitter<CaseDetailState> emit,
  ) async {
    if (state is! CaseDetailLoaded) return;
    final s = state as CaseDetailLoaded;
    final liked = !s.kase.isLikedByCurrentUser;

    // Optimistic UI
    emit(s.copyWith(
      kase: s.kase.copyWith(
        isLikedByCurrentUser: liked,
        likeCount: s.kase.likeCount + (liked ? 1 : -1),
      ),
    ));

    try {
      if (liked) {
        await _repository.likeCase(s.kase.id);
      } else {
        await _repository.unlikeCase(s.kase.id);
      }
    } catch (e) {
      // For seed data cases or Firestore failures, keep optimistic state
      debugPrint('[CaseDetailBloc] Like Firestore sync failed (keeping optimistic state): $e');
    }
  }

  Future<void> _onBookmark(
    BookmarkCaseEvent event,
    Emitter<CaseDetailState> emit,
  ) async {
    if (state is! CaseDetailLoaded) return;
    final s = state as CaseDetailLoaded;
    final bm = !s.kase.isBookmarkedByCurrentUser;

    emit(s.copyWith(
      kase: s.kase.copyWith(
        isBookmarkedByCurrentUser: bm,
        bookmarkCount: s.kase.bookmarkCount + (bm ? 1 : -1),
      ),
    ));

    try {
      if (bm) {
        await _repository.bookmarkCase(s.kase.id);
      } else {
        await _repository.unbookmarkCase(s.kase.id);
      }
    } catch (e) {
      // For seed data cases or Firestore failures, keep optimistic state
      debugPrint('[CaseDetailBloc] Bookmark Firestore sync failed (keeping optimistic state): $e');
    }
  }

  Future<void> _onSubmitComment(
    SubmitCommentEvent event,
    Emitter<CaseDetailState> emit,
  ) async {
    if (state is! CaseDetailLoaded) return;
    final s = state as CaseDetailLoaded;
    if (event.content.trim().isEmpty) return;

    emit(s.copyWith(isSubmittingComment: true));

    try {
      await _contribute.addComment(
        caseId: s.kase.id,
        content: event.content,
      );
      // Firestore'dan guncel veriyi cek
      final updated = await _getCaseById(s.kase.id);
      emit(CaseDetailLoaded(kase: updated));
    } catch (_) {
      // Firestore erisilemezse yorumu lokal olarak ekle
      String userName = 'Dr. Kullanici';
      String userRole = 'Doktor';
      try {
        final storage = GetIt.instance<LocalStorage>();
        userName = storage.getUserName() ?? 'Dr. Kullanici';
        userRole = storage.userRole ?? 'Doktor';
      } catch (_) {}

      final newComment = CaseComment(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        authorId: 'current_user',
        authorName: userName,
        authorSpecialty: userRole,
        authorLevel: 5,
        content: event.content,
        createdAt: DateTime.now(),
        isOffline: true,
      );
      final updatedComments = [...s.kase.comments, newComment];
      emit(CaseDetailLoaded(
        kase: s.kase.copyWith(comments: updatedComments),
        offlineCommentAdded: true,
      ));
    }
  }

  Future<void> _onLikeComment(
    LikeCommentEvent event,
    Emitter<CaseDetailState> emit,
  ) async {
    if (state is! CaseDetailLoaded) return;
    final s = state as CaseDetailLoaded;

    // Optimistic UI
    final updatedComments = s.kase.comments.map((c) {
      if (c.id != event.commentId) return c;
      final liked = !c.isLikedByCurrentUser;
      return CaseComment(
        id: c.id, authorId: c.authorId, authorName: c.authorName,
        authorImageUrl: c.authorImageUrl, authorSpecialty: c.authorSpecialty,
        authorLevel: c.authorLevel, content: c.content, replies: c.replies,
        isExpertOpinion: c.isExpertOpinion, isAcceptedAnswer: c.isAcceptedAnswer,
        createdAt: c.createdAt,
        likeCount: c.likeCount + (liked ? 1 : -1),
        isLikedByCurrentUser: liked,
      );
    }).toList();

    emit(s.copyWith(kase: s.kase.copyWith(comments: updatedComments)));

    try {
      await _contribute.likeComment(
        caseId: s.kase.id,
        commentId: event.commentId,
      );
    } catch (e) {
      // For seed data or Firestore failures, keep optimistic state
      debugPrint('[CaseDetailBloc] Comment like sync failed (keeping optimistic state): $e');
    }
  }

  String _msg(Object e) => e
      .toString()
      .replaceAll('Exception: ', '')
      .replaceAll('CaseRepositoryException: ', '');
}
