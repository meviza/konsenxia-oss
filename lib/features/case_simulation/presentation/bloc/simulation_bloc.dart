import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/simulation_entity.dart';
import '../../domain/usecases/get_scenarios_usecase.dart';
import '../../domain/usecases/start_simulation_usecase.dart';
import '../../domain/usecases/send_simulation_message_usecase.dart';
import '../../domain/usecases/submit_diagnosis_usecase.dart';
import '../../domain/repositories/simulation_repository.dart';

part 'simulation_event.dart';
part 'simulation_state.dart';

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final GetScenariosUseCase _getScenarios;
  final StartSimulationUseCase _startSimulation;
  final SendSimulationMessageUseCase _sendMessage;
  final SubmitDiagnosisUseCase _submitDiagnosis;
  final SimulationRepository _repository;

  SimulationEntity? _activeSimulation;

  SimulationBloc({
    required GetScenariosUseCase getScenarios,
    required StartSimulationUseCase startSimulation,
    required SendSimulationMessageUseCase sendMessage,
    required SubmitDiagnosisUseCase submitDiagnosis,
    required SimulationRepository repository,
  })  : _getScenarios = getScenarios,
        _startSimulation = startSimulation,
        _sendMessage = sendMessage,
        _submitDiagnosis = submitDiagnosis,
        _repository = repository,
        super(const SimulationInitial()) {
    on<LoadScenariosEvent>(_onLoadScenarios);
    on<StartSimulationEvent>(_onStart);
    on<SendMessageEvent>(_onSendMessage);
    on<OrderTestEvent>(_onOrderTest);
    on<AdvancePhaseEvent>(_onAdvancePhase);
    on<SubmitDiagnosisEvent>(_onSubmitDiagnosis);
    on<BackToScenariosEvent>(_onBackToScenarios);
  }

  Future<void> _onLoadScenarios(
    LoadScenariosEvent event,
    Emitter<SimulationState> emit,
  ) async {
    emit(const ScenariosLoading());
    try {
      final scenarios = await _getScenarios(
        specialty: event.specialty,
        difficulty: event.difficulty,
      );
      emit(ScenariosLoaded(scenarios: scenarios, activeFilter: event.specialty));
    } catch (e) {
      emit(SimulationError(_msg(e)));
    }
  }

  Future<void> _onStart(
    StartSimulationEvent event,
    Emitter<SimulationState> emit,
  ) async {
    emit(const ScenariosLoading());
    try {
      _activeSimulation = await _startSimulation(event.scenarioId);
      emit(SimulationActive(
          simulation: _activeSimulation!, isAiTyping: false));
    } catch (e) {
      emit(SimulationError(_msg(e)));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<SimulationState> emit,
  ) async {
    if (_activeSimulation == null) return;

    final doctorMsg = SimulationMessage(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      role: SimulationMessageRole.doctor,
      content: event.message,
      phase: _activeSimulation!.currentPhase,
      timestamp: DateTime.now(),
    );

    _activeSimulation = _activeSimulation!.copyWith(
      messages: [..._activeSimulation!.messages, doctorMsg],
    );
    emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: true));

    try {
      final response = await _sendMessage(
        _activeSimulation!.id,
        event.message,
        _activeSimulation!.currentPhase,
      );
      _activeSimulation = _activeSimulation!.copyWith(
        messages: [..._activeSimulation!.messages, response],
      );
      emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: false));
    } catch (e) {
      emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: false));
    }
  }

  Future<void> _onOrderTest(
    OrderTestEvent event,
    Emitter<SimulationState> emit,
  ) async {
    if (_activeSimulation == null) return;

    emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: true));
    try {
      final results = await _repository.orderTest(
          _activeSimulation!.id, event.testName);

      final systemMsg = SimulationMessage(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        role: SimulationMessageRole.system,
        content: '📋 ${event.testName} Sonucu:\n${results.join('\n')}',
        phase: SimulationPhase.tests,
        timestamp: DateTime.now(),
      );

      _activeSimulation = _activeSimulation!.copyWith(
        messages: [..._activeSimulation!.messages, systemMsg],
        orderedTests: [..._activeSimulation!.orderedTests, event.testName],
      );
      emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: false));
    } catch (e) {
      emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: false));
    }
  }

  Future<void> _onAdvancePhase(
    AdvancePhaseEvent event,
    Emitter<SimulationState> emit,
  ) async {
    if (_activeSimulation == null) return;

    try {
      _activeSimulation =
          await _repository.advancePhase(_activeSimulation!.id);
      emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: false));
    } catch (e) {
      emit(SimulationError(_msg(e)));
    }
  }

  Future<void> _onSubmitDiagnosis(
    SubmitDiagnosisEvent event,
    Emitter<SimulationState> emit,
  ) async {
    if (_activeSimulation == null) return;
    emit(SimulationActive(simulation: _activeSimulation!, isAiTyping: true));

    try {
      final score = await _submitDiagnosis(
        _activeSimulation!.id,
        event.diagnosis,
        event.treatmentPlan,
      );
      _activeSimulation = _activeSimulation!.copyWith(
        isCompleted: true,
        currentPhase: SimulationPhase.completed,
        userDiagnosis: event.diagnosis,
        score: score,
      );
      emit(SimulationCompleted(
          simulation: _activeSimulation!, score: score));
    } catch (e) {
      emit(SimulationError(_msg(e)));
    }
  }

  Future<void> _onBackToScenarios(
    BackToScenariosEvent event,
    Emitter<SimulationState> emit,
  ) async {
    _activeSimulation = null;
    add(const LoadScenariosEvent());
  }

  String _msg(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Bir hata oluştu';
  }
}
