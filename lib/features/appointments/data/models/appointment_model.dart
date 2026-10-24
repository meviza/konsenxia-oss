import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel {
  static AppointmentEntity fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppointmentEntity(
      id: doc.id,
      doctorId: d['doctorId'] as String? ?? '',
      doctorName: d['doctorName'] as String? ?? '',
      specialty: d['specialty'] as String? ?? '',
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: AppointmentType.fromValue(d['type'] as String? ?? 'in_person'),
      location: d['location'] as String?,
      notes: d['notes'] as String?,
      status: AppointmentStatus.fromValue(d['status'] as String? ?? 'pending'),
      meetingUrl: d['meetingUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
