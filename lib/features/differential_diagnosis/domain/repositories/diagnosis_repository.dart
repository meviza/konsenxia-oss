import '../entities/diagnosis_entity.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisResult> analyzeDifferentialDiagnosis(DiagnosisInput input);
  Future<List<DiagnosisSession>> getHistory(String userId);
  Future<void> saveSession(DiagnosisSession session);
  Future<List<String>> getSuggestedSymptoms(String chiefComplaint);
}
