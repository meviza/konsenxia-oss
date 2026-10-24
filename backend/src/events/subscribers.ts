import { eventBus, EVENTS } from '../utils/eventBus';
import { logger } from '../utils/logger';
import { AIGeneralService } from '../services/ai';
import { ConsultationFirestoreRepository } from '../repositories/implementations/consultation.firestore.repository';

/**
 * This file registers background workers (consumers) that listen to the Event Bus asynchronously.
 * It prevents the main Express HTTP thread from blocking on heavy tasks like AI analysis or BigData sync.
 */

export function registerEventSubscribers() {
    const aiService = new AIGeneralService();
    const consultationRepo = new ConsultationFirestoreRepository();

    // 1. Worker: AI Analysis on New Consultation
    eventBus.subscribe(EVENTS.CONSULTATION_CREATED, async (consultation) => {
        logger.info(`[Worker] Started AI Analysis for consultation: ${consultation.id}`);

        try {
            // Fetch historical context or run heavy ML analysis asynchronously
            // Example: 
            // const insight = await aiService.analyzeHealthData({ patientData: consultation, analysisType: 'SYMPTOM_ANALYSIS' });

            // Update database status with results
            // await consultationRepo.updateStatus(consultation.id, 'ANALYZED');

            // Emit subsequent event
            eventBus.publish(EVENTS.AI_ANALYSIS_COMPLETED, {
                consultationId: consultation.id,
                // findings: insight.findings 
            });

            logger.info(`[Worker] Completed AI Analysis for consultation: ${consultation.id}`);
        } catch (error) {
            logger.error(`[Worker] AI Analysis failed for consultation: ${consultation.id}`, { error });
        }
    });

    // 2. Worker: Data Lake Sync (e.g. ClickHouse/BigQuery) on Verified Diagnosis
    eventBus.subscribe(EVENTS.DIAGNOSIS_VERIFIED, async (verdictPayload) => {
        logger.info(`[Worker] Syncing verified diagnosis to Data Lake. ID: ${verdictPayload.id}`);

        try {
            // Here you would connect to Google BigQuery or ClickHouse via their respective SDKs
            // and perform batch inserts or streaming inserts for analytics purposes.
            // E.g.: await bigQueryClient.dataset('analytics').table('diagnoses').insert([verdictPayload]);
        } catch (error) {
            logger.error(`[Worker] Data Lake sync failed for payload: ${verdictPayload.id}`, { error });
        }
    });

    logger.info('Event subscribers registered successfully.');
}
