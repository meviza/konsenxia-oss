import { MeditronService } from './meditron_service';
import { logger } from '../utils/logger';

export interface SimulationScenario {
  id: string;
  title: string;
  description: string;
  specialty: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced' | 'expert';
  patient: {
    age: number;
    gender: string;
    chiefComplaint: string;
    pastHistory: string[];
    medications: string[];
    allergies: string[];
    vitals: Record<string, string>;
  };
  correctDiagnosis: string;
  keyFindings: Record<string, string[]>;
  criticalTests: string[];
}

export interface SimulationSession {
  id: string;
  scenarioId: string;
  userId: string;
  currentPhase: string;
  messages: Array<{
    role: 'doctor' | 'patient' | 'system';
    content: string;
    phase: string;
    timestamp: string;
  }>;
  orderedTests: string[];
  startedAt: string;
}

export class SimulationService {
  private meditron: MeditronService;
  private sessions: Map<string, SimulationSession> = new Map();

  constructor() {
    this.meditron = new MeditronService();
  }

  getScenarios(specialty?: string, difficulty?: string): SimulationScenario[] {
    let result = [...SCENARIOS];
    if (specialty) result = result.filter(s => s.specialty === specialty);
    if (difficulty) result = result.filter(s => s.difficulty === difficulty);
    return result;
  }

  startSimulation(scenarioId: string, userId: string): SimulationSession {
    const scenario = SCENARIOS.find(s => s.id === scenarioId);
    if (!scenario) throw new Error('Senaryo bulunamadi');

    const session: SimulationSession = {
      id: `sim_${Date.now()}`,
      scenarioId,
      userId,
      currentPhase: 'anamnesis',
      messages: [{
        role: 'system',
        content: `Simulasyon basladi. ${scenario.patient.age} yasinda ${scenario.patient.gender} hasta, "${scenario.patient.chiefComplaint}" sikayetiyle basvurdu.`,
        phase: 'anamnesis',
        timestamp: new Date().toISOString(),
      }],
      orderedTests: [],
      startedAt: new Date().toISOString(),
    };

    this.sessions.set(session.id, session);
    return session;
  }

  async handleMessage(
    sessionId: string,
    message: string,
    phase: string,
  ): Promise<string> {
    const session = this.sessions.get(sessionId);
    if (!session) return 'Aktif simulasyon bulunamadi.';

    const scenario = SCENARIOS.find(s => s.id === session.scenarioId);
    if (!scenario) return 'Senaryo bulunamadi.';

    // Try AI first
    try {
      const prompt = this._buildPatientPrompt(scenario, message, phase);
      const result = await this.meditron.reportAssistant({
        caseContext: `Hasta: ${scenario.patient.age} yas ${scenario.patient.gender}, ${scenario.patient.chiefComplaint}`,
        draftText: prompt,
        mode: 'complete',
      });
      if (result.source !== 'fallback') {
        return result.result;
      }
    } catch (err) {
      logger.debug('AI patient response failed, using mock', { err });
    }

    // Mock fallback
    return this._getMockResponse(scenario, message, phase);
  }

  calculateScore(
    sessionId: string,
    diagnosis: string,
    treatmentPlan: string,
  ): Record<string, any> {
    const session = this.sessions.get(sessionId);
    if (!session) return { totalPoints: 0, maxPoints: 100, feedback: 'Oturum bulunamadi' };

    const scenario = SCENARIOS.find(s => s.id === session.scenarioId);
    if (!scenario) return { totalPoints: 0, maxPoints: 100, feedback: 'Senaryo bulunamadi' };

    const isCorrect = diagnosis.toLowerCase().includes(scenario.correctDiagnosis.toLowerCase()) ||
      scenario.correctDiagnosis.toLowerCase().includes(diagnosis.toLowerCase());

    const testScore = session.orderedTests.filter(t =>
      scenario.criticalTests.some(ct => t.toLowerCase().includes(ct.toLowerCase()))
    ).length;

    const total = (isCorrect ? 20 : 5) + Math.min(testScore * 5, 20) + 18 + 16 + (treatmentPlan.length > 20 ? 14 : 7);

    return {
      totalPoints: total,
      maxPoints: 100,
      anamnesisScore: 18,
      examinationScore: 16,
      testScore: Math.min(testScore * 5, 20),
      diagnosisScore: isCorrect ? 20 : 5,
      treatmentScore: treatmentPlan.length > 20 ? 14 : 7,
      xpEarned: isCorrect ? 150 : 75,
      correctDiagnosis: scenario.correctDiagnosis,
      feedback: isCorrect
        ? 'Tebrikler! Dogru tani koydunuz.'
        : `Dogru tani: ${scenario.correctDiagnosis}. Klinik bulgulari tekrar gozden gecirin.`,
    };
  }

  private _buildPatientPrompt(scenario: SimulationScenario, question: string, phase: string): string {
    return `[Hasta Simulasyonu]
Hasta profili: ${scenario.patient.age} yas, ${scenario.patient.gender}
Sikayet: ${scenario.patient.chiefComplaint}
Gercek tani (hastanin bilmedigi): ${scenario.correctDiagnosis}

Doktorun ${phase} asamasindaki sorusu: "${question}"

Bu hastanin agzindan, dogal ve gercekci Turkce yanit ver.
Taniyi dogrudan soyleme ama uyumlu semptomlar anlat.
Yanit:`;
  }

  private _getMockResponse(scenario: SimulationScenario, question: string, phase: string): string {
    const q = question.toLowerCase();

    if (phase === 'anamnesis') {
      if (q.includes('ne zaman') || q.includes('basla'))
        return 'Yaklasik birkaç saat once basladi. Ani olarak geldi.';
      if (q.includes('siddet') || q.includes('puan'))
        return '10 uzerinden 8 diyebilirim. Cok siddetli.';
      if (q.includes('bulanti') || q.includes('kusma'))
        return 'Evet, biraz bulantiim var.';
      if (q.includes('ates') || q.includes('titreme'))
        return 'Hafif atesim var gibi hissediyorum.';
      return 'Bu konuda ozel bir sikayetim yok doktor bey.';
    }

    if (phase === 'examination') {
      if (q.includes('karin') || q.includes('batin'))
        return '[Muayene Bulgusu] Palpasyonda hassasiyet mevcut.';
      if (q.includes('kalp') || q.includes('dinle'))
        return '[Muayene Bulgusu] S1-S2 dogal.';
      return '[Muayene Bulgusu] Belirgin patoloji saptanmadi.';
    }

    return 'Anlayamadim, tekrar sorabilir misiniz?';
  }
}

// ── Mock Scenarios ──────────────────────────────────────────────────

const SCENARIOS: SimulationScenario[] = [
  {
    id: 'sim_cardio_01',
    title: 'Akut Gogus Agrisi',
    description: '55 yasinda erkek hasta, 2 saattir devam eden retrosternal gogus agrisi.',
    specialty: 'Kardiyoloji',
    difficulty: 'intermediate',
    patient: {
      age: 55, gender: 'Erkek',
      chiefComplaint: 'Gogus agrisi - 2 saattir',
      pastHistory: ['Hipertansiyon', 'DM Tip 2', 'Sigara (30 paket-yil)'],
      medications: ['Amlodipin 10mg', 'Metformin 1000mg'],
      allergies: ['Penisilin'],
      vitals: { TA: '160/95', Nabiz: '110', SpO2: '94%', Ates: '36.8' },
    },
    correctDiagnosis: 'Akut Miyokard Enfarktusu',
    keyFindings: {
      anamnesis: ['retrosternal agri', 'sol kola yayilim', 'terleme', 'bulanti'],
      examination: ['S4 galo', 'takikardi'],
    },
    criticalTests: ['EKG', 'Troponin'],
  },
  {
    id: 'sim_neuro_01',
    title: 'Ani Baslayan Bas Agrisi',
    description: '42 yasinda kadin, hayatinin en siddetli bas agrisinin ani baslamasi.',
    specialty: 'Noroloji',
    difficulty: 'advanced',
    patient: {
      age: 42, gender: 'Kadin',
      chiefComplaint: 'Siddetli bas agrisi - ani baslangic',
      pastHistory: ['Migren oykusu'],
      medications: ['Sumatriptan PRN'],
      allergies: [],
      vitals: { TA: '180/100', Nabiz: '88', SpO2: '98%', Ates: '37.2' },
    },
    correctDiagnosis: 'Subaraknoid Kanama',
    keyFindings: {
      anamnesis: ['thunderclap bas agrisi', 'ense agrisi', 'kusma'],
      examination: ['ense sertligi', 'Kernig pozitif'],
    },
    criticalTests: ['BT', 'Lomber Ponksiyon'],
  },
  {
    id: 'sim_gastro_01',
    title: 'Akut Karin Agrisi',
    description: '28 yasinda kadin, sag alt kadranda artan karin agrisi.',
    specialty: 'Gastroenteroloji',
    difficulty: 'beginner',
    patient: {
      age: 28, gender: 'Kadin',
      chiefComplaint: 'Sag alt kadran agrisi - 12 saat',
      pastHistory: [],
      medications: [],
      allergies: [],
      vitals: { TA: '120/80', Nabiz: '96', SpO2: '99%', Ates: '38.1' },
    },
    correctDiagnosis: 'Akut Apandisit',
    keyFindings: {
      anamnesis: ['periumblikal baslangic', 'sag alt kadrana kayma', 'istahsizlik'],
      examination: ['McBurney hassasiyeti', 'rebound pozitif', 'Rovsing pozitif'],
    },
    criticalTests: ['Hemogram', 'Batin USG'],
  },
];
