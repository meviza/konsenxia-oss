import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import '../../../../core/usecase/usecase.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAppointmentsUseCase _getAppointments;
  final CancelAppointmentUseCase _cancelAppointment;

  AppointmentsBloc({
    required GetAppointmentsUseCase getAppointments,
    required CancelAppointmentUseCase cancelAppointment,
  })  : _getAppointments = getAppointments,
        _cancelAppointment = cancelAppointment,
        super(const AppointmentsInitial()) {
    on<LoadAppointmentsEvent>(_onLoad);
    on<FilterAppointmentsEvent>(_onFilter);
    on<CancelAppointmentEvent>(_onCancel);
  }

  Future<void> _onLoad(
      LoadAppointmentsEvent event, Emitter<AppointmentsState> emit) async {
    emit(const AppointmentsLoading());
    try {
      final appointments = await _getAppointments(const NoParams());
      emit(AppointmentsLoaded(all: appointments));
    } on AppointmentException catch (e) {
      emit(AppointmentsError(e.message));
    }
  }

  Future<void> _onFilter(
      FilterAppointmentsEvent event, Emitter<AppointmentsState> emit) async {
    final current = state;
    if (current is AppointmentsLoaded) {
      emit(current.copyWith(activeTab: event.tab));
    }
  }

  Future<void> _onCancel(
      CancelAppointmentEvent event, Emitter<AppointmentsState> emit) async {
    final current = state;
    if (current is! AppointmentsLoaded) return;

    // Optimistic update
    final updated = current.all.map((a) {
      if (a.id == event.appointmentId) {
        return a.copyWith(status: AppointmentStatus.cancelled);
      }
      return a;
    }).toList();
    emit(current.copyWith(all: updated));

    try {
      await _cancelAppointment(CancelAppointmentParams(event.appointmentId));
    } on AppointmentException {
      emit(current); // rollback
    }
  }
}
