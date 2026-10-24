import '../entities/simulation_entity.dart';

abstract class SimulationRepository {
  Future<List<SimulationEntity>> getScenarios({
    String? specialty,
    SimulationDifficulty? difficulty,
  });

  Future<SimulationEntity> startSimulation(String scenarioId);

  Future<SimulationMessage> sendMessage(
    String simulationId,
    String message,
    SimulationPhase phase,
  );

  Future<List<String>> orderTest(String simulationId, String testName);

  Future<SimulationEntity> advancePhase(String simulationId);

  Future<SimulationScore> submitDiagnosis(
    String simulationId,
    String diagnosis,
    String treatmentPlan,
  );
}
