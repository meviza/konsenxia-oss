import '../entities/case_assignment.dart';

/// KONSENXIA — CaseAssignmentRepository Interface
abstract class CaseAssignmentRepository {
  /// Belirli bir vakaya yapılan tüm atamaları getirir
  Future<List<CaseAssignment>> getAssignmentsForCase(String caseId);

  /// Belirli bir kullanıcıya atanan vakaları getirir
  Future<List<CaseAssignment>> getAssignmentsForUser(String userId);

  /// Yeni vaka ataması oluşturur, bildirim gönderir
  Future<CaseAssignment> createAssignment({
    required String caseId,
    required String caseTitle,
    required String caseSpecialty,
    required String assignedToUserId,
    required String assignedToName,
    String? notes,
    DateTime? dueDate,
  });

  /// Atama durumunu günceller
  Future<void> updateAssignmentStatus(String assignmentId, String status);

  /// Bir kullanıcıya vaka atanmış mı?
  Future<bool> isAssigned({required String caseId, required String userId});
}
