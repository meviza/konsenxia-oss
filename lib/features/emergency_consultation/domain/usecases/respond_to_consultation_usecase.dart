import '../entities/emergency_entity.dart';
import '../repositories/emergency_repository.dart';

class RespondToConsultationUseCase {
  final EmergencyRepository _repository;
  RespondToConsultationUseCase(this._repository);

  Future<void> call(String consultationId, ConsultationResponse response) =>
      _repository.respondToConsultation(consultationId, response);
}
