import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../../domain/usecases/get_prescriptions_usecase.dart';
import '../../../../core/usecase/usecase.dart';
import 'prescriptions_event.dart';
import 'prescriptions_state.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {
  final GetPrescriptionsUseCase _getPrescriptions;

  PrescriptionsBloc({required GetPrescriptionsUseCase getPrescriptions})
      : _getPrescriptions = getPrescriptions,
        super(const PrescriptionsInitial()) {
    on<LoadPrescriptionsEvent>(_onLoad);
    on<FilterPrescriptionsEvent>(_onFilter);
  }

  Future<void> _onLoad(
      LoadPrescriptionsEvent event, Emitter<PrescriptionsState> emit) async {
    emit(const PrescriptionsLoading());
    try {
      final prescriptions = await _getPrescriptions(const NoParams());
      emit(PrescriptionsLoaded(all: prescriptions));
    } on PrescriptionException catch (e) {
      emit(PrescriptionsError(e.message));
    }
  }

  Future<void> _onFilter(
      FilterPrescriptionsEvent event, Emitter<PrescriptionsState> emit) async {
    final current = state;
    if (current is PrescriptionsLoaded) {
      emit(current.copyWith(activeFilter: event.filter));
    }
  }
}
