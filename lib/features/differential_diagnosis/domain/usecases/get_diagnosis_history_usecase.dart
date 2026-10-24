import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

class GetDiagnosisHistoryUseCase {
  final DiagnosisRepository _repository;
  GetDiagnosisHistoryUseCase(this._repository);

  Future<List<DiagnosisSession>> call(String userId) =>
      _repository.getHistory(userId);
}
