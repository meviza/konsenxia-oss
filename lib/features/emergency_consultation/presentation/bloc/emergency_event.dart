part of 'emergency_bloc.dart';

sealed class EmergencyEvent extends Equatable {
  const EmergencyEvent();
  @override
  List<Object?> get props => [];
}

class LoadConsultationsEvent extends EmergencyEvent {
  const LoadConsultationsEvent();
}

class CreateConsultationEvent extends EmergencyEvent {
  final EmergencyConsultation consultation;
  const CreateConsultationEvent(this.consultation);

  @override
  List<Object?> get props => [consultation];
}

class RespondEvent extends EmergencyEvent {
  final String consultationId;
  final ConsultationResponse response;
  const RespondEvent({required this.consultationId, required this.response});

  @override
  List<Object?> get props => [consultationId, response];
}

class AcceptResponseEvent extends EmergencyEvent {
  final String consultationId;
  final String responseId;
  const AcceptResponseEvent({
    required this.consultationId,
    required this.responseId,
  });

  @override
  List<Object?> get props => [consultationId, responseId];
}

class LoadExpertsEvent extends EmergencyEvent {
  final String specialty;
  const LoadExpertsEvent(this.specialty);

  @override
  List<Object?> get props => [specialty];
}

class RefreshEvent extends EmergencyEvent {
  const RefreshEvent();
}
