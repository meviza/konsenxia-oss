import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medical_report_entity.dart';

class MedicalReportModel {
  static MedicalReportEntity fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MedicalReportEntity(
      id: doc.id,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: ReportType.fromValue(d['type'] as String? ?? 'lab_result'),
      title: d['title'] as String? ?? '',
      summary: d['summary'] as String? ?? '',
      detail: d['detail'] as String? ?? '',
      institution: d['institution'] as String? ?? '',
      isAbnormal: d['isAbnormal'] as bool? ?? false,
      fileUrl: d['fileUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreateMap({
    required String title,
    required String summary,
    required String detail,
    required String institution,
    required ReportType type,
    required DateTime date,
    required bool isAbnormal,
    String? fileUrl,
  }) {
    return {
      'title': title,
      'summary': summary,
      'detail': detail,
      'institution': institution,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'isAbnormal': isAbnormal,
      'fileUrl': fileUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
