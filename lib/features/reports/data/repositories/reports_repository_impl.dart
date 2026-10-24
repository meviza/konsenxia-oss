import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/medical_report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../models/medical_report_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ReportsRepositoryImpl({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference get _reports =>
      _db.collection('users').doc(_uid).collection('medical_reports');

  @override
  Future<List<MedicalReportEntity>> getReports({int? year}) async {
    try {
      Query query = _reports.orderBy('date', descending: true);
      if (year != null) {
        final start = DateTime(year);
        final end = DateTime(year + 1);
        query = query
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end));
      }
      final snap = await query.get();
      return snap.docs.map(MedicalReportModel.fromDoc).toList();
    } catch (e) {
      throw ReportException('Raporlar yüklenemedi: $e');
    }
  }

  @override
  Future<MedicalReportEntity> getReportById(String reportId) async {
    try {
      final doc = await _reports.doc(reportId).get();
      if (!doc.exists) throw const ReportException('Rapor bulunamadı');
      return MedicalReportModel.fromDoc(doc);
    } catch (e) {
      if (e is ReportException) rethrow;
      throw ReportException('Rapor yüklenemedi: $e');
    }
  }

  @override
  Future<MedicalReportEntity> uploadReport({
    required String title,
    required String summary,
    required String detail,
    required String institution,
    required ReportType type,
    required DateTime date,
    required bool isAbnormal,
    String? fileUrl,
  }) async {
    try {
      final docRef = await _reports.add(MedicalReportModel.toCreateMap(
        title: title,
        summary: summary,
        detail: detail,
        institution: institution,
        type: type,
        date: date,
        isAbnormal: isAbnormal,
        fileUrl: fileUrl,
      ));
      final doc = await docRef.get();
      return MedicalReportModel.fromDoc(doc);
    } on FirebaseException catch (e) {
      // Preserve Firebase error code for permission-denied detection upstream
      if (e.code == 'permission-denied' || e.code == 'PERMISSION_DENIED') {
        throw ReportException('permission-denied: ${e.message}');
      }
      throw ReportException('Rapor yüklenemedi: $e');
    } catch (e) {
      throw ReportException('Rapor yüklenemedi: $e');
    }
  }
}
