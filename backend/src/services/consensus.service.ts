import { logger } from '../utils/logger';
import { FirestoreService } from './firestore';
import { ConsensusCase, ConsensusVote } from '../types/consensus.types';
import { eventBus } from '../utils/eventBus';

export class ConsensusService {
    private firestore: FirestoreService;
    private readonly collectionName = 'consensus_cases';

    constructor() {
        this.firestore = new FirestoreService();
    }

    async getActiveCases(): Promise<ConsensusCase[]> {
        try {
            const snapshot = await this.firestore['db']
                .collection(this.collectionName)
                .where('status', '==', 'PENDING')
                .orderBy('createdAt', 'desc')
                .get();

            if (snapshot.empty) {
                return [];
            }

            return snapshot.docs.map(doc => {
                const data = doc.data();
                return {
                    id: doc.id,
                    ...data,
                    createdAt: data.createdAt?.toDate() || new Date(),
                    updatedAt: data.updatedAt?.toDate() || new Date(),
                } as ConsensusCase;
            });
        } catch (error) {
            logger.error('Error fetching consensus cases:', error);
            throw error;
        }
    }

    async createCase(data: Omit<ConsensusCase, 'id' | 'createdAt' | 'updatedAt' | 'votes' | 'currentConsensus'>): Promise<ConsensusCase> {
        try {
            const newCaseRef = this.firestore['db'].collection(this.collectionName).doc();
            const now = new Date();
            const newCase: ConsensusCase = {
                id: newCaseRef.id,
                ...data,
                votes: [],
                currentConsensus: 0,
                createdAt: now,
                updatedAt: now,
            };

            await newCaseRef.set({
                ...newCase,
                createdAt: newCase.createdAt, // Will be converted to Firestore Timestamp automatically or manually
                updatedAt: newCase.updatedAt,
            });

            return newCase;
        } catch (error) {
            logger.error('Error creating consensus case:', error);
            throw error;
        }
    }

    async castVote(caseId: string, vote: ConsensusVote): Promise<void> {
        try {
            logger.info(`Doctor ${vote.doctorId} cast vote on case ${caseId}`);

            // Using a transaction to safely update the case and recalculate consensus
            await this.firestore['db'].runTransaction(async (transaction: any) => {
                const caseRef = this.firestore['db'].collection(this.collectionName).doc(caseId);
                const doc = await transaction.get(caseRef);

                if (!doc.exists) {
                    throw new Error('Case not found');
                }

                const caseData = doc.data() as ConsensusCase;

                // Check if doctor already voted
                const existingVoteIndex = caseData.votes.findIndex(v => v.doctorId === vote.doctorId);
                const newVotes = [...caseData.votes];

                if (existingVoteIndex >= 0) {
                    newVotes[existingVoteIndex] = vote;
                } else {
                    newVotes.push(vote);
                }

                // Recalculate robust consensus based on expertise weight
                const totalWeight = newVotes.reduce((sum, v) => sum + v.expertiseWeight, 0);
                const positiveWeight = newVotes.filter(v => v.vote).reduce((sum, v) => sum + v.expertiseWeight, 0);

                const currentConsensus = totalWeight > 0 ? positiveWeight / totalWeight : 0;

                // If it passes threshold, mark as approved (Could trigger AI fine-tuning)
                let status = caseData.status;
                if (currentConsensus >= caseData.consensusThreshold && newVotes.length >= 3) {
                    status = 'APPROVED';
                    logger.info(`Case ${caseId} has reached consensus and is APPROVED. Ready for AI pipeline.`);
                }

                transaction.update(caseRef, {
                    votes: newVotes,
                    currentConsensus,
                    status,
                    updatedAt: new Date()
                });
            });

            // Emit event after transaction successfully completes
            eventBus.publish('VOTE_UPDATED', { caseId, vote });

        } catch (error) {
            logger.error('Error casting vote:', error);
            throw error;
        }
    }
}
