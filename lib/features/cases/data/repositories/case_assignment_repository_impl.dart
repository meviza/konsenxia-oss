import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/case_assignment.dart';
import '../../domain/repositories/case_assignment_repository.dart';

/// KONSENXIA — CaseAssignmentRepositoryImpl
///
/// Firestore koleksiyonu: `case_assignments/{assignmentId}`
/// Atama oluşturulduğunda `notifications/{userId}/items` altına bildirim yazılır.
class CaseAssignmentRepositoryImpl implements CaseAssignmentRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CaseAssignmentRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _assignments =>
      _db.collection('case_assignments');

  CollectionReference<Map<String, dynamic>> _userNotifications(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  String get _currentUid => _auth.currentUser?.uid ?? '';
  String get _currentDisplayName =>
      _auth.currentUser?.displayName ?? 'Doktor';

  @override
  Future<List<CaseAssignment>> getAssignmentsForCase(String caseId) async {
    final snap = await _assignments
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 5));
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<CaseAssignment>> getAssignmentsForUser(String userId) async {
    final snap = await _assignments
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(const Duration(seconds: 5));
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<CaseAssignment> createAssignment({
    required String caseId,
    required String caseTitle,
    required String caseSpecialty,
    required String assignedToUserId,
    required String assignedToName,
    String? notes,
    DateTime? dueDate,
  }) async {
    final uid = _currentUid;
    final assignerName = _currentDisplayName;

    // Kullanıcı profil bilgisi için Firestore'dan unvan çek (fallback: 'Dr.')
    String assignerTitle = 'Dr.';
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'] as String? ?? '';
        assignerTitle = switch (role) {
          'PROFESSOR'  => 'Prof. Dr.',
          'SPECIALIST' => 'Uzm. Dr.',
          _            => 'Dr.',
        };
      }
    } catch (_) {}

    final now = DateTime.now();
    final ref = _assignments.doc();

    final data = {
      'id': ref.id,
      'caseId': caseId,
      'caseTitle': caseTitle,
      'caseSpecialty': caseSpecialty,
      'assignedTo': assignedToUserId,
      'assignedToName': assignedToName,
      'assignedBy': uid,
      'assignedByName': assignerName,
      'assignedByTitle': assignerTitle,
      'status': 'pending',
      'notes': notes,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(ref, data);

    // Bildirim oluştur
    final notifRef = _userNotifications(assignedToUserId).doc();
    batch.set(notifRef, {
      'id': notifRef.id,
      'type': 'case_assigned',
      'title': 'Yeni Vaka Atandı',
      'body': '$assignerTitle $assignerName size "$caseTitle" vakasını atadı.',
      'data': {'caseId': caseId, 'assignmentId': ref.id},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return CaseAssignment(
      id: ref.id,
      caseId: caseId,
      caseTitle: caseTitle,
      caseSpecialty: caseSpecialty,
      assignedTo: assignedToUserId,
      assignedToName: assignedToName,
      assignedBy: uid,
      assignedByName: assignerName,
      assignedByTitle: assignerTitle,
      notes: notes,
      dueDate: dueDate,
      status: 'pending',
      createdAt: now,
    );
  }

  @override
  Future<void> updateAssignmentStatus(
      String assignmentId, String status) async {
    await _assignments.doc(assignmentId).update({'status': status});
  }

  @override
  Future<bool> isAssigned({
    required String caseId,
    required String userId,
  }) async {
    final snap = await _assignments
        .where('caseId', isEqualTo: caseId)
        .where('assignedTo', isEqualTo: userId)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 5));
    return snap.docs.isNotEmpty;
  }

  // ── Model dönüşümü ───────────────────────────────────────────────

  CaseAssignment _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return CaseAssignment(
      id: doc.id,
      caseId: d['caseId'] as String,
      caseTitle: d['caseTitle'] as String,
      caseSpecialty: d['caseSpecialty'] as String? ?? '',
      assignedTo: d['assignedTo'] as String,
      assignedToName: d['assignedToName'] as String? ?? '',
      assignedBy: d['assignedBy'] as String,
      assignedByName: d['assignedByName'] as String? ?? '',
      assignedByTitle: d['assignedByTitle'] as String? ?? 'Dr.',
      status: d['status'] as String? ?? 'pending',
      notes: d['notes'] as String?,
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
