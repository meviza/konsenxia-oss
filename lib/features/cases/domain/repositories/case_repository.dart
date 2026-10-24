import '../../../../core/errors/failures.dart';
import '../entities/case_entity.dart';

/// KONSENXIA — Case Repository Interface
///
/// Domain katmanı sözleşmesi. Data katmanı bu arayüzü implement eder.
/// BLoC sadece bu arayüzü kullanır — backend agnostik.
///
/// Hata yönetimi: metodlar başarısız olduğunda [CaseRepositoryException] fırlatır.
/// [Failure] sınıfı hatanın türünü belirtir.

class CaseRepositoryException implements Exception {
  final Failure failure;
  const CaseRepositoryException(this.failure);

  @override
  String toString() => 'CaseRepositoryException: ${failure.message}';
}

abstract class CaseRepository {
  // ── Listing ────────────────────────────────────────────────────

  /// Yeni vakaların gerçek zamanlı akışı (global feed).
  Stream<List<CaseEntity>> watchRecentCases({int limit = 20});

  Future<List<CaseEntity>> getCases({
    String? specialtyFilter,
    String? urgencyFilter,
    String? statusFilter,
    int limit = 20,
    String? lastCaseId,
  });

  Future<List<CaseEntity>> searchCases(String query);

  Future<List<CaseEntity>> getTrendingCases({int limit = 10});

  // ── Detail ─────────────────────────────────────────────────────
  Future<CaseEntity> getCaseById(String caseId);

  Stream<CaseEntity> watchCase(String caseId);

  // ── Mutations ──────────────────────────────────────────────────
  Future<String> createCase({
    required String title,
    required String description,
    required String clinicalPresentation,
    required String patientSummary,
    required CaseUrgency urgency,
    List<String> specialties = const [],
    List<String> tags = const [],
    List<VitalSign> vitals = const [],
  });

  Future<void> updateCase(CaseEntity kase);

  Future<void> deleteCase(String caseId);

  Future<void> solveCase({
    required String caseId,
    required String diagnosisTitle,
    required String diagnosisDetails,
    required String acceptedCommentId,
  });

  // ── Social ─────────────────────────────────────────────────────
  Future<void> likeCase(String caseId);

  Future<void> unlikeCase(String caseId);

  Future<void> bookmarkCase(String caseId);

  Future<void> unbookmarkCase(String caseId);

  Future<bool> isCaseLiked(String caseId);

  Future<bool> isCaseBookmarked(String caseId);

  // ── Comments ───────────────────────────────────────────────────
  Future<List<CaseComment>> getComments(String caseId);

  Stream<List<CaseComment>> watchComments(String caseId);

  Future<String> addComment({
    required String caseId,
    required String content,
  });

  Future<void> likeComment({
    required String caseId,
    required String commentId,
  });

  Future<void> unlikeComment({
    required String caseId,
    required String commentId,
  });

  Future<void> acceptAnswer({
    required String caseId,
    required String commentId,
  });

  // ── User cases ─────────────────────────────────────────────────
  Future<List<CaseEntity>> getUserCases(String userId);

  Future<List<CaseEntity>> getBookmarkedCases();

  // ── View tracking ─────────────────────────────────────────────
  Future<void> incrementViewCount(String caseId);
}
