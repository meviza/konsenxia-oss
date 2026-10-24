part of 'simulation_bloc.dart';

sealed class SimulationEvent extends Equatable {
  const SimulationEvent();
  @override
  List<Object?> get props => [];
}

class LoadScenariosEvent extends SimulationEvent {
  final String? specialty;
  final SimulationDifficulty? difficulty;
  const LoadScenariosEvent({this.specialty, this.difficulty});

  @override
  List<Object?> get props => [specialty, difficulty];
}

class StartSimulationEvent extends SimulationEvent {
  final String scenarioId;
  const StartSimulationEvent(this.scenarioId);

  @override
  List<Object?> get props => [scenarioId];
}

class SendMessageEvent extends SimulationEvent {
  final String message;
  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderTestEvent extends SimulationEvent {
  final String testName;
  const OrderTestEvent(this.testName);

  @override
  List<Object?> get props => [testName];
}

class AdvancePhaseEvent extends SimulationEvent {
  const AdvancePhaseEvent();
}

class SubmitDiagnosisEvent extends SimulationEvent {
  final String diagnosis;
  final String treatmentPlan;
  const SubmitDiagnosisEvent({
    required this.diagnosis,
    required this.treatmentPlan,
  });

  @override
  List<Object?> get props => [diagnosis, treatmentPlan];
}

class BackToScenariosEvent extends SimulationEvent {
  const BackToScenariosEvent();
}
