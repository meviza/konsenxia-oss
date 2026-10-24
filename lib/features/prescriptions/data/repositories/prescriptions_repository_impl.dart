import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../models/prescription_model.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  PrescriptionsRepositoryImpl({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference get _prescriptions =>
      _db.collection('users').doc(_uid).collection('prescriptions');

  @override
  Future<List<PrescriptionEntity>> getPrescriptions() async {
    try {
      final snap = await _prescriptions
          .orderBy('prescribedDate', descending: true)
          .get();
      return snap.docs.map(PrescriptionModel.fromDoc).toList();
    } catch (e) {
      throw PrescriptionException('Reçeteler yüklenemedi: $e');
    }
  }
}
