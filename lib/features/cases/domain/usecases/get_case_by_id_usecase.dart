import '../entities/case_entity.dart';
import '../repositories/case_repository.dart';

/// Tek vaka detayını getirir (yorumlar dahil).
class GetCaseByIdUseCase {
  final CaseRepository repository;
  const GetCaseByIdUseCase(this.repository);

  Future<CaseEntity> call(String caseId) => repository.getCaseById(caseId);
}
