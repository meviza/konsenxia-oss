part of 'diagnosis_bloc.dart';

sealed class DiagnosisState extends Equatable {
  const DiagnosisState();
  @override
  List<Object?> get props => [];
}

class DiagnosisInputState extends DiagnosisState {
  final DiagnosisInput input;
  final List<String> suggestedSymptoms;

  const DiagnosisInputState({
    required this.input,
    this.suggestedSymptoms = const [],
  });

  @override
  List<Object?> get props => [input, suggestedSymptoms];
}

class DiagnosisAnalyzing extends DiagnosisState {
  final DiagnosisInput input;
  const DiagnosisAnalyzing({required this.input});

  @override
  List<Object?> get props => [input];
}

class DiagnosisResultState extends DiagnosisState {
  final DiagnosisSession session;
  const DiagnosisResultState({required this.session});

  @override
  List<Object?> get props => [session];
}

class DiagnosisError extends DiagnosisState {
  final String message;
  final DiagnosisInput? lastInput;
  const DiagnosisError(this.message, {this.lastInput});

  @override
  List<Object?> get props => [message, lastInput];
}
