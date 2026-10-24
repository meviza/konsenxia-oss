import { logger } from '../utils/logger';
import { FirestoreService } from './firestore';
import { DrugMetric } from '../types/consensus.types';

export class DrugAnalyticsService {
    private firestore: FirestoreService;
    private readonly collectionName = 'drug_metrics';

    constructor() {
        this.firestore = new FirestoreService();
    }

    async getDrugMetrics(): Promise<DrugMetric[]> {
        try {
            const snapshot = await this.firestore['db']
                .collection(this.collectionName)
                .orderBy('lastUpdated', 'desc')
                .get();

            if (snapshot.empty) {
                return [];
            }

            return snapshot.docs.map(doc => {
                const data = doc.data();
                return {
                    id: doc.id,
                    ...data,
                    lastUpdated: data.lastUpdated?.toDate() || new Date(),
                } as DrugMetric;
            });
        } catch (error) {
            logger.error('Error fetching drug metrics:', error);
            throw error;
        }
    }

    async trackEffectiveness(compoundId: string, subjectData: { isEffective: boolean; sideEffectSeverity: number }): Promise<void> {
        try {
            logger.info(`Tracking effectiveness for ${compoundId}`);
            await this.firestore['db'].runTransaction(async (transaction: any) => {
                const metricRef = this.firestore['db'].collection(this.collectionName).doc(compoundId);
                const doc = await transaction.get(metricRef);

                if (!doc.exists) {
                    throw new Error('Compound metric record not found');
                }

                const data = doc.data() as DrugMetric;

                // Recalculate moving average for effectiveness and side effect index
                const newSubjectsCount = data.subjectsCount + 1;

                const newEffectiveness = ((data.effectiveness * data.subjectsCount) + (subjectData.isEffective ? 1 : 0)) / newSubjectsCount;
                const newSideEffectIndex = ((data.sideEffectIndex * data.subjectsCount) + subjectData.sideEffectSeverity) / newSubjectsCount;

                transaction.update(metricRef, {
                    effectiveness: newEffectiveness,
                    sideEffectIndex: newSideEffectIndex,
                    subjectsCount: newSubjectsCount,
                    lastUpdated: new Date()
                });
            });
        } catch (error) {
            logger.error('Error tracking effectiveness:', error);
            throw error;
        }
    }
}
