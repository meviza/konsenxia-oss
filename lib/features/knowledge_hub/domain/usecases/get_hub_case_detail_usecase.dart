import '../../../../core/usecase/usecase.dart';
import '../entities/hub_case_entity.dart';
import '../repositories/hub_case_repository.dart';

class GetHubCaseDetailUseCase implements UseCase<HubCaseEntity, String> {
  final HubCaseRepository repository;
  const GetHubCaseDetailUseCase(this.repository);

  @override
  Future<HubCaseEntity> call(String caseId) =>
      repository.getHubCaseById(caseId);
}
