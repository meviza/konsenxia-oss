import { Router } from 'express';
import { ConsensusService } from '../services/consensus.service';

const router = Router();
const consensusService = new ConsensusService();

router.post('/cases', async (req, res) => {
    try {
        const caseData = req.body;
        const newCase = await consensusService.createCase(caseData);
        res.status(201).json(newCase);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create consensus case' });
    }
});

router.get('/cases', async (req, res) => {
    try {
        const cases = await consensusService.getActiveCases();
        res.json(cases);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch consensus cases' });
    }
});

router.post('/vote/:caseId', async (req, res) => {
    try {
        const { caseId } = req.params;
        const vote = req.body;
        await consensusService.castVote(caseId, vote);
        res.status(201).json({ message: 'Vote cast successfully' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to cast vote' });
    }
});

export default router;
