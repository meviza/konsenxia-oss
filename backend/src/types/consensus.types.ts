export interface ConsensusCase {
    id: string;
    patientId: string;
    title: string;
    description: string;
    status: 'PENDING' | 'APPROVED' | 'REJECTED';
    consensusThreshold: number; // e.g., 0.8 for 80%
    currentConsensus: number;
    votes: ConsensusVote[];
    createdAt: Date;
    updatedAt: Date;
}

export interface ConsensusVote {
    doctorId: string;
    doctorName: string;
    expertiseWeight: number;
    vote: boolean;
    comment?: string;
    timestamp: Date;
}

export interface DrugMetric {
    id: string;
    compoundName: string;
    phase: string;
    effectiveness: number;
    sideEffectIndex: number;
    progress: number;
    subjectsCount: number;
    lastUpdated: Date;
}
