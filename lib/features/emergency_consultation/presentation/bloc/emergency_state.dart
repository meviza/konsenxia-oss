part of 'emergency_bloc.dart';

sealed class EmergencyState extends Equatable {
  const EmergencyState();
  @override
  List<Object?> get props => [];
}

class EmergencyInitial extends EmergencyState {
  const EmergencyInitial();
}

class EmergencyLoading extends EmergencyState {
  const EmergencyLoading();
}

class EmergencyLoaded extends EmergencyState {
  final List<EmergencyConsultation> consultations;
  final List<AvailableExpert> availableExperts;
  final String? activeFilter;

  const EmergencyLoaded({
    required this.consultations,
    this.availableExperts = const [],
    this.activeFilter,
  });

  EmergencyLoaded copyWith({
    List<EmergencyConsultation>? consultations,
    List<AvailableExpert>? availableExperts,
    String? activeFilter,
  }) =>
      EmergencyLoaded(
        consultations: consultations ?? this.consultations,
        availableExperts: availableExperts ?? this.availableExperts,
        activeFilter: activeFilter ?? this.activeFilter,
      );

  @override
  List<Object?> get props => [consultations, availableExperts, activeFilter];
}

class EmergencyError extends EmergencyState {
  final String message;
  const EmergencyError(this.message);

  @override
  List<Object?> get props => [message];
}
