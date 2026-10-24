import '../entities/prescription_entity.dart';

class PrescriptionException implements Exception {
  final String message;
  const PrescriptionException(this.message);
  @override
  String toString() => 'PrescriptionException: $message';
}

abstract interface class PrescriptionsRepository {
  Future<List<PrescriptionEntity>> getPrescriptions();
}
