import { Router } from 'express';
import { body } from 'express-validator';
import { validate } from '../middleware/validation';
import { rateLimitMiddleware } from '../middleware/rateLimiter';
import { MeditronService } from '../services/meditron_service';
import { sendSuccess, sendError } from '../utils/responseHandler';

const router = Router();
const meditronService = new MeditronService();

/**
 * POST /medical-ai/report-assistant
 *
 * Rapor yazma yardımcısı — Meditron-7B (HF) veya Claude fallback
 *
 * Body:
 *   caseContext: string  — Vaka özeti (bağlam)
 *   draftText: string    — Kullanıcının taslak metni
 *   mode: 'complete' | 'suggest'
 */
router.post(
  '/report-assistant',
  rateLimitMiddleware.aiChat,
  [
    body('caseContext')
      .isString()
      .isLength({ min: 10, max: 2000 })
      .withMessage('Vaka bağlamı 10-2000 karakter arasında olmalı'),
    body('draftText')
      .isString()
      .isLength({ min: 0, max: 3000 })
      .withMessage('Taslak metin 3000 karakterden fazla olamaz'),
    body('mode')
      .isIn(['complete', 'suggest'])
      .withMessage("mode 'complete' veya 'suggest' olmalı"),
  ],
  validate,
  async (req, res) => {
    try {
      const result = await meditronService.reportAssistant({
        caseContext: req.body.caseContext as string,
        draftText: req.body.draftText as string,
        mode: req.body.mode as 'complete' | 'suggest',
      });
      sendSuccess(res, result);
    } catch (err) {
      sendError(res, 'AI rapor asistanı başarısız', 500);
    }
  }
);

/**
 * POST /medical-ai/case-analysis
 *
 * Vaka analizi — diferansiyel tanı, önerilen tetkikler, risk faktörleri
 *
 * Body:
 *   caseData: { title, description, vitals?, specialty? }
 *   question?: string  — opsiyonel odak sorusu
 */
router.post(
  '/case-analysis',
  rateLimitMiddleware.aiAnalysis,
  [
    body('caseData')
      .isObject()
      .withMessage('caseData bir nesne olmalı'),
    body('caseData.title')
      .isString()
      .isLength({ min: 5, max: 500 })
      .withMessage('Vaka başlığı 5-500 karakter arasında olmalı'),
    body('caseData.description')
      .isString()
      .isLength({ min: 20, max: 5000 })
      .withMessage('Vaka açıklaması 20-5000 karakter arasında olmalı'),
    body('question')
      .optional()
      .isString()
      .isLength({ max: 500 })
      .withMessage('Soru 500 karakterden fazla olamaz'),
  ],
  validate,
  async (req, res) => {
    try {
      const result = await meditronService.caseAnalysis({
        caseData: req.body.caseData,
        question: req.body.question,
      });
      sendSuccess(res, result);
    } catch (err) {
      sendError(res, 'AI vaka analizi başarısız', 500);
    }
  }
);

export default router;
