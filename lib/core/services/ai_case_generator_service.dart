import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'claude_ai_service.dart';

/// KONSENXIA — AI Profesör Vaka Üretim Servisi
///
/// Gerçekçi tıbbi vakalar üretir ve Firestore'a kaydeder.
/// Minimum vaka sayısı kontrolü ile uzmanlık alanlarına dağıtım yapar.
///
/// Kullanım:
/// ```dart
/// final generator = AICaseGeneratorService(aiService);
/// await generator.ensureMinimumCases();
/// ```
class AICaseGeneratorService {
  final ClaudeAIService _aiService;
  final FirebaseFirestore _db;

  /// AI Profesör hesabı — otomatik oluşturulan vakalar bu hesaba atanır
  static const _aiProfessorId = 'ai_professor';
  static const _aiProfessorName = 'AI Profesör';
  static const _aiProfessorSpecialty = 'Multidisipliner';

  /// Desteklenen uzmanlık alanları
  static const specialties = [
    'Kardiyoloji',
    'Nöroloji',
    'Acil Tıp',
    'Dahiliye',
    'Pediatri',
    'Göğüs Hastalıkları',
    'Gastroenteroloji',
    'Endokrinoloji',
  ];

  /// Zorluk seviyeleri
  static const difficulties = ['beginner', 'intermediate', 'advanced'];

  /// Vaka üretimi için sistem prompt'u
  static const _caseGenerationSystemPrompt = '''Sen deneyimli bir tıp profesörüsün. Görevin asistan doktorlar için eğitici klinik vakalar oluşturmaktır.

Kurallar:
1. Vakalar gerçek klinik senaryolara dayanmalı
2. Hasta bilgileri tamamen anonim ve sentetik olmalı
3. Klinik bulgular, laboratuvar sonuçları ve görüntüleme bulguları gerçekçi olmalı
4. Her vaka bir öğretim noktası (teaching point) içermeli
5. Zorluk seviyesine uygun detay düzeyi kullan
6. Mümkün olduğunca güncel kılavuzlara ve literatüre referans ver
7. Differansiyel tanı listesi ve doğru tanıya ulaşma adımları açık olmalı''';

  AICaseGeneratorService(
    this._aiService, {
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════
  //  VAKA ÜRETİMİ
  // ═══════════════════════════════════════════════════════════════════

  /// AI kullanarak gerçekçi bir klinik vaka üret
  Future<GeneratedCase> generateCase({
    required String specialty,
    required String difficulty,
  }) async {
    final difficultyLabel = switch (difficulty) {
      'beginner' => 'Başlangıç (kolay, net bulgular, klasik prezentasyon)',
      'intermediate' => 'Orta (karışık bulgular, birkaç olası tanı)',
      'advanced' => 'İleri (nadir hastalık, atipik prezentasyon, komplike)',
      _ => 'Orta',
    };

    final prompt = '''$specialty uzmanlık alanında, "$difficultyLabel" zorluk seviyesinde bir klinik vaka oluştur.

Yanıtını MUTLAKA aşağıdaki JSON formatında ver (başka hiçbir açıklama ekleme):

{
  "title": "Kısa ve açıklayıcı vaka başlığı",
  "patientAge": 45,
  "patientGender": "Erkek veya Kadın",
  "chiefComplaint": "Başvuru şikayeti (1-2 cümle)",
  "clinicalPresentation": "Detaylı anamnez ve fizik muayene bulguları (3-5 paragraf)",
  "vitalSigns": {
    "TA": "120/80 mmHg",
    "Nabız": "88/dk",
    "Solunum": "18/dk",
    "SpO2": "%98",
    "Ateş": "36.8°C"
  },
  "labResults": [
    {"test": "Hemoglobin", "value": "12.5 g/dL", "normal": "12-16 g/dL", "status": "normal"},
    {"test": "WBC", "value": "15.200/mm3", "normal": "4000-11000/mm3", "status": "yüksek"}
  ],
  "imagingFindings": "Görüntüleme bulguları (BT, MR, röntgen, USG, EKG vb.)",
  "differentialDiagnoses": [
    {"diagnosis": "Tanı 1", "probability": "yüksek", "reasoning": "Gerekçe"},
    {"diagnosis": "Tanı 2", "probability": "orta", "reasoning": "Gerekçe"},
    {"diagnosis": "Tanı 3", "probability": "düşük", "reasoning": "Gerekçe"}
  ],
  "correctDiagnosis": "Doğru tanı",
  "treatmentPlan": "Tedavi planı (basamaklar halinde)",
  "teachingPoint": "Bu vakanın öğretim noktası (1-2 cümle)",
  "scoringRubric": {
    "anamnez": 15,
    "fizikMuayene": 15,
    "tetkikYorumlama": 20,
    "differansiyelTani": 20,
    "tedaviPlani": 20,
    "klinikMuhakeme": 10
  },
  "references": [
    "Kaynak 1 (kılavuz/makale adı, yıl)",
    "Kaynak 2"
  ],
  "tags": ["etiket1", "etiket2", "etiket3"]
}''';

    final response = await _aiService.sendMessage(
      message: prompt,
      doctorContext: 'Vaka üretim sistemi — $specialty uzmanı',
    );

    // AI yanıtını parse et
    return _parseGeneratedCase(
      response.text,
      specialty: specialty,
      difficulty: difficulty,
    );
  }

  /// AI yanıtını GeneratedCase modeline dönüştür
  GeneratedCase _parseGeneratedCase(
    String responseText, {
    required String specialty,
    required String difficulty,
  }) {
    try {
      // JSON bloğunu bul (```json ... ``` veya doğrudan { ... })
      String jsonStr = responseText.trim();

      // Markdown code block varsa çıkar
      final codeBlockMatch =
          RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(jsonStr);
      if (codeBlockMatch != null) {
        jsonStr = codeBlockMatch.group(1)!.trim();
      }

      // İlk { ile son } arasını al
      final firstBrace = jsonStr.indexOf('{');
      final lastBrace = jsonStr.lastIndexOf('}');
      if (firstBrace >= 0 && lastBrace > firstBrace) {
        jsonStr = jsonStr.substring(firstBrace, lastBrace + 1);
      }

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      return GeneratedCase(
        title: data['title'] as String? ?? 'Anonim Vaka',
        patientAge: (data['patientAge'] as num?)?.toInt() ?? 45,
        patientGender: data['patientGender'] as String? ?? 'Belirtilmemiş',
        chiefComplaint: data['chiefComplaint'] as String? ?? '',
        clinicalPresentation: data['clinicalPresentation'] as String? ?? '',
        vitalSigns: _parseMap(data['vitalSigns']),
        labResults: _parseLabResults(data['labResults']),
        imagingFindings: data['imagingFindings'] as String? ?? '',
        differentialDiagnoses: _parseDifferentials(data['differentialDiagnoses']),
        correctDiagnosis: data['correctDiagnosis'] as String? ?? '',
        treatmentPlan: data['treatmentPlan'] as String? ?? '',
        teachingPoint: data['teachingPoint'] as String? ?? '',
        scoringRubric: _parseScoringRubric(data['scoringRubric']),
        references: _parseStringList(data['references']),
        tags: _parseStringList(data['tags']),
        specialty: specialty,
        difficulty: difficulty,
      );
    } catch (e) {
      debugPrint('[AI_CASE_GEN] JSON parse hatası: $e');
      // Parse edilemezse ham metinden basit bir vaka oluştur
      return GeneratedCase.fromRawText(
        text: responseText,
        specialty: specialty,
        difficulty: difficulty,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  MİNİMUM VAKA KONTROLÜ
  // ═══════════════════════════════════════════════════════════════════

  /// Aktif vaka sayısını kontrol et, eksikse AI ile oluştur
  ///
  /// [minimum] — minimum aktif vaka sayısı (varsayılan: 15)
  Future<void> ensureMinimumCases({int minimum = 15}) async {
    if (!_aiService.isConfigured) {
      debugPrint('[AI_CASE_GEN] AI servisi yapılandırılmamış, vaka üretimi atlanıyor');
      return;
    }

    try {
      // AI Profesör hesabını oluştur/güncelle
      await _ensureAIProfessorAccount();

      // Mevcut aktif vaka sayısını al
      final activeCases = await _getActiveCaseCounts();
      final totalActive = activeCases.values.fold<int>(0, (a, b) => a + b);

      if (totalActive >= minimum) {
        debugPrint('[AI_CASE_GEN] Yeterli vaka mevcut ($totalActive/$minimum)');
        return;
      }

      final needed = minimum - totalActive;
      debugPrint('[AI_CASE_GEN] $needed vaka üretilecek (mevcut: $totalActive, minimum: $minimum)');

      // Eksik olan uzmanlık alanlarını bul ve önceliklendir
      final underrepresented = _findUnderrepresentedSpecialties(activeCases);

      int generated = 0;
      for (int i = 0; i < needed && i < underrepresented.length; i++) {
        try {
          final specialty = underrepresented[i % underrepresented.length];
          final difficulty = difficulties[i % difficulties.length];

          final generatedCase = await generateCase(
            specialty: specialty,
            difficulty: difficulty,
          );

          await _saveCaseToFirestore(generatedCase);
          generated++;
          debugPrint('[AI_CASE_GEN] Vaka üretildi: ${generatedCase.title} ($specialty)');
        } catch (e) {
          debugPrint('[AI_CASE_GEN] Vaka üretim hatası: $e');
          // Tek bir vaka üretemezse devam et
          continue;
        }
      }

      debugPrint('[AI_CASE_GEN] Toplam $generated yeni vaka üretildi');
    } catch (e) {
      debugPrint('[AI_CASE_GEN] ensureMinimumCases hatası: $e');
    }
  }

  /// AI Profesör hesabını Firestore'da oluştur
  Future<void> _ensureAIProfessorAccount() async {
    final docRef = _db.collection('users').doc(_aiProfessorId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'displayName': _aiProfessorName,
        'displayNameLower': _aiProfessorName.toLowerCase(),
        'specialty': _aiProfessorSpecialty,
        'role': 'PROFESSOR',
        'isAI': true,
        'xp': 99999,
        'level': 99,
        'caseCount': 0,
        'contributionCount': 0,
        'isOnline': true,
        'isActive': true,
        'bio': 'KONSENXIA AI Profesör — Otomatik eğitici vaka üretim sistemi.',
        'institution': 'KONSENXIA AI',
        'country': 'TR',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[AI_CASE_GEN] AI Profesör hesabı oluşturuldu');
    }
  }

  /// Uzmanlık alanlarına göre aktif vaka sayılarını al
  Future<Map<String, int>> _getActiveCaseCounts() async {
    final counts = <String, int>{};
    for (final s in specialties) {
      counts[s] = 0;
    }

    try {
      final snap = await _db
          .collection('cases')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 5));

      for (final doc in snap.docs) {
        final specialty = doc.data()['specialty'] as String? ?? '';
        if (counts.containsKey(specialty)) {
          counts[specialty] = counts[specialty]! + 1;
        }
      }
    } catch (e) {
      debugPrint('[AI_CASE_GEN] Vaka sayısı alınamadı: $e');
    }

    return counts;
  }

  /// Yeterince temsil edilmeyen uzmanlık alanlarını bul
  List<String> _findUnderrepresentedSpecialties(Map<String, int> counts) {
    final sorted = specialties.toList()
      ..sort((a, b) => (counts[a] ?? 0).compareTo(counts[b] ?? 0));
    return sorted;
  }

  /// Üretilen vakayı Firestore'a kaydet
  Future<void> _saveCaseToFirestore(GeneratedCase c) async {
    final caseData = {
      'title': c.title,
      'description': c.clinicalPresentation,
      'specialty': c.specialty,
      'difficulty': c.difficulty,
      'authorId': _aiProfessorId,
      'authorName': _aiProfessorName,
      'authorSpecialty': _aiProfessorSpecialty,
      'isAI': true,
      'isActive': true,
      'isSolved': false,
      'commentCount': 0,
      'likeCount': 0,
      'viewCount': 0,
      'patient': {
        'age': c.patientAge,
        'gender': c.patientGender,
        'chiefComplaint': c.chiefComplaint,
        'vitalSigns': c.vitalSigns,
      },
      'labResults': c.labResults.map((l) => l.toMap()).toList(),
      'imagingFindings': c.imagingFindings,
      'differentialDiagnoses': c.differentialDiagnoses.map((d) => d.toMap()).toList(),
      'correctDiagnosis': c.correctDiagnosis,
      'treatmentPlan': c.treatmentPlan,
      'teachingPoint': c.teachingPoint,
      'scoringRubric': c.scoringRubric.toMap(),
      'references': c.references,
      'tags': c.tags,
      'searchTokens': [
        ...c.tags.map((t) => t.toLowerCase()),
        c.specialty.toLowerCase(),
        c.correctDiagnosis.toLowerCase(),
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _db.collection('cases').add(caseData);

    // AI Profesör vaka sayısını güncelle
    await _db.collection('users').doc(_aiProfessorId).update({
      'caseCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[AI_CASE_GEN] Vaka Firestore\'a kaydedildi: ${docRef.id}');
  }

  // ═══════════════════════════════════════════════════════════════════
  //  YARDIMCI PARSE METODLARı
  // ═══════════════════════════════════════════════════════════════════

  Map<String, String> _parseMap(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  List<LabResult> _parseLabResults(dynamic data) {
    if (data is! List) return [];
    return data.map((item) {
      if (item is Map) {
        return LabResult(
          test: item['test']?.toString() ?? '',
          value: item['value']?.toString() ?? '',
          normalRange: item['normal']?.toString() ?? '',
          status: item['status']?.toString() ?? 'normal',
        );
      }
      return const LabResult(test: '', value: '', normalRange: '', status: '');
    }).where((l) => l.test.isNotEmpty).toList();
  }

  List<DifferentialDiagnosis> _parseDifferentials(dynamic data) {
    if (data is! List) return [];
    return data.map((item) {
      if (item is Map) {
        return DifferentialDiagnosis(
          diagnosis: item['diagnosis']?.toString() ?? '',
          probability: item['probability']?.toString() ?? 'orta',
          reasoning: item['reasoning']?.toString() ?? '',
        );
      }
      return const DifferentialDiagnosis(
          diagnosis: '', probability: '', reasoning: '');
    }).where((d) => d.diagnosis.isNotEmpty).toList();
  }

  ScoringRubric _parseScoringRubric(dynamic data) {
    if (data is Map) {
      return ScoringRubric(
        anamnez: (data['anamnez'] as num?)?.toInt() ?? 15,
        fizikMuayene: (data['fizikMuayene'] as num?)?.toInt() ?? 15,
        tetkikYorumlama: (data['tetkikYorumlama'] as num?)?.toInt() ?? 20,
        differansiyelTani: (data['differansiyelTani'] as num?)?.toInt() ?? 20,
        tedaviPlani: (data['tedaviPlani'] as num?)?.toInt() ?? 20,
        klinikMuhakeme: (data['klinikMuhakeme'] as num?)?.toInt() ?? 10,
      );
    }
    return const ScoringRubric();
  }

  List<String> _parseStringList(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODELler
// ═══════════════════════════════════════════════════════════════════════════

/// AI tarafından üretilen tıbbi vaka
class GeneratedCase {
  final String title;
  final int patientAge;
  final String patientGender;
  final String chiefComplaint;
  final String clinicalPresentation;
  final Map<String, String> vitalSigns;
  final List<LabResult> labResults;
  final String imagingFindings;
  final List<DifferentialDiagnosis> differentialDiagnoses;
  final String correctDiagnosis;
  final String treatmentPlan;
  final String teachingPoint;
  final ScoringRubric scoringRubric;
  final List<String> references;
  final List<String> tags;
  final String specialty;
  final String difficulty;

  const GeneratedCase({
    required this.title,
    required this.patientAge,
    required this.patientGender,
    required this.chiefComplaint,
    required this.clinicalPresentation,
    required this.vitalSigns,
    required this.labResults,
    required this.imagingFindings,
    required this.differentialDiagnoses,
    required this.correctDiagnosis,
    required this.treatmentPlan,
    required this.teachingPoint,
    required this.scoringRubric,
    required this.references,
    required this.tags,
    required this.specialty,
    required this.difficulty,
  });

  /// Parse edilemeyen AI yanıtından basit vaka oluştur
  factory GeneratedCase.fromRawText({
    required String text,
    required String specialty,
    required String difficulty,
  }) {
    return GeneratedCase(
      title: '$specialty Vakası',
      patientAge: 45,
      patientGender: 'Belirtilmemiş',
      chiefComplaint: '',
      clinicalPresentation: text,
      vitalSigns: const {},
      labResults: const [],
      imagingFindings: '',
      differentialDiagnoses: const [],
      correctDiagnosis: '',
      treatmentPlan: '',
      teachingPoint: '',
      scoringRubric: const ScoringRubric(),
      references: const [],
      tags: [specialty],
      specialty: specialty,
      difficulty: difficulty,
    );
  }

  /// Zorluk seviyesi Türkçe etiketi
  String get difficultyLabel => switch (difficulty) {
        'beginner' => 'Başlangıç',
        'intermediate' => 'Orta',
        'advanced' => 'İleri',
        _ => 'Orta',
      };

  /// Toplam puan
  int get maxScore => scoringRubric.total;
}

/// Laboratuvar sonucu
class LabResult {
  final String test;
  final String value;
  final String normalRange;
  final String status; // normal | yüksek | düşük | kritik

  const LabResult({
    required this.test,
    required this.value,
    required this.normalRange,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'test': test,
        'value': value,
        'normalRange': normalRange,
        'status': status,
      };

  bool get isAbnormal => status != 'normal';
}

/// Diferansiyel tanı
class DifferentialDiagnosis {
  final String diagnosis;
  final String probability; // yüksek | orta | düşük
  final String reasoning;

  const DifferentialDiagnosis({
    required this.diagnosis,
    required this.probability,
    required this.reasoning,
  });

  Map<String, dynamic> toMap() => {
        'diagnosis': diagnosis,
        'probability': probability,
        'reasoning': reasoning,
      };
}

/// Puanlama rubriği
class ScoringRubric {
  final int anamnez;
  final int fizikMuayene;
  final int tetkikYorumlama;
  final int differansiyelTani;
  final int tedaviPlani;
  final int klinikMuhakeme;

  const ScoringRubric({
    this.anamnez = 15,
    this.fizikMuayene = 15,
    this.tetkikYorumlama = 20,
    this.differansiyelTani = 20,
    this.tedaviPlani = 20,
    this.klinikMuhakeme = 10,
  });

  int get total =>
      anamnez +
      fizikMuayene +
      tetkikYorumlama +
      differansiyelTani +
      tedaviPlani +
      klinikMuhakeme;

  Map<String, dynamic> toMap() => {
        'anamnez': anamnez,
        'fizikMuayene': fizikMuayene,
        'tetkikYorumlama': tetkikYorumlama,
        'differansiyelTani': differansiyelTani,
        'tedaviPlani': tedaviPlani,
        'klinikMuhakeme': klinikMuhakeme,
        'total': total,
      };
}
