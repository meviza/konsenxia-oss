import { GoogleGenerativeAI } from '@google/generative-ai';
import { config } from '../config';
import { logger } from '../utils/logger';
import { AIPromptBuilder } from '../utils/ai-prompts';
import { AIParser } from '../utils/ai-parsers';

export interface AIResponse {
  text: string;
  suggestions: string[];
  confidence: number;
  category: string;
  metadata: Record<string, any>;
}

export interface AIRequest {
  message: string;
  userRole: 'PATIENT' | 'DOCTOR' | 'ADMIN';
  userId: string;
  context?: Record<string, any>;
}

export class AIGeneralService {
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor() {
    this.genAI = new GoogleGenerativeAI(config.ai.geminiApiKey);
    this.model = this.genAI.getGenerativeModel({ model: config.ai.model });
  }

  async sendMessage(request: AIRequest): Promise<AIResponse> {
    try {
      const prompt = AIPromptBuilder.buildGeneralMessagePrompt(request);

      const result = await this.model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: { maxOutputTokens: config.ai.maxTokens, temperature: config.ai.temperature },
      });

      return AIParser.parseGeneralAIResponse(result.response.text(), request);
    } catch (error) {
      logger.error('AI Service Error:', error);
      throw new Error('Failed to generate AI response');
    }
  }

  async analyzeHealthData(data: { patientData: Record<string, any>; analysisType: string }): Promise<Record<string, any>> {
    try {
      const prompt = AIPromptBuilder.buildAnalysisPrompt(data);

      const result = await this.model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: { maxOutputTokens: config.ai.maxTokens, temperature: 0.1 },
      });

      return AIParser.parseAnalysisResponse(result.response.text());
    } catch (error) {
      logger.error('Health Data Analysis Error:', error);
      throw new Error('Failed to analyze health data');
    }
  }

  async getHealthSuggestions(context: { userRole: string; context: Record<string, any> }): Promise<string[]> {
    try {
      const prompt = AIPromptBuilder.buildSuggestionsPrompt(context);

      const result = await this.model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: { maxOutputTokens: 1000, temperature: 0.7 },
      });

      return AIParser.parseSuggestionsArray(result.response.text());
    } catch (error) {
      logger.error('Health Suggestions Error:', error);
      throw new Error('Failed to generate health suggestions');
    }
  }

  async getMedicalInformation(query: { query: string; category?: string; language?: string }): Promise<string> {
    try {
      const prompt = AIPromptBuilder.buildMedicalInfoPrompt(query);

      const result = await this.model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: { maxOutputTokens: config.ai.maxTokens, temperature: 0.3 },
      });

      return result.response.text();
    } catch (error) {
      logger.error('Medical Information Error:', error);
      throw new Error('Failed to get medical information');
    }
  }
}
