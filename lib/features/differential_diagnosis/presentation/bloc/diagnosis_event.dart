part of 'diagnosis_bloc.dart';

sealed class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();
  @override
  List<Object?> get props => [];
}

class UpdateInputEvent extends DiagnosisEvent {
  final DiagnosisInput input;
  const UpdateInputEvent(this.input);

  @override
  List<Object?> get props => [input];
}

class AddSymptomEvent extends DiagnosisEvent {
  final String symptom;
  const AddSymptomEvent(this.symptom);

  @override
  List<Object?> get props => [symptom];
}

class RemoveSymptomEvent extends DiagnosisEvent {
  final String symptom;
  const RemoveSymptomEvent(this.symptom);

  @override
  List<Object?> get props => [symptom];
}

class AnalyzeEvent extends DiagnosisEvent {
  const AnalyzeEvent();
}

class GetSuggestedSymptomsEvent extends DiagnosisEvent {
  final String chiefComplaint;
  const GetSuggestedSymptomsEvent(this.chiefComplaint);

  @override
  List<Object?> get props => [chiefComplaint];
}

class ClearResultEvent extends DiagnosisEvent {
  const ClearResultEvent();
}

class SaveSessionEvent extends DiagnosisEvent {
  const SaveSessionEvent();
}
