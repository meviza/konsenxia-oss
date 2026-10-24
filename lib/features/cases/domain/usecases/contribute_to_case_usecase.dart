import '../repositories/case_repository.dart';

/// Vakaya yorum (katkı) ekler. Kabul edilen cevabı işaretler.
class ContributeToCaseUseCase {
  final CaseRepository repository;
  const ContributeToCaseUseCase(this.repository);

  Future<String> addComment({
    required String caseId,
    required String content,
  }) =>
      repository.addComment(caseId: caseId, content: content);

  Future<void> acceptAnswer({
    required String caseId,
    required String commentId,
  }) =>
      repository.acceptAnswer(caseId: caseId, commentId: commentId);

  Future<void> likeComment({
    required String caseId,
    required String commentId,
  }) =>
      repository.likeComment(caseId: caseId, commentId: commentId);
}
