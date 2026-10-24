import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/usecases/analyze_diagnosis_usecase.dart';
import '../../domain/usecases/get_suggested_symptoms_usecase.dart';
import '../../domain/repositories/diagnosis_repository.dart';

part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final AnalyzeDiagnosisUseCase _analyze;
  final GetSuggestedSymptomsUseCase _getSuggestions;
  final DiagnosisRepository _repository;

  DiagnosisInput _currentInput = const DiagnosisInput(
    patientAge: 45,
    patientGender: 'Erkek',
    chiefComplaint: '',
  );

  DiagnosisBloc({
    required AnalyzeDiagnosisUseCase analyze,
    required GetSuggestedSymptomsUseCase getSuggestions,
    required DiagnosisRepository repository,
  })  : _analyze = analyze,
        _getSuggestions = getSuggestions,
        _repository = repository,
        super(DiagnosisInputState(
          input: const DiagnosisInput(
            patientAge: 45,
            patientGender: 'Erkek',
            chiefComplaint: '',
          ),
        )) {
    on<UpdateInputEvent>(_onUpdateInput);
    on<AddSymptomEvent>(_onAddSymptom);
    on<RemoveSymptomEvent>(_onRemoveSymptom);
    on<AnalyzeEvent>(_onAnalyze);
    on<GetSuggestedSymptomsEvent>(_onGetSuggestions);
    on<ClearResultEvent>(_onClear);
    on<SaveSessionEvent>(_onSave);
  }

  Future<void> _onUpdateInput(
    UpdateInputEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    _currentInput = event.input;
    final currentState = state;
    emit(DiagnosisInputState(
      input: _currentInput,
      suggestedSymptoms: currentState is DiagnosisInputState
          ? currentState.suggestedSymptoms
          : const [],
    ));
  }

  Future<void> _onAddSymptom(
    AddSymptomEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    if (_currentInput.symptoms.contains(event.symptom)) return;
    _currentInput = _currentInput.copyWith(
      symptoms: [..._currentInput.symptoms, event.symptom],
    );
    final currentState = state;
    emit(DiagnosisInputState(
      input: _currentInput,
      suggestedSymptoms: currentState is DiagnosisInputState
          ? currentState.suggestedSymptoms
          : const [],
    ));
  }

  Future<void> _onRemoveSymptom(
    RemoveSymptomEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    _currentInput = _currentInput.copyWith(
      symptoms:
          _currentInput.symptoms.where((s) => s != event.symptom).toList(),
    );
    final currentState = state;
    emit(DiagnosisInputState(
      input: _currentInput,
      suggestedSymptoms: currentState is DiagnosisInputState
          ? currentState.suggestedSymptoms
          : const [],
    ));
  }

  Future<void> _onAnalyze(
    AnalyzeEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    if (_currentInput.chiefComplaint.trim().isEmpty) {
      emit(DiagnosisError('Bas sikayet giriniz', lastInput: _currentInput));
      return;
    }
    emit(DiagnosisAnalyzing(input: _currentInput));
    try {
      final result = await _analyze(_currentInput);
      final session = DiagnosisSession(
        id: 'dd_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        createdAt: DateTime.now(),
        input: _currentInput,
        result: result,
      );
      emit(DiagnosisResultState(session: session));
    } catch (e) {
      emit(DiagnosisError(
        e.toString().replaceAll('Exception: ', ''),
        lastInput: _currentInput,
      ));
    }
  }

  Future<void> _onGetSuggestions(
    GetSuggestedSymptomsEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final suggestions = await _getSuggestions(event.chiefComplaint);
      emit(DiagnosisInputState(
        input: _currentInput,
        suggestedSymptoms: suggestions,
      ));
    } catch (_) {}
  }

  Future<void> _onClear(
    ClearResultEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    _currentInput = const DiagnosisInput(
      patientAge: 45,
      patientGender: 'Erkek',
      chiefComplaint: '',
    );
    emit(DiagnosisInputState(input: _currentInput));
  }

  Future<void> _onSave(
    SaveSessionEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    final currentState = state;
    if (currentState is DiagnosisResultState) {
      await _repository.saveSession(currentState.session);
    }
  }
}
