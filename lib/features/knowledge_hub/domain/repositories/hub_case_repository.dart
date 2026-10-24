import '../entities/hub_case_entity.dart';

/// KONSENXIA Knowledge Hub — Repository Arayüzü
abstract class HubCaseRepository {
  /// Vakaları listele (pagination, kategori filtresi)
  Future<List<HubCaseEntity>> getHubCases({
    HubCaseCategory? category,
    String? specialty,
    String? lastDocId,
    int limit = 20,
  });

  /// Arama
  Future<List<HubCaseEntity>> searchHubCases(String query);

  /// Tekil vaka detayı
  Future<HubCaseEntity> getHubCaseById(String id);

  /// Yeni vaka oluştur
  Future<HubCaseEntity> createHubCase({
    required String title,
    required String abstract_,
    required String content,
    required HubCaseCategory category,
    required String specialty,
    required HubDifficulty difficulty,
    required List<String> tags,
  });

  /// Beğen / beğeniyi kaldır
  Future<void> likeHubCase(String caseId);
  Future<void> unlikeHubCase(String caseId);
  Future<bool> isHubCaseLiked(String caseId);

  /// Yer imi
  Future<void> bookmarkHubCase(String caseId);
  Future<void> unbookmarkHubCase(String caseId);
  Future<bool> isHubCaseBookmarked(String caseId);

  /// Görüntülenme sayacı
  Future<void> incrementViewCount(String caseId);
}

class HubCaseException implements Exception {
  final String message;
  const HubCaseException(this.message);

  @override
  String toString() => 'HubCaseException: $message';
}
