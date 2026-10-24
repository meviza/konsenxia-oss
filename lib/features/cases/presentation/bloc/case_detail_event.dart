part of 'case_detail_bloc.dart';

abstract class CaseDetailEvent extends Equatable {
  const CaseDetailEvent();
  @override List<Object?> get props => [];
}

class LoadCaseDetailEvent extends CaseDetailEvent {
  final String caseId;
  const LoadCaseDetailEvent(this.caseId);
  @override List<Object?> get props => [caseId];
}

class LikeCaseEvent extends CaseDetailEvent { const LikeCaseEvent(); }
class BookmarkCaseEvent extends CaseDetailEvent { const BookmarkCaseEvent(); }

class SubmitCommentEvent extends CaseDetailEvent {
  final String content;
  const SubmitCommentEvent(this.content);
  @override List<Object?> get props => [content];
}

class LikeCommentEvent extends CaseDetailEvent {
  final String commentId;
  const LikeCommentEvent(this.commentId);
  @override List<Object?> get props => [commentId];
}
