import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/emergency_entity.dart';
import '../../domain/repositories/emergency_repository.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final List<EmergencyConsultation> _store = [];

  EmergencyRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _store.addAll(_mockConsultations());
  }

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<EmergencyConsultation>> getActiveConsultations() async {
    try {
      final snap = await _db
          .collection('emergency_consultations')
          .where('status', whereIn: ['pending', 'inProgress'])
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => _fromFirestore(d)).toList();
      }
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore read failed, using mock: $e');
    }
    return _store.where((c) => !c.isResolved).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<EmergencyConsultation>> getMyConsultations(String userId) async {
    try {
      final snap = await _db
          .collection('emergency_consultations')
          .where('requesterId', isEqualTo: _uid ?? userId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => _fromFirestore(d)).toList();
      }
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore read failed, using mock: $e');
    }
    return _store.where((c) => c.requesterId == userId).toList();
  }

  @override
  Future<EmergencyConsultation> createConsultation(
      EmergencyConsultation consultation) async {
    final id = 'ec_${DateTime.now().millisecondsSinceEpoch}';
    final created = EmergencyConsultation(
      id: id,
      requesterId: _uid ?? consultation.requesterId,
      requesterName: consultation.requesterName,
      requesterSpecialty: consultation.requesterSpecialty,
      requesterImageUrl: consultation.requesterImageUrl,
      priority: consultation.priority,
      targetSpecialty: consultation.targetSpecialty,
      title: consultation.title,
      clinicalSummary: consultation.clinicalSummary,
      patient: consultation.patient,
      imageUrls: consultation.imageUrls,
      createdAt: DateTime.now(),
    );

    // Firestore'a kaydet
    try {
      await _db.collection('emergency_consultations').doc(id).set({
        'requesterId': _uid,
        'requesterName': consultation.requesterName,
        'requesterSpecialty': consultation.requesterSpecialty,
        'priority': consultation.priority.name,
        'status': 'pending',
        'targetSpecialty': consultation.targetSpecialty,
        'title': consultation.title,
        'clinicalSummary': consultation.clinicalSummary,
        'patient': {
          'age': consultation.patient.age,
          'gender': consultation.patient.gender,
          'chiefComplaint': consultation.patient.chiefComplaint,
          'vitals': consultation.patient.vitals,
          'activeConditions': consultation.patient.activeConditions,
          'currentMedications': consultation.patient.currentMedications,
        },
        'imageUrls': consultation.imageUrls,
        'responses': [],
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore write failed, local only: $e');
    }

    _store.insert(0, created);
    return created;
  }

  @override
  Future<void> respondToConsultation(
      String consultationId, ConsultationResponse response) async {
    // Firestore güncelle
    try {
      await _db.collection('emergency_consultations').doc(consultationId).update({
        'status': 'inProgress',
        'responses': FieldValue.arrayUnion([{
          'id': response.id,
          'responderId': response.responderId,
          'responderName': response.responderName,
          'responderSpecialty': response.responderSpecialty,
          'responderLevel': response.responderLevel,
          'content': response.content,
          'recommendedAction': response.recommendedAction,
          'suggestedTests': response.suggestedTests,
          'createdAt': FieldValue.serverTimestamp(),
          'responseTimeSeconds': response.responseTimeSeconds,
          'xpEarned': response.xpEarned,
        }]),
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore respond failed: $e');
    }

    final idx = _store.indexWhere((c) => c.id == consultationId);
    if (idx == -1) throw Exception('Konsültasyon bulunamadı');
    final c = _store[idx];
    _store[idx] = c.copyWith(
      responses: [...c.responses, response],
      status: EmergencyStatus.inProgress,
    );
  }

  @override
  Future<void> acceptResponse(
      String consultationId, String responseId) async {
    try {
      await _db.collection('emergency_consultations').doc(consultationId).update({
        'status': 'resolved',
        'acceptedResponseId': responseId,
        'resolvedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore accept failed: $e');
    }

    final idx = _store.indexWhere((c) => c.id == consultationId);
    if (idx == -1) return;
    _store[idx] = _store[idx].copyWith(
      status: EmergencyStatus.resolved,
      acceptedResponseId: responseId,
      resolvedAt: DateTime.now(),
    );
  }

  @override
  Future<List<AvailableExpert>> getAvailableExperts(String specialty) async {
    // Firestore'dan online doktorları çek
    try {
      var query = _db.collection('users')
          .where('isOnline', isEqualTo: true);
      if (specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }
      final snap = await query.get().timeout(const Duration(seconds: 3));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final data = d.data();
          return AvailableExpert(
            id: d.id,
            name: data['displayName'] as String? ?? '',
            specialty: data['specialty'] as String? ?? '',
            level: (data['level'] as num?)?.toInt() ?? 1,
            isOnline: true,
            avgResponseMinutes: 5,
            totalConsultations: (data['contributionCount'] as num?)?.toInt() ?? 0,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[EMERGENCY] Firestore experts failed, using mock: $e');
    }
    return _mockExperts
        .where((e) => e.specialty == specialty || specialty.isEmpty)
        .toList();
  }

  // ── Firestore → Entity ─────────────────────────────────────────────

  EmergencyConsultation _fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final patientMap = d['patient'] as Map<String, dynamic>? ?? {};
    final responsesList = (d['responses'] as List<dynamic>?) ?? [];

    return EmergencyConsultation(
      id: doc.id,
      requesterId: d['requesterId'] as String? ?? '',
      requesterName: d['requesterName'] as String? ?? '',
      requesterSpecialty: d['requesterSpecialty'] as String? ?? '',
      priority: _parsePriority(d['priority'] as String?),
      status: _parseStatus(d['status'] as String?),
      targetSpecialty: d['targetSpecialty'] as String? ?? '',
      title: d['title'] as String? ?? '',
      clinicalSummary: d['clinicalSummary'] as String? ?? '',
      patient: PatientBrief(
        age: (patientMap['age'] as num?)?.toInt() ?? 0,
        gender: patientMap['gender'] as String? ?? '',
        chiefComplaint: patientMap['chiefComplaint'] as String? ?? '',
        vitals: Map<String, String>.from(patientMap['vitals'] as Map? ?? {}),
        activeConditions: List<String>.from(patientMap['activeConditions'] as List? ?? []),
        currentMedications: List<String>.from(patientMap['currentMedications'] as List? ?? []),
      ),
      imageUrls: List<String>.from(d['imageUrls'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedResponseId: d['acceptedResponseId'] as String?,
      resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
      responses: responsesList.map((r) {
        final rm = r as Map<String, dynamic>;
        return ConsultationResponse(
          id: rm['id'] as String? ?? '',
          responderId: rm['responderId'] as String? ?? '',
          responderName: rm['responderName'] as String? ?? '',
          responderSpecialty: rm['responderSpecialty'] as String? ?? '',
          responderLevel: (rm['responderLevel'] as num?)?.toInt() ?? 1,
          content: rm['content'] as String? ?? '',
          recommendedAction: rm['recommendedAction'] as String?,
          suggestedTests: List<String>.from(rm['suggestedTests'] as List? ?? []),
          createdAt: (rm['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          responseTimeSeconds: (rm['responseTimeSeconds'] as num?)?.toInt() ?? 0,
          xpEarned: (rm['xpEarned'] as num?)?.toInt() ?? 0,
          isAccepted: rm['isAccepted'] as bool? ?? false,
        );
      }).toList(),
    );
  }

  EmergencyPriority _parsePriority(String? p) => switch (p) {
    'lifeThreatening' => EmergencyPriority.lifeThreatening,
    'critical' => EmergencyPriority.critical,
    'urgent' => EmergencyPriority.urgent,
    _ => EmergencyPriority.urgent,
  };

  EmergencyStatus _parseStatus(String? s) => switch (s) {
    'pending' => EmergencyStatus.pending,
    'inProgress' => EmergencyStatus.inProgress,
    'resolved' => EmergencyStatus.resolved,
    _ => EmergencyStatus.pending,
  };

  // ── Mock Data ─────────────────────────────────────────────────────

  static final _mockExperts = [
    const AvailableExpert(id: 'exp1', name: 'Prof. Dr. Ahmet Yilmaz', specialty: 'Kardiyoloji', level: 8, isOnline: true, avgResponseMinutes: 5, totalConsultations: 234),
    const AvailableExpert(id: 'exp2', name: 'Doc. Dr. Elif Demir', specialty: 'Noroloji', level: 7, isOnline: true, avgResponseMinutes: 8, totalConsultations: 156),
    const AvailableExpert(id: 'exp3', name: 'Prof. Dr. Mehmet Kaya', specialty: 'Gogus Hastaliklari', level: 9, isOnline: false, avgResponseMinutes: 12, totalConsultations: 312),
    const AvailableExpert(id: 'exp4', name: 'Uzm. Dr. Zeynep Arslan', specialty: 'Acil Tip', level: 6, isOnline: true, avgResponseMinutes: 3, totalConsultations: 189),
    const AvailableExpert(id: 'exp5', name: 'Doc. Dr. Can Ozturk', specialty: 'Genel Cerrahi', level: 7, isOnline: true, avgResponseMinutes: 7, totalConsultations: 201),
    const AvailableExpert(id: 'exp6', name: 'Prof. Dr. Ayse Celik', specialty: 'Dahiliye', level: 8, isOnline: false, avgResponseMinutes: 10, totalConsultations: 278),
    const AvailableExpert(id: 'exp7', name: 'Uzm. Dr. Burak Sahin', specialty: 'Ortopedi', level: 5, isOnline: true, avgResponseMinutes: 6, totalConsultations: 98),
    const AvailableExpert(id: 'exp8', name: 'Doc. Dr. Selin Yildiz', specialty: 'Kardiyoloji', level: 7, isOnline: true, avgResponseMinutes: 4, totalConsultations: 167),
  ];

  List<EmergencyConsultation> _mockConsultations() {
    final now = DateTime.now();
    return [
      EmergencyConsultation(
        id: 'ec_001',
        requesterId: 'u1',
        requesterName: 'Dr. Ali Vural',
        requesterSpecialty: 'Acil Tip',
        priority: EmergencyPriority.lifeThreatening,
        status: EmergencyStatus.pending,
        targetSpecialty: 'Kardiyoloji',
        title: 'STEMI - Primer PKG gerekli',
        clinicalSummary: '58 yasinda erkek, 1 saattir gogus agrisi. EKG: anterior STEMI. '
            'Troponin yuksek. Hemodinamik stabil. PKG icin kardiyoloji gorusu isteniyor.',
        patient: const PatientBrief(
          age: 58, gender: 'Erkek',
          chiefComplaint: 'Retrosternal gogus agrisi - 1 saat',
          vitals: {'TA': '150/90', 'Nabiz': '105', 'SpO2': '95%', 'Ates': '36.7'},
          activeConditions: ['HT', 'DM Tip 2', 'Hiperlipidemi'],
          currentMedications: ['Metformin', 'Amlodipin', 'Atorvastatin'],
        ),
        createdAt: now.subtract(const Duration(minutes: 8)),
        responses: [
          ConsultationResponse(
            id: 'resp_001',
            responderId: 'exp1',
            responderName: 'Prof. Dr. Ahmet Yilmaz',
            responderSpecialty: 'Kardiyoloji',
            responderLevel: 8,
            content: 'Hastaya 300mg ASA + 180mg Ticagrelor yukle. '
                'Heparin 5000U IV bolus. Kateter labina hazirliyoruz, 10dk icinde geliyorum.',
            recommendedAction: 'Acil PKG',
            suggestedTests: ['Kardiyak enzimler seri', 'Eko'],
            createdAt: now.subtract(const Duration(minutes: 5)),
            responseTimeSeconds: 180,
            xpEarned: 150,
          ),
        ],
      ),
      EmergencyConsultation(
        id: 'ec_002',
        requesterId: 'u2',
        requesterName: 'Dr. Sema Koc',
        requesterSpecialty: 'Dahiliye',
        priority: EmergencyPriority.critical,
        status: EmergencyStatus.pending,
        targetSpecialty: 'Noroloji',
        title: 'Akut hemiparez - Strok suphe',
        clinicalSummary: '72 yasinda kadin, 45dk once ani sag kol-bacak gucsuzlugu. '
            'Konusma bozuklugu (dizartri). NIHSS: 12. BT normal, difuzyon MR bekleniyor.',
        patient: const PatientBrief(
          age: 72, gender: 'Kadin',
          chiefComplaint: 'Ani sag tarafta gucsuzluk ve konusma bozuklugu',
          vitals: {'TA': '185/100', 'Nabiz': '88', 'SpO2': '97%', 'GKS': '13'},
          activeConditions: ['AF', 'HT', 'Warfarin kullanimi duzensiz'],
          currentMedications: ['Warfarin', 'Metoprolol', 'Ramipril'],
        ),
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      EmergencyConsultation(
        id: 'ec_003',
        requesterId: 'u3',
        requesterName: 'Dr. Emre Tan',
        requesterSpecialty: 'Acil Tip',
        priority: EmergencyPriority.urgent,
        status: EmergencyStatus.inProgress,
        targetSpecialty: 'Genel Cerrahi',
        title: 'Akut batin - perforasyon suphe',
        clinicalSummary: '45 yasinda erkek, 6 saattir siddetlenen yaygin karin agrisi. '
            'Batin sert (defans+), rebound+. PAAG: serbest hava goruldu.',
        patient: const PatientBrief(
          age: 45, gender: 'Erkek',
          chiefComplaint: 'Yaygin karin agrisi ve batinda sertlik',
          vitals: {'TA': '100/65', 'Nabiz': '120', 'SpO2': '96%', 'Ates': '38.5'},
          activeConditions: ['Peptik ulser oykusu'],
          currentMedications: ['NSAII (duzenli kullanim)'],
        ),
        createdAt: now.subtract(const Duration(minutes: 35)),
        responses: [
          ConsultationResponse(
            id: 'resp_003',
            responderId: 'exp5',
            responderName: 'Doc. Dr. Can Ozturk',
            responderSpecialty: 'Genel Cerrahi',
            responderLevel: 7,
            content: 'Perfore peptik ulser ile uyumlu. IV sivi resusitasyonu baslayin, '
                'genis spektrumlu antibiyotik (Pip-Tazo) yukleyin. Ameliyathaneyi hazirliyorum.',
            recommendedAction: 'Acil laparotomi',
            createdAt: now.subtract(const Duration(minutes: 25)),
            responseTimeSeconds: 600,
            xpEarned: 100,
          ),
        ],
      ),
    ];
  }
}
