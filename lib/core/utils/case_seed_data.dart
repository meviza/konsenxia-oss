import 'package:cloud_firestore/cloud_firestore.dart';

/// KONSENXIA — Örnek Tıbbi Vaka Seed Data
///
/// Debug modda Firestore'a 6 örnek tıbbi vaka yükler.
/// Kullanım: `await CaseSeedData.seed()`
///
/// Sadece 'cases' koleksiyonu boşsa seed eder (tekrar tekrar eklememek için).
class CaseSeedData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _collection = 'cases';

  /// 6 örnek vakayı Firestore'a yazar. Koleksiyon boşsa çalışır.
  static Future<void> seed({bool force = false}) async {
    try {
      final existing = await _db.collection(_collection).limit(1).get();
      if (existing.docs.isNotEmpty && !force) {
        return; // Zaten veri var
      }

      final batch = _db.batch();
      for (final data in _sampleCases) {
        final ref = _db.collection(_collection).doc(data['id'] as String);
        batch.set(ref, {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      // Seed hatası sessizce yoksayılır — uygulama çalışmaya devam eder
    }
  }

  static final List<Map<String, dynamic>> _sampleCases = [
    {
      'id': 'KX-2024-0045',
      'title': '58y/E — ST elevasyonlu göğüs ağrısı: ACS mi?',
      'patientSummary':
          '58 yaşında erkek hasta, 2 saattir süren eziyet verici göğüs ağrısı ile acile başvurdu.',
      'description':
          'Hasta 58 yaşında erkek, hipertansiyon ve tip 2 DM öyküsü mevcut. '
          '2 saattir substernal, sol kola vuran şiddetli göğüs ağrısı tanımlıyor. '
          'EKG\'de II, III, aVF derivasyonlarında ST elevasyonu (2mm). '
          'Troponin I: 1.8 ng/mL (yüksek). KB: 85/50 mmHg. Nabız: 112/dk, düzensiz. '
          'STEMI tanısı konuldu; acil perkütan koroner girişim (PKG) planlandı. '
          'Kardiojenik şok tablosunda antikoagülasyon ve inotropik destek başlandı.',
      'specialty': 'Kardiyoloji',
      'urgency': 'critical',
      'status': 'in_discussion',
      'authorId': 'seed-author-1',
      'authorName': 'Uzm. Dr. Ayşe Kara',
      'authorSpecialty': 'Kardiyoloji',
      'authorCountry': 'TR',
      'authorLevel': 9,
      'tags': ['STEMI', 'ACS', 'PKG', 'Kardiojenik Şok'],
      'specialties': ['Kardiyoloji', 'Acil Tıp'],
      'vitals': [
        {'label': 'KB', 'value': '85/50', 'unit': 'mmHg', 'range': 'critical'},
        {'label': 'Nabız', 'value': '112', 'unit': '/dk', 'range': 'warning'},
        {'label': 'SpO2', 'value': '91', 'unit': '%', 'range': 'critical'},
        {'label': 'Ateş', 'value': '36.8', 'unit': '°C', 'range': 'normal'},
      ],
      'xpReward': {'xpForComment': 30, 'xpForAcceptedAnswer': 150, 'xpForAuthor': 80},
      'viewCount': 541,
      'likeCount': 47,
      'bookmarkCount': 23,
      'commentCount': 21,
      'isSolved': false,
      'isFeatured': true,
    },
    {
      'id': 'KX-2024-0046',
      'title': '45y/K — Ani baş ağrısı + sol hemipleji: İnme şüphesi',
      'patientSummary':
          '45 yaşında kadın hasta, ani başlayan şiddetli baş ağrısı ve sol vücut yarısında güçsüzlük ile başvurdu.',
      'description':
          'Hasta 45 yaşında kadın, sigara içici (20 paket-yıl), oral kontraseptif kullanıcısı. '
          'Sabah uyanırken sol hemipleji fark etmiş. "Hayatımın en kötü baş ağrısı" tarif ediyor. '
          'BT\'de sağ orta serebral arter sulama alanında hipodens alan. '
          'NIHSS skoru: 14. Son görüldüğü saat: 6 saat önce. '
          'tPA için zaman penceresi geçmiş; trombektomi endikasyonu değerlendiriliyor. '
          'Antiplatelet tedavi, statin ve antihipertansif başlandı.',
      'specialty': 'Nöroloji',
      'urgency': 'emergency',
      'status': 'open',
      'authorId': 'seed-author-2',
      'authorName': 'Doç. Dr. Mehmet Aydın',
      'authorSpecialty': 'Nöroloji',
      'authorCountry': 'TR',
      'authorLevel': 11,
      'tags': ['İnme', 'Hemipleji', 'tPA', 'Trombektomi'],
      'specialties': ['Nöroloji', 'Acil Tıp', 'Radyoloji'],
      'vitals': [
        {'label': 'KB', 'value': '178/102', 'unit': 'mmHg', 'range': 'critical'},
        {'label': 'Nabız', 'value': '88', 'unit': '/dk', 'range': 'normal'},
        {'label': 'SpO2', 'value': '96', 'unit': '%', 'range': 'normal'},
        {'label': 'GKS', 'value': '13', 'unit': '/15', 'range': 'warning'},
      ],
      'xpReward': {'xpForComment': 40, 'xpForAcceptedAnswer': 200, 'xpForAuthor': 100},
      'viewCount': 389,
      'likeCount': 62,
      'bookmarkCount': 31,
      'commentCount': 17,
      'isSolved': false,
      'isFeatured': false,
    },
    {
      'id': 'KX-2024-0047',
      'title': '32y/E — Ateş, hipotansiyon, konfüzyon: Sepsis odağı nerede?',
      'patientSummary':
          '32 yaşında erkek hasta, 3 gündür süren ateş, bugün hipotansiyon ve konfüzyon eklenmesiyle yoğun bakıma alındı.',
      'description':
          'Hasta 32 yaşında erkek, özgeçmişinde tip 1 DM. '
          'KB: 78/42 mmHg, nabız: 128/dk, ateş: 39.4°C. '
          'Laktat: 4.2 mmol/L. WBC: 22.000 (sola kayma). CRP: 342. PCT: 8.7 ng/mL. '
          'Akciğer grafisinde sol alt lob konsolidasyon. '
          'Septic shock tanısıyla yoğun bakıma alındı; geniş spektrumlu antibiyotik, '
          'agresif IV sıvı resüsitasyonu ve norepinefrin infüzyonu başlandı. '
          'Kan kültürleri bekleniyor; beta-D-glukan ve galaktomannan gönderildi.',
      'specialty': 'Enfeksiyon Hastalıkları',
      'urgency': 'critical',
      'status': 'in_discussion',
      'authorId': 'seed-author-3',
      'authorName': 'Dr. Selin Kaya',
      'authorSpecialty': 'Enfeksiyon Hastalıkları',
      'authorCountry': 'TR',
      'authorLevel': 7,
      'tags': ['Sepsis', 'Septic Shock', 'Laktat', 'Norepinefrin'],
      'specialties': ['Enfeksiyon Hastalıkları', 'Yoğun Bakım'],
      'vitals': [
        {'label': 'KB', 'value': '78/42', 'unit': 'mmHg', 'range': 'critical'},
        {'label': 'Nabız', 'value': '128', 'unit': '/dk', 'range': 'critical'},
        {'label': 'Ateş', 'value': '39.4', 'unit': '°C', 'range': 'critical'},
        {'label': 'Laktat', 'value': '4.2', 'unit': 'mmol/L', 'range': 'critical'},
      ],
      'xpReward': {'xpForComment': 35, 'xpForAcceptedAnswer': 180, 'xpForAuthor': 90},
      'viewCount': 312,
      'likeCount': 28,
      'bookmarkCount': 14,
      'commentCount': 14,
      'isSolved': false,
      'isFeatured': false,
    },
    {
      'id': 'KX-2024-0048',
      'title': '22y/K — DKA, bilinç bulanıklığı: İnsülin protokolü?',
      'patientSummary':
          '22 yaşında kadın hasta, bilinen Tip 1 DM, 6 saattir bulantı-kusma ve bilinç bulanıklığıyla başvurdu.',
      'description':
          'Hasta 22 yaşında kadın, Tip 1 DM (8 yıllık). '
          'İnsülin pompa arızası sonrası insülin almamış. '
          'Glukoz: 492 mg/dL. pH: 7.08. Bikarbonat: 8. Keton: ++++. Anyon gap: 28. '
          'GKS: 12/15. EKG\'de düzleşmiş T dalgaları (hipokalemi). '
          'DKA protokolü başlandı: IV salin, insülin infüzyonu, K+ replasmanı. '
          'Beyin ödemi riski açısından sıvı hızı takibi yapılıyor. '
          'İlk 2 saatte K+ 2.8 mEq/L\'ye düştü; replasmanın yeterliliği sorgulanıyor.',
      'specialty': 'Endokrinoloji',
      'urgency': 'urgent',
      'status': 'open',
      'authorId': 'seed-author-4',
      'authorName': 'Dr. Zeynep Arslan',
      'authorSpecialty': 'Endokrinoloji',
      'authorCountry': 'TR',
      'authorLevel': 6,
      'tags': ['DKA', 'Tip 1 DM', 'Hipokalemi', 'İnsülin'],
      'specialties': ['Endokrinoloji', 'Yoğun Bakım'],
      'vitals': [
        {'label': 'Glukoz', 'value': '492', 'unit': 'mg/dL', 'range': 'critical'},
        {'label': 'pH', 'value': '7.08', 'unit': '', 'range': 'critical'},
        {'label': 'K+', 'value': '2.8', 'unit': 'mEq/L', 'range': 'critical'},
        {'label': 'GKS', 'value': '12', 'unit': '/15', 'range': 'warning'},
      ],
      'xpReward': {'xpForComment': 25, 'xpForAcceptedAnswer': 120, 'xpForAuthor': 70},
      'viewCount': 278,
      'likeCount': 41,
      'bookmarkCount': 19,
      'commentCount': 23,
      'isSolved': false,
      'isFeatured': false,
    },
    {
      'id': 'KX-2024-0049',
      'title': '19y/E — Politravma, motorlu taşıt kazası: Damage control mi?',
      'patientSummary':
          '19 yaşında erkek hasta, yüksek hızlı motorlu taşıt kazası sonrası acile getirildi.',
      'description':
          'Hasta 19 yaşında erkek, trafik kazası sonrası ambulansla getirildi. '
          'GKS: 13/15. Bilateral femur fraktürü, sol pnömotoraks (tüp torakostomi yapıldı). '
          'FAST US: Batın içi serbest sıvı (perihepatik). '
          'KB: 88/56 mmHg (masif transfüzyon protokolü başlandı). '
          'Hemoglobin: 7.2 g/dL, INR: 1.9. '
          'Damage control cerrahisi vs. erken total care tartışması var. '
          'Travma cerrahi, ortopedi ve anestezi ekipleri multidisipliner toplanıyor.',
      'specialty': 'Acil Tıp',
      'urgency': 'emergency',
      'status': 'open',
      'authorId': 'seed-author-5',
      'authorName': 'Dr. Emre Yılmaz',
      'authorSpecialty': 'Acil Tıp',
      'authorCountry': 'TR',
      'authorLevel': 5,
      'tags': ['Politravma', 'Damage Control', 'Hemotoraks', 'Masif Transfüzyon'],
      'specialties': ['Acil Tıp', 'Genel Cerrahi', 'Ortopedi'],
      'vitals': [
        {'label': 'KB', 'value': '88/56', 'unit': 'mmHg', 'range': 'critical'},
        {'label': 'Nabız', 'value': '136', 'unit': '/dk', 'range': 'critical'},
        {'label': 'Hgb', 'value': '7.2', 'unit': 'g/dL', 'range': 'critical'},
        {'label': 'GKS', 'value': '13', 'unit': '/15', 'range': 'warning'},
      ],
      'xpReward': {'xpForComment': 30, 'xpForAcceptedAnswer': 160, 'xpForAuthor': 85},
      'viewCount': 421,
      'likeCount': 38,
      'bookmarkCount': 17,
      'commentCount': 19,
      'isSolved': false,
      'isFeatured': false,
    },
    {
      'id': 'KX-2024-0050',
      'title': '65y/E — Ani dispne, sağ alt lob PE şüphesi: Antikoagülasyon?',
      'patientSummary':
          '65 yaşında erkek hasta, 3 saattir ani başlayan dispne ve sağ plöritik göğüs ağrısı ile başvurdu.',
      'description':
          'Hasta 65 yaşında erkek, 2 hafta önce sağ diz protezi ameliyatı geçirmiş. '
          'Sağ bacakta şişlik ve ısı artışı mevcut. D-dimer: 4800 ng/mL. '
          'Wells skoru: 6 (yüksek olasılık). SpO2: %88 (oda havasında). '
          'BT pulmoner anjiyografi yapılıyor; beklerken antikoagülasyon başlanmalı mı? '
          'Hemoraji riski düşük (post-op 14. gün). '
          'BT anjio: Sağ ana pulmoner arterde filling defekti — masif PE. '
          'Sistolik KB: 82 mmHg — hemodinamik instabilite. Trombolitik uygulandı.',
      'specialty': 'Göğüs Hastalıkları',
      'urgency': 'critical',
      'status': 'solved',
      'authorId': 'seed-author-6',
      'authorName': 'Prof. Dr. Aynur Başkaya',
      'authorSpecialty': 'Göğüs Hastalıkları',
      'authorCountry': 'TR',
      'authorLevel': 14,
      'tags': ['Pulmoner Emboli', 'Wells', 'Trombolitik', 'DVT'],
      'specialties': ['Göğüs Hastalıkları', 'Kardiyoloji', 'Acil Tıp'],
      'vitals': [
        {'label': 'KB', 'value': '82/50', 'unit': 'mmHg', 'range': 'critical'},
        {'label': 'SpO2', 'value': '88', 'unit': '%', 'range': 'critical'},
        {'label': 'Nabız', 'value': '118', 'unit': '/dk', 'range': 'critical'},
        {'label': 'D-dimer', 'value': '4800', 'unit': 'ng/mL', 'range': 'critical'},
      ],
      'xpReward': {'xpForComment': 20, 'xpForAcceptedAnswer': 100, 'xpForAuthor': 60},
      'diagnosisTitle': 'Masif Pulmoner Emboli — Sistolik Instabilite',
      'diagnosisDetails':
          'BT-PA\'da sağ ana pulmoner arterde filling defekti. '
          'Hemodinamik instabilite nedeniyle sistemik trombolitik (alteplaz 100mg/2h) uygulandı. '
          'Tedavi sonrası KB: 118/74 mmHg, SpO2: %95.',
      'viewCount': 334,
      'likeCount': 52,
      'bookmarkCount': 26,
      'commentCount': 24,
      'isSolved': true,
      'isFeatured': false,
    },
  ];
}
