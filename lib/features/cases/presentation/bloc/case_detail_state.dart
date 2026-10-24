part of 'case_detail_bloc.dart';

abstract class CaseDetailState extends Equatable {
  const CaseDetailState();
  @override List<Object?> get props => [];
}

class CaseDetailInitial extends CaseDetailState { const CaseDetailInitial(); }
class CaseDetailLoading extends CaseDetailState { const CaseDetailLoading(); }

class CaseDetailLoaded extends CaseDetailState {
  final CaseEntity kase;
  final bool isSubmittingComment;
  final bool offlineCommentAdded;

  const CaseDetailLoaded({
    required this.kase,
    this.isSubmittingComment = false,
    this.offlineCommentAdded = false,
  });

  CaseDetailLoaded copyWith({
    CaseEntity? kase,
    bool? isSubmittingComment,
    bool? offlineCommentAdded,
  }) =>
      CaseDetailLoaded(
        kase: kase ?? this.kase,
        isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
        offlineCommentAdded: offlineCommentAdded ?? false,
      );

  @override List<Object?> get props => [kase, isSubmittingComment, offlineCommentAdded];
}

class CaseDetailError extends CaseDetailState {
  final String message;
  const CaseDetailError(this.message);
  @override List<Object?> get props => [message];
}
