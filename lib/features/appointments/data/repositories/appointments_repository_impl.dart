import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../models/appointment_model.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AppointmentsRepositoryImpl({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference get _appointments =>
      _db.collection('users').doc(_uid).collection('appointments');

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    try {
      final snap = await _appointments
          .orderBy('date', descending: false)
          .get();
      return snap.docs.map(AppointmentModel.fromDoc).toList();
    } catch (e) {
      throw AppointmentException('Randevular yüklenemedi: $e');
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _appointments.doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.name,
      });
    } catch (e) {
      throw AppointmentException('Randevu iptal edilemedi: $e');
    }
  }
}
