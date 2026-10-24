import '../../../../core/usecase/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointments_repository.dart';

class GetAppointmentsUseCase
    implements UseCase<List<AppointmentEntity>, NoParams> {
  final AppointmentsRepository repository;
  const GetAppointmentsUseCase(this.repository);

  @override
  Future<List<AppointmentEntity>> call(NoParams params) =>
      repository.getAppointments();
}
