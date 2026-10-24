import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hub_case_entity.dart';
import '../repositories/hub_case_repository.dart';

class CreateHubCaseUseCase implements UseCase<HubCaseEntity, CreateHubCaseParams> {
  final HubCaseRepository repository;
  const CreateHubCaseUseCase(this.repository);

  @override
  Future<HubCaseEntity> call(CreateHubCaseParams params) =>
      repository.createHubCase(
        title: params.title,
        abstract_: params.abstract_,
        content: params.content,
        category: params.category,
        specialty: params.specialty,
        difficulty: params.difficulty,
        tags: params.tags,
      );
}

class CreateHubCaseParams extends Equatable {
  final String title;
  final String abstract_;
  final String content;
  final HubCaseCategory category;
  final String specialty;
  final HubDifficulty difficulty;
  final List<String> tags;

  const CreateHubCaseParams({
    required this.title,
    required this.abstract_,
    required this.content,
    required this.category,
    required this.specialty,
    required this.difficulty,
    required this.tags,
  });

  @override
  List<Object?> get props => [title, abstract_, content, category, specialty, difficulty, tags];
}
