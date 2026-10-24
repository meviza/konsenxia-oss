import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final Dio _dio = GetIt.instance<Dio>();
  final List<DiagnosisSession> _history = [];

  @override
  Future<DiagnosisResult> analyzeDifferentialDiagnosis(
      DiagnosisInput input) async {
    try {
      final res = await _dio.post(
        '/api/v1/medical-ai/differential-diagnosis',
        data: {
          'patientAge': input.patientAge,
          'patientGender': input.patientGender,
          'chiefComplaint': input.chiefComplaint,
          'symptoms': input.symptoms,
          'negativeFindings': input.negativeFindings,
          'duration': input.symptomDuration,
          'onset': input.symptomOnset,
          'vitals': input.vitals,
          'pastHistory': input.pastHistory,
          'medications': input.medications,
          'familyHistory': input.familyHistory,
          'specialty': input.targetSpecialty,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        return _parseResult(res.data);
      }
    } catch (_) {}

    // Mock fallback
    await Future.delayed(const Duration(seconds: 2));
    return _getMockResult(input);
  }

  @override
  Future<List<DiagnosisSession>> getHistory(String userId) async {
    return _history.where((s) => s.userId == userId).toList();
  }

  @override
  Future<void> saveSession(DiagnosisSession session) async {
    _history.insert(0, session);
  }

  @override
  Future<List<String>> getSuggestedSymptoms(String chiefComplaint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _symptomSuggestions(chiefComplaint);
  }

  DiagnosisResult _parseResult(Map<String, dynamic> data) {
    // Try to parse real API response
    try {
      final diffs = (data['differentials'] as List?)
              ?.asMap()
              .entries
              .map((e) => DifferentialItem(
                    rank: e.key + 1,
                    diagnosis: e.value['diagnosis'] ?? '',
                    probability: (e.value['probability'] ?? 0).toDouble(),
                    reasoning: e.value['reasoning'] ?? '',
                    icdCode: e.value['icdCode'] ?? '',
                  ))
              .toList() ??
          [];

      return DiagnosisResult(
        differentials: diffs,
        recommendedTests: [],
        riskFactors: [],
        clinicalComment: data['clinicalComment'] ?? '',
        aiSource: data['source'] ?? 'api',
        processingMs: data['processingMs'] ?? 0,
        confidenceScore: (data['confidence'] ?? 0.7).toDouble(),
      );
    } catch (_) {
      return const DiagnosisResult(
        differentials: [],
        recommendedTests: [],
        riskFactors: [],
        clinicalComment: 'Sonuc islenemedi',
        aiSource: 'error',
        processingMs: 0,
      );
    }
  }

  DiagnosisResult _getMockResult(DiagnosisInput input) {
    final cc = input.chiefComplaint.toLowerCase();

    if (cc.contains('gogus') || cc.contains('chest')) {
      return _chestPainResult(input);
    }
    if (cc.contains('bas agri') || cc.contains('headache') || cc.contains('bas ')) {
      return _headacheResult(input);
    }
    if (cc.contains('karin') || cc.contains('abdominal')) {
      return _abdominalPainResult(input);
    }
    if (cc.contains('nefes') || cc.contains('dyspnea') || cc.contains('dispne')) {
      return _dyspneaResult(input);
    }
    return _genericResult(input);
  }

  DiagnosisResult _chestPainResult(DiagnosisInput input) {
    final age = input.patientAge;
    final hasRisk = age > 45 ||
        input.pastHistory.any((h) =>
            h.toLowerCase().contains('ht') ||
            h.toLowerCase().contains('dm') ||
            h.toLowerCase().contains('sigara'));

    return DiagnosisResult(
      differentials: [
        DifferentialItem(
          rank: 1,
          diagnosis: 'Akut Koroner Sendrom (AKS)',
          probability: hasRisk ? 0.45 : 0.25,
          reasoning: hasRisk
              ? 'Yas ve risk faktorleri (HT, DM, sigara) AKS olasiligini artiriyor. '
                  'Retrosternal agri, terleme ve bulanti tipik AKS prezentasyonu.'
              : 'Risk faktorleri sinirli ancak klinik tablo ile uyumlu.',
          supportingFindings: ['Retrosternal agri', 'Terleme', 'Bulanti', 'Risk faktorleri'],
          againstFindings: ['Genc yas', 'Normal EKG'],
          icdCode: 'I21.9',
        ),
        DifferentialItem(
          rank: 2,
          diagnosis: 'Pulmoner Emboli',
          probability: 0.20,
          reasoning: 'Ani baslayan gogus agrisi ve dispne ile uyumlu. Immobilizasyon oykusu sorgulanmali.',
          supportingFindings: ['Ani baslangic', 'Dispne', 'Takipne'],
          againstFindings: ['Tipik ploritik agri yok'],
          icdCode: 'I26.9',
        ),
        DifferentialItem(
          rank: 3,
          diagnosis: 'Pnomotoraks',
          probability: 0.10,
          reasoning: 'Ani baslayan gogus agrisi ve nefes darligi ile uyumlu, ozellikle genc erkeklerde.',
          supportingFindings: ['Ani baslangic', 'Tek tarafli agri'],
          againstFindings: ['Bilateral solunum sesleri normal'],
          icdCode: 'J93.9',
        ),
        DifferentialItem(
          rank: 4,
          diagnosis: 'Gastroozofageal Reflu (GORH)',
          probability: 0.15,
          reasoning: 'Retrosternal yanma hissi ile karisan gogus agrisi. Pozisyonel ozellikleri sorgulanmali.',
          supportingFindings: ['Retrosternal lokalizasyon', 'Bulanti'],
          againstFindings: ['Eforla artis', 'Terleme'],
          icdCode: 'K21.0',
        ),
        DifferentialItem(
          rank: 5,
          diagnosis: 'Kostokondrit',
          probability: 0.10,
          reasoning: 'Genc hastalarda sik gorulen, palpasyonla artan gogus agrisi nedeni.',
          supportingFindings: ['Lokalize agri', 'Palpasyonla hassasiyet'],
          againstFindings: ['Sistemik semptomlar', 'EKG degisikligi'],
          icdCode: 'M94.0',
        ),
      ],
      recommendedTests: [
        const RecommendedTest(
          name: '12 derivasyonlu EKG',
          priority: TestPriority.stat,
          rationale: 'AKS ekarte etmek icin ilk basamak',
          expectedFinding: 'ST degisiklikleri, Q dalgasi, T inversiyonu',
          category: 'Kardiyoloji',
        ),
        const RecommendedTest(
          name: 'Troponin I/T (seri)',
          priority: TestPriority.stat,
          rationale: 'Miyokard hasarini gostermek icin',
          expectedFinding: 'AKS\'de yukselme (>0.04 ng/mL)',
          category: 'Laboratuvar',
        ),
        const RecommendedTest(
          name: 'D-Dimer',
          priority: TestPriority.urgent,
          rationale: 'Pulmoner emboli taramasinda',
          expectedFinding: 'PE\'de >500 ng/mL',
          category: 'Laboratuvar',
        ),
        const RecommendedTest(
          name: 'PA Akciger Grafisi',
          priority: TestPriority.urgent,
          rationale: 'Pnomotoraks, plevral efuzyon, kardiyomegali degerlendirmesi',
          expectedFinding: 'Pnomotoraksta apikal hava',
          category: 'Goruntuleme',
        ),
        const RecommendedTest(
          name: 'Tam Kan Sayimi + CRP',
          priority: TestPriority.routine,
          rationale: 'Enfeksiyon ve anemi taramasi',
          expectedFinding: 'Enfeksiyonda lokositoz',
          category: 'Laboratuvar',
        ),
      ],
      riskFactors: [
        if (age > 45)
          RiskFactor(
            factor: 'Yas > 45',
            level: RiskLevel.moderate,
            explanation: 'Kardiyovaskuler risk artar',
          ),
        if (input.pastHistory.any((h) => h.toLowerCase().contains('dm')))
          const RiskFactor(
            factor: 'Diabetes Mellitus',
            level: RiskLevel.high,
            explanation: 'Sessiz iskemi riski. Atipik prezentasyon gorulebilir.',
          ),
        if (input.pastHistory.any((h) => h.toLowerCase().contains('ht')))
          const RiskFactor(
            factor: 'Hipertansiyon',
            level: RiskLevel.moderate,
            explanation: 'Koroner arter hastaligi riski artar',
          ),
      ],
      clinicalComment:
          'Gogus agrisi ile basvuran hastada oncelikle hayati tehdit eden nedenler (AKS, PE, '
          'pnomotoraks, aort diseksiyonu) ekarte edilmelidir. EKG ve troponin ilk basamak '
          'tetkiklerdir. Klinik tabloya gore BT anjiyografi gerekebilir.',
      redFlags: [
        if (hasRisk) 'Kardiyovaskuler risk faktorleri mevcut',
        'Ani baslangicli siddetli agri - aort diseksiyonu ekarte edilmeli',
      ],
      aiSource: 'mock',
      processingMs: 1200,
      confidenceScore: 0.78,
    );
  }

  DiagnosisResult _headacheResult(DiagnosisInput input) {
    return DiagnosisResult(
      differentials: [
        const DifferentialItem(rank: 1, diagnosis: 'Migren', probability: 0.35, reasoning: 'Tekrarlayan, tek tarafli, zonklayici bas agrisi. Bulanti ve isik hassasiyeti eslik edebilir.', supportingFindings: ['Tek tarafli', 'Zonklayici', 'Bulanti'], againstFindings: ['Ani baslangic'], icdCode: 'G43.9'),
        const DifferentialItem(rank: 2, diagnosis: 'Tansiyon Tipi Bas Agrisi', probability: 0.25, reasoning: 'En sik bas agrisi nedeni. Bilateral, baskilayici tarzdadir.', supportingFindings: ['Bilateral', 'Baski hissi'], againstFindings: ['Siddetli agri', 'Bulanti'], icdCode: 'G44.2'),
        DifferentialItem(rank: 3, diagnosis: 'Subaraknoid Kanama', probability: input.symptoms.any((s) => s.toLowerCase().contains('ani')) ? 0.20 : 0.08, reasoning: 'Ani baslangicli, hayatin en siddetli bas agrisi. Acil BT ve LP gerektirir.', supportingFindings: const ['Ani baslangic', 'Siddetli agri', 'Ense sertligi'], againstFindings: const ['Kronik seyir'], icdCode: 'I60.9'),
        const DifferentialItem(rank: 4, diagnosis: 'Menenjit', probability: 0.10, reasoning: 'Ates, ense sertligi ve bas agrisi uclusu. Acil LP gerektirir.', supportingFindings: ['Ates', 'Ense sertligi', 'Fotofobi'], againstFindings: ['Ates yok', 'Meningeal bulgu yok'], icdCode: 'G03.9'),
        const DifferentialItem(rank: 5, diagnosis: 'Temporal Arterit', probability: 0.05, reasoning: '50 yas ustu hastalarda temporal bolge agrisi. ESR/CRP yuksekligi beklenir.', supportingFindings: ['Yas > 50', 'Temporal agri', 'Cene kladikasyosu'], againstFindings: ['Genc yas'], icdCode: 'M31.6'),
      ],
      recommendedTests: [
        const RecommendedTest(name: 'Beyin BT (kontrastsiz)', priority: TestPriority.stat, rationale: 'SAH ve intrakranial patoloji ekartasyonu', expectedFinding: 'SAH\'da bazal sisternlerde kanama', category: 'Goruntuleme'),
        const RecommendedTest(name: 'Lomber Ponksiyon', priority: TestPriority.urgent, rationale: 'BT negatif ancak SAH suphe devam ediyorsa', expectedFinding: 'Ksantokromik BOS', category: 'Girisimsel'),
        const RecommendedTest(name: 'CRP + ESR', priority: TestPriority.urgent, rationale: 'Enflamatuar neden (temporal arterit, menenjit)', expectedFinding: 'Temporal arteritte ESR > 50', category: 'Laboratuvar'),
        const RecommendedTest(name: 'Tam Kan Sayimi', priority: TestPriority.routine, rationale: 'Enfeksiyon taramasi', expectedFinding: 'Menenjitte lokositoz', category: 'Laboratuvar'),
      ],
      riskFactors: [
        if (input.symptoms.any((s) => s.toLowerCase().contains('ani')))
          const RiskFactor(factor: 'Ani baslangic', level: RiskLevel.critical, explanation: 'Thunderclap bas agrisi SAH\'yi dusundurur - acil BT'),
        if (input.patientAge > 50)
          const RiskFactor(factor: 'Yas > 50', level: RiskLevel.moderate, explanation: 'Temporal arterit ve intrakranial kitle olasiligi artar'),
      ],
      clinicalComment: 'Bas agrisinda kirmizi bayraklar (ani baslangic, ilerleyici seyir, norolojik defisit, '
          'ates, ense sertligi) varsa acil goruntuleme yapilmalidir. SAH suphesinde BT normalse LP yapilmalidir.',
      redFlags: ['Ani baslangic - SAH suphe', 'Norolojik defisit varsa acil goruntuleme'],
      aiSource: 'mock',
      processingMs: 950,
      confidenceScore: 0.82,
    );
  }

  DiagnosisResult _abdominalPainResult(DiagnosisInput input) {
    return DiagnosisResult(
      differentials: [
        const DifferentialItem(rank: 1, diagnosis: 'Akut Apandisit', probability: 0.30, reasoning: 'Periumblikal agri ile baslayip sag alt kadrana lokalize olan agri. Ates ve lokositoz eslik eder.', supportingFindings: ['Sag alt kadran agrisi', 'Ates', 'Bulanti'], againstFindings: ['Sol tarafta agri'], icdCode: 'K35.9'),
        const DifferentialItem(rank: 2, diagnosis: 'Akut Kolesistit', probability: 0.20, reasoning: 'Sag ust kadran agrisi, yagali yemek sonrasi artar. Murphy bulgusu pozitif.', supportingFindings: ['Sag ust kadran', 'Postprandiyal', 'Bulanti/kusma'], againstFindings: ['Alt kadran agrisi'], icdCode: 'K81.0'),
        const DifferentialItem(rank: 3, diagnosis: 'Akut Pankreatit', probability: 0.15, reasoning: 'Epigastrik agri, sita yayilim. Amilaz/lipaz yuksekligi beklenir.', supportingFindings: ['Epigastrik agri', 'Sita yayilim', 'Kusma'], againstFindings: ['Alt kadranda agri'], icdCode: 'K85.9'),
        const DifferentialItem(rank: 4, diagnosis: 'Renal Kolik', probability: 0.15, reasoning: 'Kostovertebral aciyi tutan kolik tarzi agri. Hematuria eslik edebilir.', supportingFindings: ['Yan agri', 'Kolik', 'Hematuri'], againstFindings: ['Ates'], icdCode: 'N23'),
        const DifferentialItem(rank: 5, diagnosis: 'Pelvik Inflamatuar Hastalik', probability: 0.10, reasoning: 'Genc kadinlarda alt karin agrisi ve vajinal akinti ile prezente olur.', supportingFindings: ['Alt karin agrisi', 'Vajinal akinti', 'Ates'], againstFindings: ['Erkek hasta'], icdCode: 'N73.0'),
      ],
      recommendedTests: [
        const RecommendedTest(name: 'Tam Kan + CRP', priority: TestPriority.stat, rationale: 'Enfeksiyon ve inflamasyon degerlendirmesi', expectedFinding: 'Lokositoz ve CRP yuksekligi', category: 'Laboratuvar'),
        const RecommendedTest(name: 'Batin USG', priority: TestPriority.stat, rationale: 'Apandisit, kolesistit, batin ici serbest sivi', expectedFinding: 'Apandikste odem, kolesistitte tas', category: 'Goruntuleme'),
        const RecommendedTest(name: 'Amilaz / Lipaz', priority: TestPriority.urgent, rationale: 'Pankreatit ekartasyonu', expectedFinding: 'Pankreatitte > 3x normal', category: 'Laboratuvar'),
        const RecommendedTest(name: 'Tam Idrar Tahlili', priority: TestPriority.urgent, rationale: 'Uriner patoloji, hematuri', expectedFinding: 'Renal kolikte hematuri', category: 'Laboratuvar'),
        const RecommendedTest(name: 'PAAG', priority: TestPriority.routine, rationale: 'Serbest hava (perforasyon), ileus', expectedFinding: 'Perforasyonda diyafram altinda serbest hava', category: 'Goruntuleme'),
      ],
      riskFactors: [
        const RiskFactor(factor: 'Peritoneal iritasyon', level: RiskLevel.high, explanation: 'Defans ve rebound varsa cerrahi aciliyet artar'),
      ],
      clinicalComment: 'Akut karin agrisinda perforasyon, mezenter iskemi ve ektopik gebelik gibi acil cerrahi nedenler oncelikle ekarte edilmelidir.',
      redFlags: ['Peritoneal iritasyon bulgulari (defans, rebound)', 'Hemodinamik instabilite'],
      aiSource: 'mock',
      processingMs: 1100,
      confidenceScore: 0.75,
    );
  }

  DiagnosisResult _dyspneaResult(DiagnosisInput input) {
    return DiagnosisResult(
      differentials: [
        const DifferentialItem(rank: 1, diagnosis: 'KOAH Alevlenmesi', probability: 0.30, reasoning: 'Kronik sigara oykusu olan hastada artan dispne, oksuruk ve balgam.', supportingFindings: ['Sigara oykusu', 'Kronik oksuruk', 'Wheezing'], againstFindings: ['Genc yas', 'Sigara yok'], icdCode: 'J44.1'),
        const DifferentialItem(rank: 2, diagnosis: 'Pnomoni', probability: 0.25, reasoning: 'Ates, oksuruk, balgam ve lokalize solunum sesleri azalmasi.', supportingFindings: ['Ates', 'Prodüktif oksuruk', 'Ral'], againstFindings: ['Ates yok'], icdCode: 'J18.9'),
        const DifferentialItem(rank: 3, diagnosis: 'Konjestif Kalp Yetmezligi', probability: 0.20, reasoning: 'Efor dispnesi, ortopne, PND. Alt ekstremitede odem.', supportingFindings: ['Ortopne', 'Odem', 'S3 galo'], againstFindings: ['Genc yas', 'Kardiyak oykü yok'], icdCode: 'I50.9'),
        const DifferentialItem(rank: 4, diagnosis: 'Pulmoner Emboli', probability: 0.15, reasoning: 'Ani baslayan dispne, ploritik gogus agrisi, takikardi.', supportingFindings: ['Ani baslangic', 'Takikardi', 'Hipoksi'], againstFindings: ['Yavas baslangic'], icdCode: 'I26.9'),
        const DifferentialItem(rank: 5, diagnosis: 'Astim Atagi', probability: 0.10, reasoning: 'Episodik dispne, wheezing, allerji oykusu.', supportingFindings: ['Wheezing', 'Allerji', 'Episodik'], againstFindings: ['Ilk atak'], icdCode: 'J45.9'),
      ],
      recommendedTests: [
        const RecommendedTest(name: 'Arter Kan Gazi', priority: TestPriority.stat, rationale: 'Oksijenasyon ve asit-baz durumu', expectedFinding: 'Hipoksemi, hiperkapni', category: 'Laboratuvar'),
        const RecommendedTest(name: 'PA Akciger Grafisi', priority: TestPriority.stat, rationale: 'Pnomoni, plevral efuzyon, KKY bulgusu', expectedFinding: 'Infiltrasyon, konjesyon', category: 'Goruntuleme'),
        const RecommendedTest(name: 'EKG', priority: TestPriority.stat, rationale: 'Kardiyak neden ekartasyonu', expectedFinding: 'AF, iskemi, sag kalp yuku', category: 'Kardiyoloji'),
        const RecommendedTest(name: 'BNP/proBNP', priority: TestPriority.urgent, rationale: 'Kalp yetmezligi tanisi', expectedFinding: 'KKY\'de > 100 pg/mL', category: 'Laboratuvar'),
        const RecommendedTest(name: 'D-Dimer', priority: TestPriority.urgent, rationale: 'PE taramasi', expectedFinding: 'PE\'de yuksek', category: 'Laboratuvar'),
      ],
      riskFactors: [
        const RiskFactor(factor: 'Hipoksi (SpO2 < 90%)', level: RiskLevel.critical, explanation: 'Acil oksijen tedavisi gerektirir'),
      ],
      clinicalComment: 'Akut dispnede hayati tehdit eden nedenler (PE, tansiyon pnomotoraks, agir astim, '
          'akut akciger odemi) oncelikle degeerlendirilmelidir. Kan gazi ve akciger grafisi ilk basamak tetkiklerdir.',
      redFlags: ['SpO2 < 90%', 'Solunum sikintisi bulgulari', 'Hemodinamik instabilite'],
      aiSource: 'mock',
      processingMs: 1050,
      confidenceScore: 0.80,
    );
  }

  DiagnosisResult _genericResult(DiagnosisInput input) {
    return DiagnosisResult(
      differentials: [
        DifferentialItem(rank: 1, diagnosis: 'Degerlendirme gerekiyor', probability: 0.40, reasoning: 'Verilen bilgilerle kesin bir DD olusturmak icin daha fazla klinik detay gereklidir. Anamnez derinlestirilmelidir.', supportingFindings: input.symptoms, icdCode: 'R69'),
      ],
      recommendedTests: [
        const RecommendedTest(name: 'Tam Kan Sayimi', priority: TestPriority.routine, rationale: 'Genel tarama', expectedFinding: 'Anemi, enfeksiyon', category: 'Laboratuvar'),
        const RecommendedTest(name: 'Biyokimya Paneli', priority: TestPriority.routine, rationale: 'Organ fonksiyon degerlendirmesi', expectedFinding: 'Metabolik bozukluk', category: 'Laboratuvar'),
      ],
      riskFactors: [],
      clinicalComment: 'Mevcut bilgilerle sinirli degerlendirme yapilabilmektedir. Daha detayli anamnez ve fizik muayene bulgulari gereklidir.',
      aiSource: 'mock',
      processingMs: 500,
      confidenceScore: 0.40,
    );
  }

  List<String> _symptomSuggestions(String cc) {
    final complaint = cc.toLowerCase();
    if (complaint.contains('gogus') || complaint.contains('chest')) {
      return ['Retrosternal agri', 'Terleme', 'Bulanti', 'Kola yayilim', 'Ceneye yayilim', 'Nefes darligi', 'Carpinti', 'Senkop', 'Ploritik agri', 'Eforla artan agri', 'Istirahatte baslayan', 'Pozisyonla degisen'];
    }
    if (complaint.contains('bas') || complaint.contains('head')) {
      return ['Zonklayici agri', 'Baskilayici agri', 'Tek tarafli', 'Bilateral', 'Bulanti', 'Kusma', 'Fotofobi', 'Fonofobi', 'Ense sertligi', 'Gorme bozuklugu', 'Ates', 'Ani baslangic', 'Norolojik defisit'];
    }
    if (complaint.contains('karin') || complaint.contains('abdominal')) {
      return ['Bulanti', 'Kusma', 'Ishal', 'Kabizlik', 'Ates', 'Kanli gaita', 'Distansiyon', 'Defans', 'Rebound', 'Sag alt kadran', 'Epigastrik', 'Yaygin agri', 'Kolik tarzi'];
    }
    if (complaint.contains('nefes') || complaint.contains('dispne')) {
      return ['Oksuruk', 'Balgam', 'Hemoptizi', 'Ortopne', 'PND', 'Wheezing', 'Gogus agrisi', 'Bacak sismeleri', 'Ates', 'Takipne', 'Siyanoz'];
    }
    return ['Ates', 'Halsizlik', 'Kilo kaybi', 'Gece terlemesei', 'Istahsizlik', 'Agri', 'Sislik', 'Kizariklik'];
  }
}
