import '../entities/simulation_entity.dart';
import '../repositories/simulation_repository.dart';

class GetScenariosUseCase {
  final SimulationRepository _repository;
  GetScenariosUseCase(this._repository);

  Future<List<SimulationEntity>> call({
    String? specialty,
    SimulationDifficulty? difficulty,
  }) =>
      _repository.getScenarios(specialty: specialty, difficulty: difficulty);
}
