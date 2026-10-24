export interface AIModel {
  id: string;
  name: string;
  version: string;
  type: AIModelType;
  description: string;
  accuracy: number;
  trainingDataSize: number;
  trainedAt: Date;
  lastUpdated?: Date;
  specialties: string[];
  performance: {
    responseTime: number;
    accuracy: number;
    reliability: number;
    userSatisfaction: number;
  };
  isActive: boolean;
  configuration: {
    temperature: number;
    maxTokens: number;
    topP: number;
    topK: number;
  };
}

export enum AIModelType {
  MEDICAL_CONSULTATION = 'medicalConsultation',
  DIAGNOSIS_ASSISTANCE = 'diagnosisAssistance',
  TREATMENT_RECOMMENDATION = 'treatmentRecommendation',
  DRUG_INTERACTION = 'drugInteraction',
  SYMPTOM_ANALYSIS = 'symptomAnalysis',
  RISK_ASSESSMENT = 'riskAssessment',
}

export interface AIConsultation {
  id: string;
  consultationId: string;
  modelId: string;
  prompt: string;
  response: string;
  confidence: number;
  references: string[];
  insights: AIInsight[];
  context: {
    doctorSpecialties: string[];
    consultationType: string;
    urgency: string;
  };
  createdAt: Date;
  responseTime: number;
  metadata: {
    modelVersion: string;
    promptTokens: number;
    responseTokens: number;
    anonymizationLevel: string;
  };
}

export interface AIInsight {
  id: string;
  insight: string;
  confidence: number;
  references: string[];
  type: InsightType;
  category?: string;
  data: any;
  generatedAt: Date;
}

export enum InsightType {
  DIAGNOSIS = 'diagnosis',
  TREATMENT = 'treatment',
  SYMPTOM_ANALYSIS = 'symptomAnalysis',
  DRUG_INTERACTION = 'drugInteraction',
  RISK_ASSESSMENT = 'riskAssessment',
  RECOMMENDATION = 'recommendation',
  WARNING = 'warning',
}

export interface AIFeedback {
  id: string;
  consultationId: string;
  doctorId: string;
  modelId: string;
  rating: number; // 1-5
  comment?: string;
  issues: string[];
  suggestions: string[];
  wasHelpful: boolean;
  createdAt: Date;
  metadata: any;
}

export interface TrainingData {
  id: string;
  consultationId: string;
  anonymizedData: string[];
  features: string[];
  expectedOutcome?: string;
  actualOutcome?: string;
  isUsedForTraining: boolean;
  createdAt: Date;
  metadata: any;
}

export interface LearningPattern {
  id: string;
  doctorId: string;
  specialties: string[];
  commonDiagnoses: string[];
  treatmentApproaches: string[];
  accuracyScore: number;
  caseCount: number;
  lastUpdated: Date;
  patterns: any;
}
