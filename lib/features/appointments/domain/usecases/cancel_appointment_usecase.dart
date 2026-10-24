import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/appointments_repository.dart';

class CancelAppointmentUseCase implements UseCase<void, CancelAppointmentParams> {
  final AppointmentsRepository repository;
  const CancelAppointmentUseCase(this.repository);

  @override
  Future<void> call(CancelAppointmentParams params) =>
      repository.cancelAppointment(params.appointmentId);
}

class CancelAppointmentParams extends Equatable {
  final String appointmentId;
  const CancelAppointmentParams(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}
