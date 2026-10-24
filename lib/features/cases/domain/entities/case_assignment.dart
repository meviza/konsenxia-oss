import 'package:equatable/equatable.dart';

/// KONSENXIA — CaseAssignment Entity
///
/// Bir uzman/profesör tarafından intern/residente atanan vaka kaydı.
/// Firestore koleksiyonu: `case_assignments/{assignmentId}`
class CaseAssignment extends Equatable {
  final String id;
  final String caseId;
  final String caseTitle;
  final String caseSpecialty;

  /// Vakanın atandığı doktor
  final String assignedTo;
  final String assignedToName;

  /// Vakayı atayan doktor
  final String assignedBy;
  final String assignedByName;
  final String assignedByTitle; // Prof. Dr. / Uzm. Dr.

  /// Son teslim tarihi (opsiyonel)
  final DateTime? dueDate;

  /// pending | in_progress | completed
  final String status;

  /// Atama notu
  final String? notes;

  final DateTime createdAt;

  const CaseAssignment({
    required this.id,
    required this.caseId,
    required this.caseTitle,
    required this.caseSpecialty,
    required this.assignedTo,
    required this.assignedToName,
    required this.assignedBy,
    required this.assignedByName,
    required this.assignedByTitle,
    this.dueDate,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
  });

  bool get isPending    => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted  => status == 'completed';

  CaseAssignment copyWith({String? status, String? notes}) {
    return CaseAssignment(
      id: id,
      caseId: caseId,
      caseTitle: caseTitle,
      caseSpecialty: caseSpecialty,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      assignedBy: assignedBy,
      assignedByName: assignedByName,
      assignedByTitle: assignedByTitle,
      dueDate: dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, caseId, assignedTo, status];
}
