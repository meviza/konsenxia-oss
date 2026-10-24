import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/hub_case_repository.dart';

class LikeHubCaseUseCase implements UseCase<void, LikeHubCaseParams> {
  final HubCaseRepository repository;
  const LikeHubCaseUseCase(this.repository);

  @override
  Future<void> call(LikeHubCaseParams params) async {
    if (params.isCurrentlyLiked) {
      await repository.unlikeHubCase(params.caseId);
    } else {
      await repository.likeHubCase(params.caseId);
    }
  }
}

class LikeHubCaseParams extends Equatable {
  final String caseId;
  final bool isCurrentlyLiked;
  const LikeHubCaseParams({required this.caseId, required this.isCurrentlyLiked});
  @override
  List<Object?> get props => [caseId, isCurrentlyLiked];
}

class SearchHubCasesUseCase implements UseCase<List<dynamic>, String> {
  final HubCaseRepository repository;
  const SearchHubCasesUseCase(this.repository);

  @override
  Future<List<dynamic>> call(String query) =>
      repository.searchHubCases(query);
}
