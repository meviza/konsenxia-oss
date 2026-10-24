import 'package:equatable/equatable.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentsEvent {
  const LoadAppointmentsEvent();
}

class CancelAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;
  const CancelAppointmentEvent(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}

class FilterAppointmentsEvent extends AppointmentsEvent {
  final String tab; // 'Yaklaşan' | 'Geçmiş' | 'Bekleyen'
  const FilterAppointmentsEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}
