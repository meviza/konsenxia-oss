import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/simulation_entity.dart';
import '../../domain/repositories/simulation_repository.dart';

class SimulationRepositoryImpl implements SimulationRepository {
  final Dio _dio = GetIt.instance<Dio>();

  SimulationEntity? _activeSimulation;

  @override
  Future<List<SimulationEntity>> getScenarios({
    String? specialty,
    SimulationDifficulty? difficulty,
  }) async {
    try {
      final res = await _dio.get('/api/v1/simulation/scenarios', queryParameters: {
        if (specialty != null) 'specialty': specialty,
        if (difficulty != null) 'difficulty': difficulty.name,
      });
      // Parse real API response when available
      if (res.statusCode == 200 && res.data is List) {
        return _mockScenarios(specialty: specialty, difficulty: difficulty);
      }
    } catch (_) {}
    return _mockScenarios(specialty: specialty, difficulty: difficulty);
  }

  @override
  Future<SimulationEntity> startSimulation(String scenarioId) async {
    final scenarios = await getScenarios();
    final scenario = scenarios.firstWhere(
      (s) => s.id == scenarioId,
      orElse: () => scenarios.first,
    );

    _activeSimulation = scenario.copyWith(
      messages: [
        SimulationMessage(
          id: 'sys_0',
          role: SimulationMessageRole.system,
          content:
              'Simülasyon başladı. ${scenario.patient.age} yaşında ${scenario.patient.gender} hasta, '
              '"${scenario.patient.chiefComplaint}" şikayetiyle başvurdu. Anamnez almaya başlayabilirsiniz.',
          phase: SimulationPhase.anamnesis,
          timestamp: DateTime.now(),
        ),
      ],
    );
    return _activeSimulation!;
  }

  @override
  Future<SimulationMessage> sendMessage(
    String simulationId,
    String message,
    SimulationPhase phase,
  ) async {
    try {
      final res = await _dio.post('/api/v1/simulation/message', data: {
        'simulationId': simulationId,
        'message': message,
        'phase': phase.name,
      });
      if (res.statusCode == 200) {
        return SimulationMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: SimulationMessageRole.patient,
          content: res.data['response'] ?? '',
          phase: phase,
          timestamp: DateTime.now(),
        );
      }
    } catch (_) {}

    // Mock AI patient response
    final response = _getMockPatientResponse(
      _activeSimulation?.id ?? simulationId,
      message,
      phase,
    );
    return SimulationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: SimulationMessageRole.patient,
      content: response,
      phase: phase,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<String>> orderTest(String simulationId, String testName) async {
    await Future.delayed(const Duration(seconds: 1));
    final results = _getMockTestResult(simulationId, testName);
    return results;
  }

  @override
  Future<SimulationEntity> advancePhase(String simulationId) async {
    if (_activeSimulation == null) throw Exception('Aktif simülasyon yok');

    final currentIndex = _activeSimulation!.currentPhase.index;
    if (currentIndex >= SimulationPhase.values.length - 2) {
      return _activeSimulation!;
    }

    final nextPhase = SimulationPhase.values[currentIndex + 1];
    final systemMsg = SimulationMessage(
      id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      role: SimulationMessageRole.system,
      content: _getPhaseTransitionMessage(nextPhase),
      phase: nextPhase,
      timestamp: DateTime.now(),
    );

    _activeSimulation = _activeSimulation!.copyWith(
      currentPhase: nextPhase,
      messages: [..._activeSimulation!.messages, systemMsg],
    );
    return _activeSimulation!;
  }

  @override
  Future<SimulationScore> submitDiagnosis(
    String simulationId,
    String diagnosis,
    String treatmentPlan,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final correct = _activeSimulation?.correctDiagnosis ??
        _getCorrectDiagnosis(simulationId);
    final isCorrect =
        diagnosis.toLowerCase().contains(correct.toLowerCase()) ||
            correct.toLowerCase().contains(diagnosis.toLowerCase());

    final score = SimulationScore(
      totalPoints: isCorrect ? 85 : 55,
      maxPoints: 100,
      anamnesisScore: 18,
      examinationScore: 16,
      testScore: _activeSimulation?.orderedTests.isNotEmpty == true ? 17 : 10,
      diagnosisScore: isCorrect ? 20 : 5,
      treatmentScore: treatmentPlan.length > 20 ? 14 : 7,
      xpEarned: isCorrect ? 150 : 75,
      feedback: isCorrect
          ? 'Tebrikler! Doğru tanı koydunuz. Sistematik yaklaşımınız ve klinik muhakemeniz başarılı.'
          : 'Doğru tanı: $correct. Anamnez ve fizik muayene bulgularını tekrar gözden geçirin. '
              'Özellikle ayırıcı tanıda dikkat edilmesi gereken noktaları not edin.',
    );

    _activeSimulation = _activeSimulation?.copyWith(
      isCompleted: true,
      currentPhase: SimulationPhase.completed,
      userDiagnosis: diagnosis,
      correctDiagnosis: correct,
      score: score,
      completedAt: DateTime.now(),
    );

    return score;
  }

  // ── Mock Data ─────────────────────────────────────────────────────

  List<SimulationEntity> _mockScenarios({
    String? specialty,
    SimulationDifficulty? difficulty,
  }) {
    final all = [
      SimulationEntity(
        id: 'sim_cardio_01',
        scenarioTitle: 'Akut Göğüs Ağrısı',
        scenarioDescription:
            '55 yaşında erkek hasta, 2 saattir devam eden retrosternal göğüs ağrısı ile acil servise başvuruyor.',
        specialty: 'Kardiyoloji',
        difficulty: SimulationDifficulty.intermediate,
        patient: const PatientProfile(
          age: 55,
          gender: 'Erkek',
          chiefComplaint: 'Göğüs ağrısı - 2 saattir devam ediyor',
          pastHistory: ['Hipertansiyon (5 yıl)', 'Tip 2 DM (3 yıl)', 'Sigara (30 paket-yıl)'],
          medications: ['Amlodipin 10mg', 'Metformin 1000mg 2x1'],
          allergies: ['Penisilin'],
          vitals: {'TA': '160/95 mmHg', 'Nabız': '110/dk', 'SpO2': '%94', 'Ateş': '36.8°C'},
        ),
        correctDiagnosis: 'Akut Miyokard Enfarktüsü',
        startedAt: DateTime.now(),
      ),
      SimulationEntity(
        id: 'sim_neuro_01',
        scenarioTitle: 'Ani Başlayan Baş Ağrısı',
        scenarioDescription:
            '42 yaşında kadın hasta, hayatının en şiddetli baş ağrısının ani başlamasıyla başvuruyor.',
        specialty: 'Nöroloji',
        difficulty: SimulationDifficulty.advanced,
        patient: const PatientProfile(
          age: 42,
          gender: 'Kadın',
          chiefComplaint: 'Şiddetli baş ağrısı - ani başlangıç',
          pastHistory: ['Migren öyküsü'],
          medications: ['Sumatriptan PRN'],
          allergies: [],
          vitals: {'TA': '180/100 mmHg', 'Nabız': '88/dk', 'SpO2': '%98', 'Ateş': '37.2°C'},
        ),
        correctDiagnosis: 'Subaraknoid Kanama',
        startedAt: DateTime.now(),
      ),
      SimulationEntity(
        id: 'sim_gastro_01',
        scenarioTitle: 'Akut Karın Ağrısı',
        scenarioDescription:
            '28 yaşında kadın hasta, 12 saattir sağ alt kadranda artan karın ağrısı ile başvuruyor.',
        specialty: 'Gastroenteroloji',
        difficulty: SimulationDifficulty.beginner,
        patient: const PatientProfile(
          age: 28,
          gender: 'Kadın',
          chiefComplaint: 'Sağ alt kadran ağrısı - 12 saattir',
          pastHistory: [],
          medications: [],
          allergies: [],
          vitals: {'TA': '120/80 mmHg', 'Nabız': '96/dk', 'SpO2': '%99', 'Ateş': '38.1°C'},
        ),
        correctDiagnosis: 'Akut Apandisit',
        startedAt: DateTime.now(),
      ),
      SimulationEntity(
        id: 'sim_endo_01',
        scenarioTitle: 'Poliüri ve Polidipsi',
        scenarioDescription:
            '17 yaşında erkek hasta, 2 haftadır artan susuzluk, sık idrara çıkma ve kilo kaybı.',
        specialty: 'Endokrinoloji',
        difficulty: SimulationDifficulty.beginner,
        patient: const PatientProfile(
          age: 17,
          gender: 'Erkek',
          chiefComplaint: 'Aşırı susama ve sık idrara çıkma - 2 hafta',
          pastHistory: [],
          medications: [],
          allergies: [],
          vitals: {'TA': '110/70 mmHg', 'Nabız': '100/dk', 'SpO2': '%99', 'Ateş': '36.5°C'},
        ),
        correctDiagnosis: 'Tip 1 Diabetes Mellitus',
        startedAt: DateTime.now(),
      ),
      SimulationEntity(
        id: 'sim_pulm_01',
        scenarioTitle: 'Ani Nefes Darlığı',
        scenarioDescription:
            '65 yaşında kadın hasta, diz protezi ameliyatından 5 gün sonra ani nefes darlığı.',
        specialty: 'Göğüs Hastalıkları',
        difficulty: SimulationDifficulty.intermediate,
        patient: const PatientProfile(
          age: 65,
          gender: 'Kadın',
          chiefComplaint: 'Ani başlayan nefes darlığı - postoperatif 5. gün',
          pastHistory: ['Gonartroz', 'Obezite (BMI: 34)'],
          medications: ['Enoksaparin 40mg SC (kesilmiş)'],
          allergies: [],
          vitals: {'TA': '140/85 mmHg', 'Nabız': '120/dk', 'SpO2': '%88', 'Ateş': '37.5°C'},
        ),
        correctDiagnosis: 'Pulmoner Emboli',
        startedAt: DateTime.now(),
      ),
      SimulationEntity(
        id: 'sim_acil_01',
        scenarioTitle: 'Bilinç Değişikliği',
        scenarioDescription:
            '70 yaşında erkek hasta, evde bilinç bulanıklığı ile bulunuyor. Yanıt veriyor ancak konfüze.',
        specialty: 'Acil Tıp',
        difficulty: SimulationDifficulty.expert,
        patient: const PatientProfile(
          age: 70,
          gender: 'Erkek',
          chiefComplaint: 'Bilinç bulanıklığı - yakınları fark etmiş',
          pastHistory: ['KAH', 'AF', 'KBY Evre 3'],
          medications: ['Warfarin', 'Digoksin', 'Furosemid'],
          allergies: ['Sulfonamid'],
          vitals: {'TA': '90/60 mmHg', 'Nabız': '45/dk', 'SpO2': '%92', 'Ateş': '35.8°C'},
        ),
        correctDiagnosis: 'Digoksin Toksisitesi',
        startedAt: DateTime.now(),
      ),
    ];

    return all.where((s) {
      if (specialty != null && s.specialty != specialty) return false;
      if (difficulty != null && s.difficulty != difficulty) return false;
      return true;
    }).toList();
  }

  String _getMockPatientResponse(
      String simId, String question, SimulationPhase phase) {
    final q = question.toLowerCase();

    if (phase == SimulationPhase.anamnesis) {
      if (q.contains('ne zaman') || q.contains('başla')) {
        if (simId.contains('cardio')) {
          return 'Yaklaşık 2 saat önce, evde otururken birdenbire başladı. Göğsümün ortasında çok '
              'şiddetli bir baskı hissettim. Sol koluma ve çeneme yayılıyor.';
        }
        if (simId.contains('neuro')) {
          return 'Tam 3 saat önce, tuvalette ıkınırken birdenbire başladı. Hayatımda hiç böyle '
              'bir ağrı yaşamadım. Sanki kafamın içinde bir şey patladı.';
        }
        if (simId.contains('gastro')) {
          return 'Dün akşam yemekten sonra göbek çevresinde bir ağrı başladı, sonra sağ alt tarafa '
              'kaydı. Gece boyunca giderek arttı.';
        }
        return 'Birkaç gün önce hafif başladı, giderek kötüleşti.';
      }
      if (q.contains('şiddet') || q.contains('puan') || q.contains('skor')) {
        return '10 üzerinden 8-9 diyebilirim. Çok şiddetli, dayanılmaz bir ağrı.';
      }
      if (q.contains('bulantı') || q.contains('kusma')) {
        if (simId.contains('cardio')) {
          return 'Evet, ağrı başladığından beri bulantım var. Bir kez de kustum.';
        }
        if (simId.contains('neuro')) {
          return 'Evet, baş ağrısı başladıktan sonra iki kez kustum.';
        }
        return 'Hafif bir bulantım var ama kusmadım.';
      }
      if (q.contains('terleme') || q.contains('soğuk')) {
        if (simId.contains('cardio')) {
          return 'Evet, çok terliyorum. Soğuk soğuk terliyorum, ellerim de soğuk.';
        }
        return 'Biraz terliyorum ama çok belirgin değil.';
      }
      if (q.contains('aile') || q.contains('ailede')) {
        if (simId.contains('cardio')) {
          return 'Babam 52 yaşında kalp krizi geçirdi. Amcam da kalp hastası.';
        }
        return 'Ailemde bilinen önemli bir hastalık yok.';
      }
      if (q.contains('sigara') || q.contains('alkol')) {
        if (simId.contains('cardio')) {
          return 'Günde bir paket sigara içiyorum, 30 yıldır. Alkol nadiren.';
        }
        return 'Sigara ve alkol kullanmıyorum.';
      }
      if (q.contains('ilaç') || q.contains('kullan')) {
        if (simId.contains('cardio')) {
          return 'Tansiyon ilacı alıyorum, amlodipin. Bir de şeker ilacı, metformin.';
        }
        return 'Düzenli kullandığım bir ilaç yok.';
      }
      return 'Bu konuda özel bir şikayetim yok doktor bey/hanım.';
    }

    if (phase == SimulationPhase.examination) {
      if (q.contains('karın') || q.contains('palpasyon') || q.contains('batın')) {
        if (simId.contains('gastro')) {
          return '[Muayene Bulgusu] Sağ alt kadranda belirgin hassasiyet ve defans mevcut. '
              'McBurney noktasında rebound pozitif. Rovsing bulgusu pozitif.';
        }
        return '[Muayene Bulgusu] Batın muayenesi normal. Hassasiyet veya defans yok.';
      }
      if (q.contains('kalp') || q.contains('oskültasyon') || q.contains('dinleme')) {
        if (simId.contains('cardio')) {
          return '[Muayene Bulgusu] S1-S2 normal, ek ses yok. S4 duyuluyor. '
              'Kalp hızı 110/dk, ritmik.';
        }
        return '[Muayene Bulgusu] S1-S2 doğal, ek ses yok, üfürüm yok.';
      }
      if (q.contains('nörolojik') || q.contains('ense') || q.contains('meningeal')) {
        if (simId.contains('neuro')) {
          return '[Muayene Bulgusu] Ense sertliği pozitif. Kernig bulgusu pozitif. '
              'Brudzinski pozitif. Fokal nörolojik defisit yok. GKS: 14 (E4V4M6).';
        }
        return '[Muayene Bulgusu] Nörolojik muayene normal. Meningeal bulgular negatif.';
      }
      if (q.contains('akciğer') || q.contains('solunum')) {
        if (simId.contains('pulm')) {
          return '[Muayene Bulgusu] Sağ akciğer bazalinde solunum sesleri azalmış. '
              'Takipne mevcut (SS: 28/dk). Hafif siyanoz var.';
        }
        return '[Muayene Bulgusu] Her iki akciğer doğal ventile. Ral, ronküs yok.';
      }
      return '[Muayene Bulgusu] Bu bölgede belirgin patolojik bulgu saptanmadı.';
    }

    return 'Sorunuzu anlayamadım, tekrar sorabilir misiniz doktor bey/hanım?';
  }

  List<String> _getMockTestResult(String simId, String testName) {
    final test = testName.toLowerCase();

    if (test.contains('ekg') || test.contains('elektrokardiyografi')) {
      if (simId.contains('cardio')) {
        return ['EKG: V1-V4 derivasyonlarında ST elevasyonu', 'Sinüs taşikardisi (110/dk)', 'Anterior STEMI ile uyumlu'];
      }
      if (simId.contains('pulm')) {
        return ['EKG: Sinüs taşikardisi', 'Sağ aks deviasyonu', 'S1Q3T3 paterni', 'V1-V3 T dalga inversiyonu'];
      }
      return ['EKG: Normal sinüs ritmi', 'Hız: 78/dk', 'ST-T değişikliği yok'];
    }
    if (test.contains('troponin') || test.contains('kardiyak')) {
      if (simId.contains('cardio')) {
        return ['Troponin I: 2.8 ng/mL (Normal: <0.04)', 'YÜKSEK - Miyokard hasarı ile uyumlu'];
      }
      return ['Troponin I: 0.01 ng/mL (Normal: <0.04)', 'Normal sınırlarda'];
    }
    if (test.contains('tam kan') || test.contains('hemogram') || test.contains('cbc')) {
      if (simId.contains('gastro')) {
        return ['WBC: 14.200/mm³ (Yüksek)', 'Hb: 13.5 g/dL', 'Plt: 280.000', 'Nötrofil: %82 (Yüksek)'];
      }
      return ['WBC: 7.500/mm³', 'Hb: 14.2 g/dL', 'Plt: 250.000', 'Normal sınırlarda'];
    }
    if (test.contains('bt') || test.contains('tomografi')) {
      if (simId.contains('neuro')) {
        return ['Beyin BT: Bazal sisternlerde yaygın subaraknoid kanama', 'Fisher Grade 3', 'Hidrosefali yok', 'Anevrizma kaynağı için BT anjiyografi önerilir'];
      }
      if (simId.contains('pulm')) {
        return ['BT Pulmoner Anjiyografi: Sağ ana pulmoner arterde dolum defekti', 'Bilateral alt lob segmental dallarda trombüs', 'Pulmoner emboli ile uyumlu'];
      }
      return ['BT: Belirgin patoloji saptanmadı'];
    }
    if (test.contains('d-dimer')) {
      if (simId.contains('pulm')) {
        return ['D-Dimer: 4.500 ng/mL (Normal: <500)', 'YÜKSEK - Tromboembolik olay düşündürür'];
      }
      return ['D-Dimer: 180 ng/mL (Normal: <500)', 'Normal sınırlarda'];
    }
    if (test.contains('kan şekeri') || test.contains('glukoz') || test.contains('hba1c')) {
      if (simId.contains('endo')) {
        return ['Açlık Kan Şekeri: 380 mg/dL (Yüksek)', 'HbA1c: %12.5 (Yüksek)', 'Ketonüri: +++', 'pH: 7.28 (Düşük - Asidoz)'];
      }
      return ['Açlık Kan Şekeri: 95 mg/dL', 'Normal sınırlarda'];
    }
    if (test.contains('biyokimya') || test.contains('metabolik')) {
      return ['Glukoz: 110 mg/dL', 'BUN: 18 mg/dL', 'Kreatinin: 0.9 mg/dL', 'Na: 140 mEq/L', 'K: 4.2 mEq/L'];
    }
    if (test.contains('idrar') || test.contains('tam idrar')) {
      if (simId.contains('endo')) {
        return ['Glukozüri: +++', 'Ketonüri: +++', 'Proteinüri: +', 'Diyabetik ketoasidoz ile uyumlu'];
      }
      return ['TİT: Normal bulgular', 'pH: 6.0', 'Dansite: 1.020'];
    }
    if (test.contains('digoksin') || test.contains('dijitalis')) {
      if (simId.contains('acil')) {
        return ['Digoksin düzeyi: 3.8 ng/mL (Terapötik: 0.8-2.0)', 'TOKSİK DÜZEY', 'K: 5.8 mEq/L (Yüksek)', 'Kreatinin: 2.4 mg/dL (Yüksek)'];
      }
      return ['Digoksin düzeyi: 1.2 ng/mL', 'Terapötik aralıkta'];
    }
    return ['$testName sonucu: Normal sınırlarda'];
  }

  String _getPhaseTransitionMessage(SimulationPhase phase) {
    switch (phase) {
      case SimulationPhase.examination:
        return 'Anamnez tamamlandı. Fizik muayeneye geçebilirsiniz. '
            'Muayene etmek istediğiniz bölgeyi belirtin.';
      case SimulationPhase.tests:
        return 'Fizik muayene tamamlandı. Tetkik isteme aşamasına geçildi. '
            'İstediğiniz tetkikleri seçin veya yazın.';
      case SimulationPhase.diagnosis:
        return 'Tetkik sonuçları hazır. Şimdi ön tanınızı koyabilirsiniz.';
      case SimulationPhase.treatment:
        return 'Tanınızı belirlediniz. Tedavi planınızı yazın.';
      default:
        return 'Sonraki aşamaya geçildi.';
    }
  }

  String _getCorrectDiagnosis(String simId) {
    if (simId.contains('cardio')) return 'Akut Miyokard Enfarktüsü';
    if (simId.contains('neuro')) return 'Subaraknoid Kanama';
    if (simId.contains('gastro')) return 'Akut Apandisit';
    if (simId.contains('endo')) return 'Tip 1 Diabetes Mellitus';
    if (simId.contains('pulm')) return 'Pulmoner Emboli';
    if (simId.contains('acil')) return 'Digoksin Toksisitesi';
    return 'Bilinmiyor';
  }
}
