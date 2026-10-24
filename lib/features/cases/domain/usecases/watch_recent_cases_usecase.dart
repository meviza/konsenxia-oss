import '../entities/case_entity.dart';
import '../repositories/case_repository.dart';

/// Global case feed — gerçek zamanlı yeni vaka akışı.
class WatchRecentCasesUseCase {
  final CaseRepository _repository;
  const WatchRecentCasesUseCase(this._repository);

  Stream<List<CaseEntity>> call({int limit = 20}) =>
      _repository.watchRecentCases(limit: limit);
}
