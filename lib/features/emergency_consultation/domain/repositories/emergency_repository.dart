import '../entities/emergency_entity.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyConsultation>> getActiveConsultations();
  Future<List<EmergencyConsultation>> getMyConsultations(String userId);
  Future<EmergencyConsultation> createConsultation(EmergencyConsultation consultation);
  Future<void> respondToConsultation(String consultationId, ConsultationResponse response);
  Future<void> acceptResponse(String consultationId, String responseId);
  Future<List<AvailableExpert>> getAvailableExperts(String specialty);
}
