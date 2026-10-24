part of 'simulation_bloc.dart';

sealed class SimulationState extends Equatable {
  const SimulationState();
  @override
  List<Object?> get props => [];
}

class SimulationInitial extends SimulationState {
  const SimulationInitial();
}

class ScenariosLoading extends SimulationState {
  const ScenariosLoading();
}

class ScenariosLoaded extends SimulationState {
  final List<SimulationEntity> scenarios;
  final String? activeFilter;

  const ScenariosLoaded({required this.scenarios, this.activeFilter});

  @override
  List<Object?> get props => [scenarios, activeFilter];
}

class SimulationActive extends SimulationState {
  final SimulationEntity simulation;
  final bool isAiTyping;

  const SimulationActive({required this.simulation, this.isAiTyping = false});

  @override
  List<Object?> get props => [simulation, isAiTyping];
}

class SimulationCompleted extends SimulationState {
  final SimulationEntity simulation;
  final SimulationScore score;

  const SimulationCompleted({required this.simulation, required this.score});

  @override
  List<Object?> get props => [simulation, score];
}

class SimulationError extends SimulationState {
  final String message;
  const SimulationError(this.message);

  @override
  List<Object?> get props => [message];
}
