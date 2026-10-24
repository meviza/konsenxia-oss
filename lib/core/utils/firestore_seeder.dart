import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'hub_seed_data.dart';

/// KONSENXIA — Kapsamlı Firestore Seed Data
///
/// Tüm boş koleksiyonları tek seferde seed eder.
/// Debug modda çalışır, production'da atlanır.
///
/// Kullanım: `await FirestoreSeeder.seedAll()`
class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Tüm koleksiyonları seed et
  static Future<void> seedAll() async {
    if (!kDebugMode) return;

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await Future.wait([
        _seedUsers(uid),
        _seedHubCases(),
        _seedPolls(uid),
        _seedNotifications(uid),
        _seedMedicalFiles(uid),
        _seedEmergencyConsultations(uid),
        _seedCaseAssignments(uid),
        _seedAnalyticsData(uid),
      ]);
      debugPrint('[SEEDER] All collections seeded successfully');
    } catch (e) {
      debugPrint('[SEEDER] Seed error (non-critical): $e');
    }
  }

  // ── Kullanıcılar (5 mock doktor) ─────────────────────────────────

  static Future<void> _seedUsers(String currentUid) async {
    if (await _hasData('users')) return;

    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();

    // Mevcut kullanıcıyı güncelle
    batch.set(_db.collection('users').doc(currentUid), {
      'displayName': 'Dr. Kerem Çelik',
      'displayNameLower': 'dr. kerem çelik',
      'specialty': 'Dahiliye',
      'role': 'SPECIALIST',
      'xp': 5200,
      'xpThisWeek': 340,
      'xpThisMonth': 1200,
      'level': 7,
      'caseCount': 89,
      'contributionCount': 234,
      'countryCount': 5,
      'rank': 45,
      'totalComments': 187,
      'acceptedAnswers': 34,
      'totalLikes': 412,
      'currentStreak': 12,
      'longestStreak': 28,
      'isOnline': true,
      'isActive': true,
      'lastSeen': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // 4 ek doktor profili
    for (final doc in _mockDoctors) {
      batch.set(
        _db.collection('users').doc(doc['id'] as String),
        {...doc..remove('id'), 'updatedAt': now, 'lastSeen': now},
      );
    }

    await batch.commit();
    debugPrint('[SEEDER] Users seeded');
  }

  // ── Knowledge Hub Vakaları ────────────────────────────────────────

  static Future<void> _seedHubCases() async {
    if (await _hasData('hub_cases')) return;

    // Birleştir: eski temel vakalar + yeni zengin beta-test verileri
    final allCases = [..._hubCases, ...kHubSeedCases];

    // Firestore batch limiti 500; güvenli tarafta kalalım
    final batch = _db.batch();
    for (final c in allCases) {
      final ref = _db.collection('hub_cases').doc(c['id'] as String);
      batch.set(ref, {
        ...c,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Hub cases seeded (${allCases.length} cases)');
  }

  // ── Konsensüs Oylamaları ──────────────────────────────────────────

  static Future<void> _seedPolls(String uid) async {
    if (await _hasData('polls')) return;

    final batch = _db.batch();
    for (final p in _polls) {
      final ref = _db.collection('polls').doc(p['id'] as String);
      batch.set(ref, {
        ...p,
        'authorId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Polls seeded');
  }

  // ── Bildirimler ───────────────────────────────────────────────────

  static Future<void> _seedNotifications(String uid) async {
    final col = _db.collection('notifications').doc(uid).collection('items');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final n in _notifications) {
      final ref = col.doc(n['id'] as String);
      batch.set(ref, {
        ...n,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Notifications seeded');
  }

  // ── Tıbbi Dosyalar ───────────────────────────────────────────────

  static Future<void> _seedMedicalFiles(String uid) async {
    if (await _hasData('medical_files')) return;

    final batch = _db.batch();
    for (final f in _medicalFiles) {
      final ref = _db.collection('medical_files').doc(f['id'] as String);
      batch.set(ref, {
        ...f,
        'uploadedBy': uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Medical files seeded');
  }

  // ── Acil Konsültasyonlar ──────────────────────────────────────────

  static Future<void> _seedEmergencyConsultations(String uid) async {
    if (await _hasData('emergency_consultations')) return;

    final batch = _db.batch();
    for (final ec in _emergencyConsultations) {
      final ref = _db.collection('emergency_consultations').doc(ec['id'] as String);
      batch.set(ref, {
        ...ec,
        'requesterId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Emergency consultations seeded');
  }

  // ── Vaka Atamaları ────────────────────────────────────────────────

  static Future<void> _seedCaseAssignments(String uid) async {
    if (await _hasData('case_assignments')) return;

    final batch = _db.batch();
    for (final a in _caseAssignments) {
      final ref = _db.collection('case_assignments').doc(a['id'] as String);
      batch.set(ref, {
        ...a,
        'assignedTo': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('[SEEDER] Case assignments seeded');
  }

  // ── Analytics user data güncelleme ────────────────────────────────

  static Future<void> _seedAnalyticsData(String uid) async {
    // Mevcut kullanıcı dökümanına analytics alanları ekle
    await _db.collection('users').doc(uid).set({
      'xpHistory': [
        {'month': 'Eki', 'xp': 680},
        {'month': 'Kas', 'xp': 920},
        {'month': 'Ara', 'xp': 1150},
        {'month': 'Oca', 'xp': 870},
        {'month': 'Şub', 'xp': 1340},
        {'month': 'Mar', 'xp': 940},
      ],
    }, SetOptions(merge: true));
    debugPrint('[SEEDER] Analytics data seeded');
  }

  // ── Yardımcı ──────────────────────────────────────────────────────

  static Future<bool> _hasData(String collection) async {
    try {
      final snap = await _db.collection(collection).limit(1).get()
          .timeout(const Duration(seconds: 3));
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SEED DATA
  // ══════════════════════════════════════════════════════════════════

  static final _mockDoctors = [
    {
      'id': 'doc_prof_ayse',
      'displayName': 'Prof. Dr. Ayşe Yılmaz',
      'displayNameLower': 'prof. dr. ayşe yılmaz',
      'specialty': 'Kardiyoloji',
      'role': 'PROFESSOR',
      'xp': 18500, 'level': 12, 'rank': 3,
      'caseCount': 234, 'contributionCount': 678,
      'totalComments': 456, 'acceptedAnswers': 89,
      'totalLikes': 1230, 'currentStreak': 45, 'longestStreak': 90,
      'isOnline': true, 'isActive': true,
      'bio': 'İstanbul Üniversitesi Kardiyoloji ABD, 20 yıllık deneyim.',
      'institution': 'İstanbul Tıp Fakültesi',
      'country': 'TR',
    },
    {
      'id': 'doc_uzm_mehmet',
      'displayName': 'Uzm. Dr. Mehmet Kara',
      'displayNameLower': 'uzm. dr. mehmet kara',
      'specialty': 'Nöroloji',
      'role': 'SPECIALIST',
      'xp': 7800, 'level': 8, 'rank': 28,
      'caseCount': 112, 'contributionCount': 345,
      'totalComments': 267, 'acceptedAnswers': 45,
      'totalLikes': 560, 'currentStreak': 8, 'longestStreak': 35,
      'isOnline': true, 'isActive': true,
      'bio': 'Hacettepe Üniversitesi Nöroloji Uzmanı.',
      'institution': 'Hacettepe Üniversitesi',
      'country': 'TR',
    },
    {
      'id': 'doc_asist_elif',
      'displayName': 'Dr. Elif Demir',
      'displayNameLower': 'dr. elif demir',
      'specialty': 'Dahiliye',
      'role': 'RESIDENT',
      'xp': 2100, 'level': 3, 'rank': 156,
      'caseCount': 28, 'contributionCount': 89,
      'totalComments': 67, 'acceptedAnswers': 8,
      'totalLikes': 134, 'currentStreak': 5, 'longestStreak': 14,
      'isOnline': false, 'isActive': true,
      'bio': 'Ankara Üniversitesi Dahiliye Asistanı.',
      'institution': 'Ankara Üniversitesi',
      'country': 'TR',
    },
    {
      'id': 'doc_intern_ali',
      'displayName': 'Ali Öztürk',
      'displayNameLower': 'ali öztürk',
      'specialty': 'Tıp Fakültesi 6. Sınıf',
      'role': 'INTERN',
      'xp': 450, 'level': 1, 'rank': 523,
      'caseCount': 5, 'contributionCount': 18,
      'totalComments': 12, 'acceptedAnswers': 1,
      'totalLikes': 23, 'currentStreak': 2, 'longestStreak': 7,
      'isOnline': true, 'isActive': true,
      'bio': 'Cerrahpaşa Tıp Fakültesi 6. sınıf intern.',
      'institution': 'Cerrahpaşa Tıp Fakültesi',
      'country': 'TR',
    },
  ];

  static final _hubCases = [
    {
      'id': 'hub_001',
      'title': 'STEMI Yönetiminde Güncel Yaklaşımlar',
      'abstract': 'Akut ST elevasyonlu miyokard infarktüsünde '
          'reperfüzyon stratejileri ve zaman yönetimi.',
      'content': 'ST elevasyonlu miyokard infarktüsü (STEMI), koroner arterin '
          'tam tıkanması sonucu gelişen akut bir kardiyovasküler acildir...',
      'category': 'Kılavuz Özeti',
      'specialty': 'Kardiyoloji',
      'difficulty': 'Orta',
      'authorId': 'doc_prof_ayse',
      'authorName': 'Prof. Dr. Ayşe Yılmaz',
      'authorSpecialty': 'Kardiyoloji',
      'tags': ['STEMI', 'ACS', 'Reperfüzyon', 'Kardiyoloji'],
      'searchTokens': ['stemi', 'acs', 'reperfüzyon', 'kardiyoloji', 'miyokard'],
      'likeCount': 87, 'viewCount': 342, 'commentCount': 23,
      'isPinned': true, 'isApproved': true,
    },
    {
      'id': 'hub_002',
      'title': 'Akut İnme: İlk 60 Dakika',
      'abstract': 'Akut iskemik inmede altın saat yönetimi, '
          'tromboliz endikasyonları ve kontrendikasyonlar.',
      'content': 'Akut iskemik inme, beyin kan akımının ani kesilmesi sonucu '
          'gelişen nörolojik bir acil durumdur. İlk 60 dakika kritiktir...',
      'category': 'Vaka Çalışması',
      'specialty': 'Nöroloji',
      'difficulty': 'İleri',
      'authorId': 'doc_uzm_mehmet',
      'authorName': 'Uzm. Dr. Mehmet Kara',
      'authorSpecialty': 'Nöroloji',
      'tags': ['İnme', 'Tromboliz', 'Nöroloji', 'Acil'],
      'searchTokens': ['inme', 'stroke', 'tromboliz', 'nöroloji', 'acil'],
      'likeCount': 65, 'viewCount': 289, 'commentCount': 18,
      'isPinned': false, 'isApproved': true,
    },
    {
      'id': 'hub_003',
      'title': 'Sepsis-3 Tanı Kriterleri ve qSOFA',
      'abstract': 'Sepsis-3 tanım değişiklikleri, qSOFA skoru '
          've erken tanıda pratik yaklaşımlar.',
      'content': 'Sepsis-3 tanımı 2016 yılında güncellenerek enfeksiyona karşı '
          'düzensiz konak yanıtı olarak tanımlanmıştır...',
      'category': 'Kılavuz Özeti',
      'specialty': 'Enfeksiyon Hastalıkları',
      'difficulty': 'Başlangıç',
      'authorId': 'doc_prof_ayse',
      'authorName': 'Prof. Dr. Ayşe Yılmaz',
      'authorSpecialty': 'Kardiyoloji',
      'tags': ['Sepsis', 'qSOFA', 'Enfeksiyon', 'Yoğun Bakım'],
      'searchTokens': ['sepsis', 'qsofa', 'enfeksiyon', 'yoğun bakım'],
      'likeCount': 112, 'viewCount': 567, 'commentCount': 34,
      'isPinned': true, 'isApproved': true,
    },
    {
      'id': 'hub_004',
      'title': 'Diyabetik Ketoasidoz: Adım Adım Tedavi',
      'abstract': 'DKA yönetiminde sıvı replasmanı, insülin infüzyonu '
          've elektrolit takibi protokolü.',
      'content': 'Diyabetik ketoasidoz (DKA), insülin eksikliği ve karşı-düzenleyici '
          'hormonların artışı sonucu ortaya çıkan metabolik bir acildir...',
      'category': 'Tedavi Protokolü',
      'specialty': 'Endokrinoloji',
      'difficulty': 'Orta',
      'authorId': 'doc_asist_elif',
      'authorName': 'Dr. Elif Demir',
      'authorSpecialty': 'Dahiliye',
      'tags': ['DKA', 'Diyabet', 'Endokrinoloji', 'Acil'],
      'searchTokens': ['dka', 'diyabet', 'ketoasidoz', 'endokrinoloji'],
      'likeCount': 45, 'viewCount': 198, 'commentCount': 11,
      'isPinned': false, 'isApproved': true,
    },
  ];

  static final _polls = [
    {
      'id': 'poll_001',
      'caseRef': 'KX-2024-0045',
      'question': '58y/E STEMI hastasında tercih edilen reperfüzyon stratejisi?',
      'specialty': 'Kardiyoloji',
      'options': [
        {'label': 'Primer PKG (< 120 dk)', 'voteCount': 67, 'rationale': 'ACC/AHA Klass I'},
        {'label': 'Fibrinolitik tedavi', 'voteCount': 12, 'rationale': 'PKG mümkün değilse'},
        {'label': 'CABG', 'voteCount': 3, 'rationale': 'Çoklu damar hastalığı varsa'},
      ],
      'expertComment': 'Door-to-balloon süresi < 90 dk ise primer PKG altın standarttır.',
      'expertName': 'Prof. Dr. Ayşe Yılmaz',
      'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'status': 'open',
      'totalVotes': 82,
    },
    {
      'id': 'poll_002',
      'caseRef': 'KX-2024-0046',
      'question': 'Akut iskemik inmede tromboliz için zaman penceresi?',
      'specialty': 'Nöroloji',
      'options': [
        {'label': '< 3 saat (IV tPA)', 'voteCount': 45, 'rationale': 'AHA/ASA Klass I'},
        {'label': '3-4.5 saat (genişletilmiş)', 'voteCount': 38, 'rationale': 'ECASS III'},
        {'label': '< 6 saat (mekanik trombektomi)', 'voteCount': 29, 'rationale': 'MR CLEAN'},
        {'label': '< 24 saat (DAWN/DEFUSE)', 'voteCount': 15, 'rationale': 'Perfüzyon uyumsuzluğu'},
      ],
      'deadline': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
      'status': 'open',
      'totalVotes': 127,
    },
  ];

  static final _notifications = [
    {
      'id': 'notif_001',
      'type': 'case_assigned',
      'title': 'Yeni vaka atandı',
      'body': 'Prof. Dr. Ayşe Yılmaz size bir kardiyoloji vakası atadı.',
      'data': {'caseId': 'KX-2024-0045', 'assignmentId': 'assign_001'},
      'isRead': false,
    },
    {
      'id': 'notif_002',
      'type': 'comment',
      'title': 'Vakanıza yorum geldi',
      'body': 'Uzm. Dr. Mehmet Kara diferansiyel tanı önerisi ekledi.',
      'data': {'caseId': 'KX-2024-0046'},
      'isRead': false,
    },
    {
      'id': 'notif_003',
      'type': 'like',
      'title': 'Katkınız beğenildi',
      'body': 'STEMI vakasındaki yorumunuz 5 doktor tarafından beğenildi.',
      'data': {'caseId': 'KX-2024-0045'},
      'isRead': true,
    },
    {
      'id': 'notif_004',
      'type': 'system',
      'title': 'Seviye atladınız!',
      'body': 'Tebrikler! Seviye 7\'ye ulaştınız. Yeni rozetiniz: Uzman Klinisyen',
      'data': {},
      'isRead': true,
    },
    {
      'id': 'notif_005',
      'type': 'poll',
      'title': 'Yeni konsensüs oylaması',
      'body': 'STEMI reperfüzyon stratejisi hakkında görüşünüz bekleniyor.',
      'data': {'pollId': 'poll_001'},
      'isRead': false,
    },
  ];

  static final _medicalFiles = [
    {
      'id': 'mf_001',
      'originalName': 'tam_kan_sayimi.pdf',
      'fileName': 'lab_tks_20240315.pdf',
      'mimeType': 'application/pdf',
      'size': 245000,
      'category': 'lab_result',
      'fileUrl': 'https://storage.example.com/mock/tks.pdf',
      'notes': 'Hemoglobin düşük, lökosit normal',
      'caseId': 'KX-2024-0045',
    },
    {
      'id': 'mf_002',
      'originalName': 'akciger_pa.jpg',
      'fileName': 'xray_pa_20240315.jpg',
      'mimeType': 'image/jpeg',
      'size': 1200000,
      'category': 'xray',
      'fileUrl': 'https://storage.example.com/mock/xray.jpg',
      'width': 2048, 'height': 2048,
      'notes': 'Bilateral infiltrasyon mevcut',
    },
    {
      'id': 'mf_003',
      'originalName': 'beyin_bt.jpg',
      'fileName': 'ct_brain_20240316.jpg',
      'mimeType': 'image/jpeg',
      'size': 3500000,
      'category': 'ct',
      'fileUrl': 'https://storage.example.com/mock/ct.jpg',
      'width': 512, 'height': 512,
      'caseId': 'KX-2024-0046',
      'notes': 'MCA sulama alanında hipodens lezyon',
    },
    {
      'id': 'mf_004',
      'originalName': 'ekg_12_derivasyon.jpg',
      'fileName': 'ecg_12lead_20240315.jpg',
      'mimeType': 'image/jpeg',
      'size': 890000,
      'category': 'ecg',
      'fileUrl': 'https://storage.example.com/mock/ecg.jpg',
      'width': 1600, 'height': 900,
      'caseId': 'KX-2024-0045',
      'notes': 'V1-V4 anterior ST elevasyonu',
    },
    {
      'id': 'mf_005',
      'originalName': 'lomber_mr.jpg',
      'fileName': 'mri_lomber_20240317.jpg',
      'mimeType': 'image/jpeg',
      'size': 4200000,
      'category': 'mri',
      'fileUrl': 'https://storage.example.com/mock/mri.jpg',
      'width': 512, 'height': 512,
      'notes': 'L4-L5 disk hernisi',
    },
    {
      'id': 'mf_006',
      'originalName': 'abdominal_usg.jpg',
      'fileName': 'usg_abd_20240318.jpg',
      'mimeType': 'image/jpeg',
      'size': 1800000,
      'category': 'ultrasound',
      'fileUrl': 'https://storage.example.com/mock/usg.jpg',
      'width': 800, 'height': 600,
      'notes': 'Safra kesesi içinde multiple taş',
    },
  ];

  static final _emergencyConsultations = [
    {
      'id': 'ec_001',
      'requesterName': 'Dr. Elif Demir',
      'requesterSpecialty': 'Dahiliye',
      'priority': 'critical',
      'status': 'inProgress',
      'targetSpecialty': 'Kardiyoloji',
      'title': 'Masif STEMI — acil PKG kararı',
      'clinicalSummary': '58y/E, 45 dk önce başlayan retrosternal ağrı. '
          'EKG: V1-V4 anterior ST elevasyonu. Troponin T: 2.4 ng/mL.',
      'patient': {
        'age': 58, 'gender': 'Erkek',
        'chiefComplaint': 'Retrosternal göğüs ağrısı',
        'vitals': {'TA': '90/60', 'Nabız': '110', 'SpO2': '91%', 'Ateş': '36.8°C'},
        'activeConditions': ['HT', 'DM Tip 2', 'Hiperlipidemi'],
        'currentMedications': ['Metformin 1000mg', 'Amlodipin 5mg', 'Atorvastatin 20mg'],
      },
      'imageUrls': [],
      'responses': [
        {
          'id': 'resp_001',
          'responderId': 'doc_prof_ayse',
          'responderName': 'Prof. Dr. Ayşe Yılmaz',
          'responderSpecialty': 'Kardiyoloji',
          'responderLevel': 12,
          'content': 'Anterior STEMI ile uyumlu. Dual antiplatelet başlanmalı, '
              'acil primer PKG planlanmalı. Door-to-balloon < 90 dk hedeflenmeli.',
          'recommendedAction': 'Acil kateterizasyon',
          'suggestedTests': ['Troponin seri', 'Eko', 'Tam kan', 'BNP'],
          'isAccepted': true,
          'responseTimeSeconds': 180,
          'xpEarned': 150,
        }
      ],
      'viewCount': 12,
    },
    {
      'id': 'ec_002',
      'requesterName': 'Dr. Ali Öztürk',
      'requesterSpecialty': 'Acil Tıp',
      'priority': 'lifeThreatening',
      'status': 'pending',
      'targetSpecialty': 'Nöroloji',
      'title': 'Ani bilinç kaybı — İnme şüphesi',
      'clinicalSummary': '72y/K, 30 dk önce ani sol taraflı güçsüzlük. '
          'GKS: E3V4M5. Sol hemipleji, santral fasiyal paralizi.',
      'patient': {
        'age': 72, 'gender': 'Kadın',
        'chiefComplaint': 'Ani bilinç bulanıklığı, sol taraf güçsüzlük',
        'vitals': {'TA': '185/110', 'Nabız': '88 (AF)', 'SpO2': '94%', 'Ateş': '37.2°C'},
        'activeConditions': ['AF', 'HT', 'DM Tip 2'],
        'currentMedications': ['Warfarin', 'Metoprolol 50mg', 'Metformin 1000mg'],
      },
      'imageUrls': [],
      'responses': [],
      'viewCount': 3,
    },
  ];

  static final _caseAssignments = [
    {
      'id': 'assign_001',
      'caseId': 'KX-2024-0045',
      'caseTitle': '58y/E — ST elevasyonlu göğüs ağrısı',
      'caseSpecialty': 'Kardiyoloji',
      'assignedToName': 'Dr. Kerem Çelik',
      'assignedBy': 'doc_prof_ayse',
      'assignedByName': 'Prof. Dr. Ayşe Yılmaz',
      'assignedByTitle': 'Prof. Dr.',
      'status': 'pending',
      'notes': 'Diferansiyel tanı listesi hazırlayın ve tedavi planı önerin.',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
    },
    {
      'id': 'assign_002',
      'caseId': 'KX-2024-0046',
      'caseTitle': '45y/K — Sol hemiparezi, afazi',
      'caseSpecialty': 'Nöroloji',
      'assignedToName': 'Dr. Kerem Çelik',
      'assignedBy': 'doc_uzm_mehmet',
      'assignedByName': 'Uzm. Dr. Mehmet Kara',
      'assignedByTitle': 'Uzm. Dr.',
      'status': 'in_progress',
      'notes': 'NIHSS skorunu hesaplayın ve tromboliz endikasyonlarını değerlendirin.',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
    },
    {
      'id': 'assign_003',
      'caseId': 'KX-2024-0047',
      'caseTitle': '32y/E — Ateş, hipotansiyon, bilinç bulanıklığı',
      'caseSpecialty': 'Enfeksiyon Hastalıkları',
      'assignedToName': 'Dr. Kerem Çelik',
      'assignedBy': 'doc_prof_ayse',
      'assignedByName': 'Prof. Dr. Ayşe Yılmaz',
      'assignedByTitle': 'Prof. Dr.',
      'status': 'completed',
      'notes': 'qSOFA ve SOFA skorlarını hesaplayarak sepsis yönetimi önerin.',
    },
  ];
}
