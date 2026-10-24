import '../entities/simulation_entity.dart';
import '../repositories/simulation_repository.dart';

class StartSimulationUseCase {
  final SimulationRepository _repository;
  StartSimulationUseCase(this._repository);

  Future<SimulationEntity> call(String scenarioId) =>
      _repository.startSimulation(scenarioId);
}
