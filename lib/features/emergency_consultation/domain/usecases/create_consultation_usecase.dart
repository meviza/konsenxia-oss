import '../entities/emergency_entity.dart';
import '../repositories/emergency_repository.dart';

class CreateConsultationUseCase {
  final EmergencyRepository _repository;
  CreateConsultationUseCase(this._repository);

  Future<EmergencyConsultation> call(EmergencyConsultation consultation) =>
      _repository.createConsultation(consultation);
}
