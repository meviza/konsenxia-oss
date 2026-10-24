import '../entities/case_entity.dart';
import '../repositories/case_repository.dart';

/// Vaka listesini getirir. Filtre ve pagination desteği.
class GetCasesUseCase {
  final CaseRepository repository;
  const GetCasesUseCase(this.repository);

  Future<List<CaseEntity>> call({
    String? specialtyFilter,
    String? urgencyFilter,
    String? statusFilter,
    int limit = 20,
    String? lastCaseId,
  }) =>
      repository.getCases(
        specialtyFilter: specialtyFilter,
        urgencyFilter: urgencyFilter,
        statusFilter: statusFilter,
        limit: limit,
        lastCaseId: lastCaseId,
      );
}
