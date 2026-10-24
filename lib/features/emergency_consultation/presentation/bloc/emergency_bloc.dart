import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_entity.dart';
import '../../domain/usecases/get_active_consultations_usecase.dart';
import '../../domain/usecases/create_consultation_usecase.dart';
import '../../domain/usecases/respond_to_consultation_usecase.dart';
import '../../domain/usecases/get_available_experts_usecase.dart';

part 'emergency_event.dart';
part 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final GetActiveConsultationsUseCase _getActive;
  final CreateConsultationUseCase _create;
  final RespondToConsultationUseCase _respond;
  final GetAvailableExpertsUseCase _getExperts;

  EmergencyBloc({
    required GetActiveConsultationsUseCase getActive,
    required CreateConsultationUseCase create,
    required RespondToConsultationUseCase respond,
    required GetAvailableExpertsUseCase getExperts,
  })  : _getActive = getActive,
        _create = create,
        _respond = respond,
        _getExperts = getExperts,
        super(const EmergencyInitial()) {
    on<LoadConsultationsEvent>(_onLoad);
    on<CreateConsultationEvent>(_onCreate);
    on<RespondEvent>(_onRespond);
    on<AcceptResponseEvent>(_onAcceptResponse);
    on<LoadExpertsEvent>(_onLoadExperts);
    on<RefreshEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadConsultationsEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(const EmergencyLoading());
    try {
      final consultations = await _getActive();
      emit(EmergencyLoaded(consultations: consultations));
    } catch (e) {
      emit(EmergencyError(_msg(e)));
    }
  }

  Future<void> _onCreate(
    CreateConsultationEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      final created = await _create(event.consultation);
      final currentState = state;
      if (currentState is EmergencyLoaded) {
        emit(EmergencyLoaded(
          consultations: [created, ...currentState.consultations],
          availableExperts: currentState.availableExperts,
        ));
      } else {
        emit(EmergencyLoaded(consultations: [created]));
      }
    } catch (e) {
      emit(EmergencyError(_msg(e)));
    }
  }

  Future<void> _onRespond(
    RespondEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      await _respond(event.consultationId, event.response);
      add(const LoadConsultationsEvent());
    } catch (e) {
      emit(EmergencyError(_msg(e)));
    }
  }

  Future<void> _onAcceptResponse(
    AcceptResponseEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    // For now, just reload
    add(const LoadConsultationsEvent());
  }

  Future<void> _onLoadExperts(
    LoadExpertsEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      final experts = await _getExperts(event.specialty);
      final currentState = state;
      if (currentState is EmergencyLoaded) {
        emit(currentState.copyWith(availableExperts: experts));
      } else {
        emit(EmergencyLoaded(consultations: const [], availableExperts: experts));
      }
    } catch (e) {
      emit(EmergencyError(_msg(e)));
    }
  }

  Future<void> _onRefresh(
    RefreshEvent event,
    Emitter<EmergencyState> emit,
  ) async {
    add(const LoadConsultationsEvent());
  }

  String _msg(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Bir hata olustu';
  }
}
