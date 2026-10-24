import '../repositories/diagnosis_repository.dart';

class GetSuggestedSymptomsUseCase {
  final DiagnosisRepository _repository;
  GetSuggestedSymptomsUseCase(this._repository);

  Future<List<String>> call(String chiefComplaint) =>
      _repository.getSuggestedSymptoms(chiefComplaint);
}
