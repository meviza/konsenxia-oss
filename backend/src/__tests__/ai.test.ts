import express from 'express';
import request from 'supertest';

import aiRoutes from '../routes/ai';

jest.mock('../services/ai', () => {
  const sendMessage = jest.fn().mockResolvedValue({
    text: 'Hello patient',
    suggestions: ['s1', 's2'],
    confidence: 0.9,
    category: 'GENERAL',
    metadata: {},
  });

  const analyzeHealthData = jest.fn().mockResolvedValue({
    findings: 'All good',
    confidence: 0.95,
  });

  const getHealthSuggestions = jest.fn().mockResolvedValue(['s1', 's2']);

  return {
    AIGeneralService: jest.fn().mockImplementation(() => ({
      sendMessage,
      analyzeHealthData,
      getHealthSuggestions,
      getMedicalInformation: jest.fn().mockResolvedValue('info'),
    })),
  };
});
jest.mock('../middleware/rateLimiter', () => ({
  rateLimitMiddleware: {
    aiChat: (_req: any, _res: any, next: any) => next(),
    aiAnalysis: (_req: any, _res: any, next: any) => next(),
    aiSuggestions: (_req: any, _res: any, next: any) => next(),
    aiMedicalInfo: (_req: any, _res: any, next: any) => next(),
    aiSymptomChecker: (_req: any, _res: any, next: any) => next(),
    aiMedicationInfo: (_req: any, _res: any, next: any) => next(),
  },
}));
jest.mock('../middleware/validation', () => ({
  validate: (_req: any, _res: any, next: any) => next(),
}));

describe('AI routes', () => {
  const createApp = () => {
    const app = express();
    app.use(express.json());
    app.use('/api/v1/ai', aiRoutes);
    return app;
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('POST /chat/send returns 200 with AI response data', async () => {
    const app = createApp();

    const res = await request(app)
      .post('/api/v1/ai/chat/send')
      .send({
        message: 'Hi',
        userRole: 'PATIENT',
        userId: '550e8400-e29b-41d4-a716-446655440000',
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.text).toBe('Hello patient');
  });

  it('POST /analyze returns 200 with analysis result', async () => {
    const app = createApp();

    const res = await request(app)
      .post('/api/v1/ai/analyze')
      .send({
        patientData: { bp: '120/80' },
        analysisType: 'HEALTH_TRENDS',
        patientId: '550e8400-e29b-41d4-a716-446655440000',
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.findings).toBe('All good');
  });

  it('POST /suggestions returns 200 with suggestions', async () => {
    const app = createApp();

    const res = await request(app)
      .post('/api/v1/ai/suggestions')
      .send({
        userRole: 'PATIENT',
        context: { symptom: 'headache' },
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toEqual(['s1', 's2']);
  });
});

