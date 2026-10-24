export interface MedicalConsultation {
  id: string;
  patientId: string;
  doctorId: string;
  collaboratingDoctorId?: string;
  type: ConsultationType;
  status: ConsultationStatus;
  title: string;
  description: string;
  symptoms: string[];
  diagnosis?: string;
  treatmentPlan?: string;
  attachments: string[];
  tags: string[];
  aiConfidenceScore?: number;
  aiInsights: any[];
  doctorComments: any[];
  createdAt: Date;
  updatedAt?: Date;
  completedAt?: Date;
  metadata: any;
  // Additional fields for AI processing
  patientAgeGroup?: string;
  patientGender?: string;
  symptomDuration?: string;
  medicalHistory?: string;
  currentMedications?: string[];
  allergies?: string[];
  previousTreatments?: string[];
  questions?: string[];
  urgency?: string;
}

export enum ConsultationType {
  GENERAL = 'general',
  EMERGENCY = 'emergency',
  SECOND_OPINION = 'secondOpinion',
  FOLLOW_UP = 'followUp',
  SPECIALIST_REFERRAL = 'specialistReferral',
}

export enum ConsultationStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'inProgress',
  AWAITING_COLLABORATION = 'awaitingCollaboration',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export interface DoctorComment {
  id: string;
  doctorId: string;
  doctorName: string;
  comment: string;
  createdAt: Date;
  isCollaborationRequest: boolean;
}
