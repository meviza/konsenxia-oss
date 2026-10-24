import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

class AnalyzeDiagnosisUseCase {
  final DiagnosisRepository _repository;
  AnalyzeDiagnosisUseCase(this._repository);

  Future<DiagnosisResult> call(DiagnosisInput input) =>
      _repository.analyzeDifferentialDiagnosis(input);
}
