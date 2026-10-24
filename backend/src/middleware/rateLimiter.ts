import rateLimit from 'express-rate-limit';

const aiChatLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { error: 'Too many AI chat requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const aiAnalysisLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { error: 'Too many analysis requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

export const rateLimitMiddleware = {
  aiChat: aiChatLimiter,
  aiAnalysis: aiAnalysisLimiter,
  aiSuggestions: aiAnalysisLimiter,
  aiMedicalInfo: aiChatLimiter,
  aiSymptomChecker: aiAnalysisLimiter,
  aiMedicationInfo: aiChatLimiter,
};
