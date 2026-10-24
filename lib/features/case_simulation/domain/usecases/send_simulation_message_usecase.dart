import '../entities/simulation_entity.dart';
import '../repositories/simulation_repository.dart';

class SendSimulationMessageUseCase {
  final SimulationRepository _repository;
  SendSimulationMessageUseCase(this._repository);

  Future<SimulationMessage> call(
    String simulationId,
    String message,
    SimulationPhase phase,
  ) =>
      _repository.sendMessage(simulationId, message, phase);
}
