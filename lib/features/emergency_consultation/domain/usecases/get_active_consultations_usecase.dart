import '../entities/emergency_entity.dart';
import '../repositories/emergency_repository.dart';

class GetActiveConsultationsUseCase {
  final EmergencyRepository _repository;
  GetActiveConsultationsUseCase(this._repository);

  Future<List<EmergencyConsultation>> call() =>
      _repository.getActiveConsultations();
}
