import { Router, Request, Response } from 'express';
import { SimulationService } from '../services/simulation_service';
import { logger } from '../utils/logger';

const router = Router();
const service = new SimulationService();

// GET /scenarios — list available scenarios
router.get('/scenarios', (req: Request, res: Response) => {
  try {
    const { specialty, difficulty } = req.query;
    const scenarios = service.getScenarios(
      specialty as string | undefined,
      difficulty as string | undefined,
    );
    res.json({ success: true, data: scenarios });
  } catch (error) {
    logger.error('Failed to get scenarios', { error });
    res.status(500).json({ success: false, error: 'Senaryolar yuklenemedi' });
  }
});

// POST /start — start a simulation
router.post('/start', (req: Request, res: Response) => {
  try {
    const { scenarioId } = req.body;
    const userId = (req as any).userId || 'anonymous';
    const session = service.startSimulation(scenarioId, userId);
    res.json({ success: true, data: session });
  } catch (error) {
    logger.error('Failed to start simulation', { error });
    res.status(500).json({ success: false, error: 'Simulasyon baslatilamadi' });
  }
});

// POST /message — send message to AI patient
router.post('/message', async (req: Request, res: Response) => {
  try {
    const { simulationId, message, phase } = req.body;
    const response = await service.handleMessage(simulationId, message, phase);
    res.json({ success: true, response });
  } catch (error) {
    logger.error('Failed to handle simulation message', { error });
    res.status(500).json({ success: false, error: 'Mesaj iletilemedi' });
  }
});

// POST /diagnose — submit diagnosis and get score
router.post('/diagnose', (req: Request, res: Response) => {
  try {
    const { simulationId, diagnosis, treatmentPlan } = req.body;
    const score = service.calculateScore(simulationId, diagnosis, treatmentPlan);
    res.json({ success: true, data: score });
  } catch (error) {
    logger.error('Failed to calculate score', { error });
    res.status(500).json({ success: false, error: 'Skor hesaplanamadi' });
  }
});

export default router;
