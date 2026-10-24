import { Router, Request, Response } from 'express';
import { EmergencyService } from '../services/emergency_service';
import { logger } from '../utils/logger';

const router = Router();
const service = new EmergencyService();

// GET /active — get active consultations
router.get('/active', (req: Request, res: Response) => {
  try {
    const active = service.getActive();
    res.json({ success: true, data: active });
  } catch (error) {
    logger.error('Failed to get active consultations', { error });
    res.status(500).json({ success: false, error: 'Konsultasyonlar yuklenemedi' });
  }
});

// POST /create — create new emergency consultation
router.post('/create', (req: Request, res: Response) => {
  try {
    const consultation = service.create({
      ...req.body,
      createdAt: new Date().toISOString(),
    });
    res.json({ success: true, data: consultation });
  } catch (error) {
    logger.error('Failed to create consultation', { error });
    res.status(500).json({ success: false, error: 'Konsultasyon olusturulamadi' });
  }
});

// POST /:id/respond — respond to consultation
router.post('/:id/respond', (req: Request, res: Response) => {
  try {
    service.respond(req.params.id, {
      ...req.body,
      id: `resp_${Date.now()}`,
      createdAt: new Date().toISOString(),
      xpEarned: 0,
    });
    res.json({ success: true });
  } catch (error) {
    logger.error('Failed to respond', { error });
    res.status(500).json({ success: false, error: 'Yanit gonderilemedi' });
  }
});

// GET /experts/:specialty — get available experts
router.get('/experts/:specialty', (req: Request, res: Response) => {
  try {
    const experts = service.getExperts(req.params.specialty);
    res.json({ success: true, data: experts });
  } catch (error) {
    logger.error('Failed to get experts', { error });
    res.status(500).json({ success: false, error: 'Uzmanlar yuklenemedi' });
  }
});

export default router;
