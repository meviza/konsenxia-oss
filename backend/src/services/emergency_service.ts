import { logger } from '../utils/logger';

export interface EmergencyConsultationData {
  id: string;
  requesterId: string;
  requesterName: string;
  requesterSpecialty: string;
  priority: 'urgent' | 'critical' | 'lifeThreatening';
  targetSpecialty: string;
  title: string;
  clinicalSummary: string;
  patient: {
    age: number;
    gender: string;
    chiefComplaint: string;
    vitals: Record<string, string>;
  };
  status: 'pending' | 'viewed' | 'inProgress' | 'resolved';
  responses: Array<{
    id: string;
    responderId: string;
    responderName: string;
    content: string;
    recommendedAction?: string;
    createdAt: string;
    xpEarned: number;
  }>;
  createdAt: string;
}

export class EmergencyService {
  private consultations: EmergencyConsultationData[] = [];

  getActive(): EmergencyConsultationData[] {
    return this.consultations
      .filter(c => c.status !== 'resolved')
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }

  create(data: Omit<EmergencyConsultationData, 'id' | 'responses' | 'status'>): EmergencyConsultationData {
    const consultation: EmergencyConsultationData = {
      ...data,
      id: `ec_${Date.now()}`,
      responses: [],
      status: 'pending',
    };
    this.consultations.unshift(consultation);
    logger.info('Emergency consultation created', { id: consultation.id, priority: consultation.priority });
    return consultation;
  }

  respond(consultationId: string, response: EmergencyConsultationData['responses'][0]): void {
    const idx = this.consultations.findIndex(c => c.id === consultationId);
    if (idx === -1) throw new Error('Konsultasyon bulunamadi');

    const elapsed = (Date.now() - new Date(this.consultations[idx].createdAt).getTime()) / 1000;
    response.xpEarned = elapsed < 300 ? 150 : elapsed < 900 ? 100 : 50;

    this.consultations[idx].responses.push(response);
    this.consultations[idx].status = 'inProgress';
  }

  getExperts(specialty: string) {
    return MOCK_EXPERTS.filter(e => !specialty || e.specialty === specialty);
  }
}

const MOCK_EXPERTS = [
  { id: 'exp1', name: 'Prof. Dr. Ahmet Yilmaz', specialty: 'Kardiyoloji', level: 8, isOnline: true, avgResponseMinutes: 5 },
  { id: 'exp2', name: 'Doc. Dr. Elif Demir', specialty: 'Noroloji', level: 7, isOnline: true, avgResponseMinutes: 8 },
  { id: 'exp3', name: 'Prof. Dr. Mehmet Kaya', specialty: 'Gogus Hastaliklari', level: 9, isOnline: false, avgResponseMinutes: 12 },
  { id: 'exp4', name: 'Uzm. Dr. Zeynep Arslan', specialty: 'Acil Tip', level: 6, isOnline: true, avgResponseMinutes: 3 },
  { id: 'exp5', name: 'Doc. Dr. Can Ozturk', specialty: 'Genel Cerrahi', level: 7, isOnline: true, avgResponseMinutes: 7 },
  { id: 'exp6', name: 'Prof. Dr. Ayse Celik', specialty: 'Dahiliye', level: 8, isOnline: false, avgResponseMinutes: 10 },
];
