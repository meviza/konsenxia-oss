import { Router } from 'express';
import { DrugAnalyticsService } from '../services/drug-analytics.service';

const router = Router();
const drugAnalyticsService = new DrugAnalyticsService();

router.post('/effectiveness/:compoundId', async (req, res) => {
    try {
        const { compoundId } = req.params;
        const subjectData = req.body;
        await drugAnalyticsService.trackEffectiveness(compoundId, subjectData);
        res.status(200).json({ message: 'Effectiveness tracked successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to track effectiveness' });
    }
});

router.get('/metrics', async (req, res) => {
    try {
        const metrics = await drugAnalyticsService.getDrugMetrics();
        res.json(metrics);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch drug metrics' });
    }
});

export default router;
