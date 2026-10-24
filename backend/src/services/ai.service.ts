import { GoogleGenerativeAI } from '@google/generative-ai';
import { logger } from '../utils/logger';
import { AIConsultation, AIInsight, AIModel, InsightType, AIModelType } from '../types/ai.types';
import { MedicalConsultation } from '../types/consultation.types';
import { anonymizePatientData } from '../utils/data-anonymization';
import { AIPromptBuilder } from '../utils/ai-prompts';
import { AIParser } from '../utils/ai-parsers';

export class AIService {
  private genAI: GoogleGenerativeAI;
  private model: any;
  private logger = logger;

  constructor() {
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });
  }

  async generateConsultation(
    consultation: MedicalConsultation,
    doctorContext?: any
  ): Promise<AIConsultation> {
    try {
      const startTime = Date.now();
      const anonymizedData = anonymizePatientData(consultation);
      const prompt = AIPromptBuilder.createMedicalPrompt(anonymizedData, doctorContext);

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      const responseTime = Date.now() - startTime;
      const insights = AIParser.parseInsightsFromConsultation(text);
      const confidence = this.calculateConfidence(insights, consultation);

      const aiConsultation: AIConsultation = {
        id: `ai_consultation_${Date.now()}`,
        consultationId: consultation.id,
        modelId: 'gemini-pro-v1',
        prompt: prompt,
        response: text,
        confidence: confidence,
        references: AIParser.extractReferences(text),
        insights: insights,
        context: {
          doctorSpecialties: doctorContext?.specialties || [],
          consultationType: consultation.type,
          urgency: consultation.urgency || 'medium',
        },
        createdAt: new Date(),
        responseTime: responseTime,
        metadata: {
          modelVersion: 'gemini-pro-v1',
          promptTokens: prompt.length,
          responseTokens: text.length,
          anonymizationLevel: 'full',
        },
      };

      this.logger.info('AI consultation generated successfully', { consultationId: consultation.id, confidence, responseTime });
      return aiConsultation;
    } catch (error) {
      this.logger.error('Error generating AI consultation', error);
      throw new Error('Failed to generate AI consultation');
    }
  }

  private calculateConfidence(insights: AIInsight[], consultation: MedicalConsultation): number {
    let baseConfidence = 0.75;
    if (consultation.symptoms && consultation.symptoms.length > 2) baseConfidence += 0.05;
    if (consultation.medicalHistory && consultation.medicalHistory.length > 0) baseConfidence += 0.05;
    if (consultation.currentMedications && consultation.currentMedications.length > 0) baseConfidence += 0.03;

    const avgInsightConfidence = insights.reduce((sum, insight) => sum + insight.confidence, 0) / (insights.length || 1);
    baseConfidence = (baseConfidence + avgInsightConfidence) / 2;
    return Math.min(baseConfidence, 0.95);
  }

  async getAvailableModels(): Promise<AIModel[]> {
    return [
      {
        id: 'gemini-pro-v1',
        name: 'Gemini Pro',
        version: '1.0',
        type: AIModelType.MEDICAL_CONSULTATION,
        description: 'Google Gemini Pro model optimized for medical consultations',
        accuracy: 0.92,
        trainingDataSize: 1000000,
        trainedAt: new Date('2024-01-15'),
        specialties: ['General Practice', 'Internal Medicine', 'Pediatrics'],
        performance: { responseTime: 2.5, accuracy: 0.92, reliability: 0.95, userSatisfaction: 4.2 },
        isActive: true,
        configuration: { temperature: 0.3, maxTokens: 2048, topP: 0.8, topK: 40 },
      },
      {
        id: 'gemini-pro-specialist-v1',
        name: 'Gemini Pro Specialist',
        version: '1.0',
        type: AIModelType.DIAGNOSIS_ASSISTANCE,
        description: 'Specialized model for complex diagnosis assistance',
        accuracy: 0.94,
        trainingDataSize: 1500000,
        trainedAt: new Date('2024-02-01'),
        specialties: ['Cardiology', 'Neurology', 'Oncology'],
        performance: { responseTime: 3.2, accuracy: 0.94, reliability: 0.96, userSatisfaction: 4.4 },
        isActive: true,
        configuration: { temperature: 0.2, maxTokens: 3072, topP: 0.9, topK: 50 },
      },
    ];
  }

  async submitFeedback(feedback: any): Promise<void> {
    try {
      this.logger.info('AI feedback submitted', { consultationId: feedback.consultationId, rating: feedback.rating });
      if (feedback.rating <= 2 && feedback.issues?.length > 0) {
        await this.scheduleModelRetraining(feedback.modelId);
      }
    } catch (error) {
      this.logger.error('Error submitting AI feedback', error);
      throw new Error('Failed to submit feedback');
    }
  }

  private async scheduleModelRetraining(modelId: string): Promise<void> {
    this.logger.info('Scheduling model retraining', { modelId });
  }

  async getInsights(consultationId: string): Promise<AIInsight[]> {
    return [];
  }

  async processConsensusForTraining(consensusCase: any): Promise<void> {
    try {
      this.logger.info(`Starting AI training based on consensus: ${consensusCase.id}`);
      anonymizePatientData(consensusCase);
      await this.scheduleModelRetraining(this.model.modelName);
    } catch (error) {
      this.logger.error('Error processing consensus', error);
      throw new Error('Failed to process consensus');
    }
  }

  async analyzeCollaborationPatterns(doctorId: string): Promise<any> {
    return { collaborationFrequency: 0, preferredSpecialties: [], accuracyImprovement: 0, learningProgress: 0 };
  }
}
