import '../entities/appointment_entity.dart';

class AppointmentException implements Exception {
  final String message;
  const AppointmentException(this.message);
  @override
  String toString() => 'AppointmentException: $message';
}

abstract interface class AppointmentsRepository {
  Future<List<AppointmentEntity>> getAppointments();
  Future<void> cancelAppointment(String appointmentId);
}
