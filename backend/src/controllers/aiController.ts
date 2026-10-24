import { Request, Response } from 'express';
import { AIGeneralService } from '../services/ai';
import { logger } from '../utils/logger';

const aiService = new AIGeneralService();

export class AIController {
  async sendMessage(req: Request, res: Response): Promise<void> {
    try {
      const { message, userRole, userId, context } = req.body;
      const result = await aiService.sendMessage({
        message,
        userRole: userRole || 'PATIENT',
        userId: userId || 'anonymous',
        context,
      });
      res.json({
        success: true,
        data: {
          text: result.text,
          suggestions: result.suggestions,
          confidence: result.confidence,
          category: result.category,
        },
      });
    } catch (error) {
      logger.error('AI sendMessage error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to process message',
      });
    }
  }

  async getChatHistory(req: Request, res: Response): Promise<void> {
    res.json({ success: true, data: [] });
  }

  async clearChatHistory(req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Chat history cleared' });
  }

  async analyzeHealthData(req: Request, res: Response): Promise<void> {
    try {
      const { patientData, analysisType, patientId } = req.body;
      const result = await aiService.analyzeHealthData({
        patientData: patientData || {},
        analysisType: analysisType || 'GENERAL',
      });
      res.json({ success: true, data: result });
    } catch (error) {
      logger.error('AI analyze error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to analyze health data',
      });
    }
  }

  async getHealthInsights(req: Request, res: Response): Promise<void> {
    res.json({ success: true, data: [] });
  }

  async getHealthSuggestions(req: Request, res: Response): Promise<void> {
    try {
      const { userRole, context, category } = req.body;
      const result = await aiService.getHealthSuggestions({
        userRole: userRole || 'PATIENT',
        context: context || {},
      });
      res.json({ success: true, data: result });
    } catch (error) {
      logger.error('AI suggestions error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get suggestions',
      });
    }
  }

  async getMedicalInformation(req: Request, res: Response): Promise<void> {
    try {
      const { query, category, language } = req.body;
      const result = await aiService.getMedicalInformation({
        query: query || '',
        category,
        language,
      });
      res.json({ success: true, data: { text: result } });
    } catch (error) {
      logger.error('AI medical info error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get medical information',
      });
    }
  }

  async checkSymptoms(req: Request, res: Response): Promise<void> {
    res.json({ success: true, data: { analysis: 'Consult a healthcare professional.' } });
  }

  async getMedicationInfo(req: Request, res: Response): Promise<void> {
    try {
      const { medicationName, query, language } = req.body;
      const result = await aiService.getMedicalInformation({
        query: `${medicationName}: ${query || 'general information'}`,
        category: 'MEDICATIONS',
        language,
      });
      res.json({ success: true, data: { text: result } });
    } catch (error) {
      logger.error('AI medication info error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get medication information',
      });
    }
  }

  async getModelPerformance(req: Request, res: Response): Promise<void> {
    res.json({ success: true, data: {} });
  }

  async submitFeedback(req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Feedback received' });
  }
}
