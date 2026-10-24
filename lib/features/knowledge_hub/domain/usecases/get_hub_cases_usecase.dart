import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hub_case_entity.dart';
import '../repositories/hub_case_repository.dart';

class GetHubCasesUseCase implements UseCase<List<HubCaseEntity>, GetHubCasesParams> {
  final HubCaseRepository repository;
  const GetHubCasesUseCase(this.repository);

  @override
  Future<List<HubCaseEntity>> call(GetHubCasesParams params) =>
      repository.getHubCases(
        category: params.category,
        specialty: params.specialty,
        lastDocId: params.lastDocId,
        limit: params.limit,
      );
}

class GetHubCasesParams extends Equatable {
  final HubCaseCategory? category;
  final String? specialty;
  final String? lastDocId;
  final int limit;

  const GetHubCasesParams({
    this.category,
    this.specialty,
    this.lastDocId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [category, specialty, lastDocId, limit];
}
