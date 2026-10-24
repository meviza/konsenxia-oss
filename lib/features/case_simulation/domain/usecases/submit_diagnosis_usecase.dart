import '../entities/simulation_entity.dart';
import '../repositories/simulation_repository.dart';

class SubmitDiagnosisUseCase {
  final SimulationRepository _repository;
  SubmitDiagnosisUseCase(this._repository);

  Future<SimulationScore> call(
    String simulationId,
    String diagnosis,
    String treatmentPlan,
  ) =>
      _repository.submitDiagnosis(simulationId, diagnosis, treatmentPlan);
}
