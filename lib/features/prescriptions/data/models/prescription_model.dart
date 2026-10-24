import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prescription_entity.dart';

class PrescriptionModel {
  static PrescriptionEntity fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PrescriptionEntity(
      id: doc.id,
      drugName: d['drugName'] as String? ?? '',
      form: d['form'] as String? ?? '',
      dosage: d['dosage'] as String? ?? '',
      prescriber: d['prescriber'] as String? ?? '',
      prescribedDate: (d['prescribedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (d['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      refillsLeft: (d['refillsLeft'] as num?)?.toInt() ?? 0,
      indication: d['indication'] as String? ?? '',
      isActive: d['isActive'] as bool? ?? true,
      isControlled: d['isControlled'] as bool? ?? false,
    );
  }
}
