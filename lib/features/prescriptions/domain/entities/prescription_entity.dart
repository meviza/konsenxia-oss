import 'package:equatable/equatable.dart';

class PrescriptionEntity extends Equatable {
  final String id;
  final String drugName;
  final String form;
  final String dosage;
  final String prescriber;
  final DateTime prescribedDate;
  final DateTime expiryDate;
  final int refillsLeft;
  final String indication;
  final bool isActive;
  final bool isControlled;

  const PrescriptionEntity({
    required this.id,
    required this.drugName,
    required this.form,
    required this.dosage,
    required this.prescriber,
    required this.prescribedDate,
    required this.expiryDate,
    required this.refillsLeft,
    required this.indication,
    required this.isActive,
    required this.isControlled,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  @override
  List<Object?> get props => [
        id, drugName, form, dosage, prescriber,
        prescribedDate, expiryDate, refillsLeft,
        indication, isActive, isControlled,
      ];
}
