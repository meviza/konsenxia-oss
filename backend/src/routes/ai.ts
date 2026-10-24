import { Router } from 'express';
import { body, param, query } from 'express-validator';
import { AIController } from '../controllers/aiController';
import { validate } from '../middleware/validation';
import { rateLimitMiddleware } from '../middleware/rateLimiter';

const router = Router();
const aiController = new AIController();

// AI Chat endpoints
router.post('/chat/send',
  rateLimitMiddleware.aiChat,
  [
    body('message')
      .trim()
      .isLength({ min: 1, max: 1000 })
      .withMessage('Message must be between 1 and 1000 characters'),
    body('userRole')
      .isIn(['PATIENT', 'DOCTOR', 'ADMIN'])
      .withMessage('Invalid user role'),
    body('userId')
      .isUUID()
      .withMessage('Invalid user ID'),
    body('context')
      .optional()
      .isObject()
      .withMessage('Context must be an object'),
  ],
  validate,
  aiController.sendMessage.bind(aiController)
);

router.get('/chat/history/:userId',
  [
    param('userId')
      .isUUID()
      .withMessage('Invalid user ID'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    query('offset')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Offset must be a non-negative integer'),
  ],
  validate,
  aiController.getChatHistory.bind(aiController)
);

router.delete('/chat/clear/:userId',
  [
    param('userId')
      .isUUID()
      .withMessage('Invalid user ID'),
  ],
  validate,
  aiController.clearChatHistory.bind(aiController)
);

// Health Data Analysis endpoints
router.post('/analyze',
  rateLimitMiddleware.aiAnalysis,
  [
    body('patientData')
      .isObject()
      .withMessage('Patient data must be an object'),
    body('analysisType')
      .isIn(['HEALTH_TRENDS', 'RISK_ASSESSMENT', 'MEDICATION_ANALYSIS', 'SYMPTOM_ANALYSIS'])
      .withMessage('Invalid analysis type'),
    body('patientId')
      .isUUID()
      .withMessage('Invalid patient ID'),
  ],
  validate,
  aiController.analyzeHealthData.bind(aiController)
);

router.get('/insights/:patientId',
  [
    param('patientId')
      .isUUID()
      .withMessage('Invalid patient ID'),
    query('type')
      .optional()
      .isIn(['HEALTH_TRENDS', 'RISK_FACTORS', 'LIFESTYLE', 'MEDICATION'])
      .withMessage('Invalid insight type'),
  ],
  validate,
  aiController.getHealthInsights.bind(aiController)
);

// AI Suggestions endpoints
router.post('/suggestions',
  rateLimitMiddleware.aiSuggestions,
  [
    body('userRole')
      .isIn(['PATIENT', 'DOCTOR', 'ADMIN'])
      .withMessage('Invalid user role'),
    body('context')
      .isObject()
      .withMessage('Context must be an object'),
    body('category')
      .optional()
      .isIn(['SYMPTOMS', 'MEDICATION', 'LIFESTYLE', 'APPOINTMENTS', 'GENERAL'])
      .withMessage('Invalid suggestion category'),
  ],
  validate,
  aiController.getHealthSuggestions.bind(aiController)
);

// Medical Information endpoints
router.post('/medical-info',
  rateLimitMiddleware.aiMedicalInfo,
  [
    body('query')
      .trim()
      .isLength({ min: 3, max: 500 })
      .withMessage('Query must be between 3 and 500 characters'),
    body('category')
      .optional()
      .isIn(['SYMPTOMS', 'CONDITIONS', 'MEDICATIONS', 'PROCEDURES', 'GENERAL'])
      .withMessage('Invalid medical category'),
    body('language')
      .optional()
      .isIn(['en', 'tr', 'de', 'fr', 'es', 'ru', 'ar'])
      .withMessage('Unsupported language'),
  ],
  validate,
  aiController.getMedicalInformation.bind(aiController)
);

// Symptom Checker endpoints
router.post('/symptom-checker',
  rateLimitMiddleware.aiSymptomChecker,
  [
    body('symptoms')
      .isArray({ min: 1, max: 20 })
      .withMessage('Symptoms must be an array with 1-20 items'),
    body('symptoms.*.name')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Symptom name must be between 2 and 100 characters'),
    body('symptoms.*.severity')
      .optional()
      .isIn(['MILD', 'MODERATE', 'SEVERE'])
      .withMessage('Invalid severity level'),
    body('symptoms.*.duration')
      .optional()
      .isISO8601()
      .withMessage('Invalid duration format'),
    body('patientInfo')
      .isObject()
      .withMessage('Patient information must be an object'),
    body('patientInfo.age')
      .isInt({ min: 0, max: 150 })
      .withMessage('Age must be between 0 and 150'),
    body('patientInfo.gender')
      .isIn(['MALE', 'FEMALE', 'OTHER'])
      .withMessage('Invalid gender'),
  ],
  validate,
  aiController.checkSymptoms.bind(aiController)
);

// Medication Information endpoints
router.post('/medication-info',
  rateLimitMiddleware.aiMedicationInfo,
  [
    body('medicationName')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Medication name must be between 2 and 100 characters'),
    body('query')
      .trim()
      .isLength({ min: 3, max: 500 })
      .withMessage('Query must be between 3 and 500 characters'),
    body('language')
      .optional()
      .isIn(['en', 'tr', 'de', 'fr', 'es', 'ru', 'ar'])
      .withMessage('Unsupported language'),
  ],
  validate,
  aiController.getMedicationInfo.bind(aiController)
);

// AI Model Performance endpoints
router.get('/performance',
  aiController.getModelPerformance.bind(aiController)
);

router.post('/feedback',
  [
    body('messageId')
      .isUUID()
      .withMessage('Invalid message ID'),
    body('rating')
      .isInt({ min: 1, max: 5 })
      .withMessage('Rating must be between 1 and 5'),
    body('feedback')
      .optional()
      .trim()
      .isLength({ max: 1000 })
      .withMessage('Feedback must be less than 1000 characters'),
    body('category')
      .optional()
      .isIn(['ACCURACY', 'RELEVANCE', 'CLARITY', 'HELPFULNESS', 'GENERAL'])
      .withMessage('Invalid feedback category'),
  ],
  validate,
  aiController.submitFeedback.bind(aiController)
);

export default router;
