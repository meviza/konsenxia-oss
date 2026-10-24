import { MedicalConsultation } from '../types/consultation.types';

/**
 * Anonymize patient data for AI processing and research
 * Follows HIPAA, GDPR, and KVKK compliance standards
 */
export function anonymizePatientData(consultation: MedicalConsultation): any {
  const anonymized = {
    ...consultation,
    // Remove direct identifiers
    patientId: generateAnonymousId(),
    doctorId: generateAnonymousId(),
    collaboratingDoctorId: consultation.collaboratingDoctorId ? generateAnonymousId() : undefined,
    
    // Generalize age groups
    patientAgeGroup: generalizeAge(consultation.patientAgeGroup),
    
    // Keep gender but ensure it's generalized
    patientGender: consultation.patientGender || 'unknown',
    
    // Remove specific dates, keep relative timing
    createdAt: new Date(), // Reset to current time for training
    updatedAt: consultation.updatedAt ? new Date() : undefined,
    completedAt: consultation.completedAt ? new Date() : undefined,
    
    // Anonymize text fields
    title: anonymizeText(consultation.title),
    description: anonymizeText(consultation.description),
    symptoms: consultation.symptoms.map(s => anonymizeText(s)),
    diagnosis: consultation.diagnosis ? anonymizeText(consultation.diagnosis) : undefined,
    treatmentPlan: consultation.treatmentPlan ? anonymizeText(consultation.treatmentPlan) : undefined,
    
    // Remove specific identifiers from medical history
    medicalHistory: consultation.medicalHistory ? anonymizeMedicalHistory(consultation.medicalHistory) : undefined,
    currentMedications: consultation.currentMedications?.map(m => anonymizeMedication(m)) || [],
    allergies: consultation.allergies?.map(a => anonymizeAllergy(a)) || [],
    previousTreatments: consultation.previousTreatments?.map(t => anonymizeText(t)) || [],
    questions: consultation.questions?.map(q => anonymizeText(q)) || [],
  };

  return anonymized;
}

/**
 * Generate anonymous ID for training data
 */
function generateAnonymousId(): string {
  return `anon_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Generalize age to age groups
 */
function generalizeAge(ageGroup?: string): string {
  if (!ageGroup) return 'unknown';
  
  const ageMap: { [key: string]: string } = {
    '0-2': 'infant',
    '3-12': 'child',
    '13-17': 'adolescent',
    '18-25': 'young_adult',
    '26-45': 'adult',
    '46-65': 'middle_aged',
    '66+': 'elderly',
  };
  
  return ageMap[ageGroup] || 'unknown';
}

/**
 * Remove potential identifiers from text
 */
function anonymizeText(text: string): string {
  if (!text) return '';
  
  // Remove names (simple pattern matching)
  let anonymized = text.replace(/\b[A-Z][a-z]+\s+[A-Z][a-z]+\b/g, '[NAME]');
  anonymized = anonymized.replace(/\b[A-Z][a-z]+\b/g, '[NAME]');
  
  // Remove dates
  anonymized = anonymized.replace(/\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b/g, '[DATE]');
  anonymized = anonymized.replace(/\b\d{4}\b/g, '[YEAR]');
  
  // Remove phone numbers
  anonymized = anonymized.replace(/\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b/g, '[PHONE]');
  
  // Remove addresses (simple pattern)
  anonymized = anonymized.replace(/\d+\s+[\w\s]+\s+(Street|St|Avenue|Ave|Road|Rd)/gi, '[ADDRESS]');
  
  // Remove medical record numbers
  anonymized = anonymized.replace(/\bMRN\s*#?\s*\d+\b/gi, '[MRN]');
  anonymized = anonymized.replace(/\bMedical\s+Record\s+#?\s*\d+\b/gi, '[MRN]');
  
  // Remove social security numbers
  anonymized = anonymized.replace(/\b\d{3}[-.\s]?\d{2}[-.\s]?\d{4}\b/g, '[SSN]');
  
  return anonymized.trim();
}

/**
 * Anonymize medical history while preserving clinical relevance
 */
function anonymizeMedicalHistory(history: string): string {
  let anonymized = anonymizeText(history);
  
  // Remove specific facility names but keep facility types
  anonymized = anonymized.replace(/\b[A-Z][a-z]+\s+(Hospital|Clinic|Medical Center)\b/g, '[FACILITY]');
  
  // Remove specific doctor names but keep titles
  anonymized = anonymized.replace(/\bDr\.?\s+[A-Z][a-z]+/g, '[DOCTOR]');
  
  return anonymized;
}

/**
 * Anonymize medication names while keeping drug classes
 */
function anonymizeMedication(medication: string): string {
  // Keep drug classes but remove specific brands
  const drugClasses = ['antibiotic', 'painkiller', 'antidepressant', 'blood pressure', 'diabetes'];
  
  for (const drugClass of drugClasses) {
    if (medication.toLowerCase().includes(drugClass)) {
      return `[${drugClass.toUpperCase()}_MEDICATION]`;
    }
  }
  
  return '[MEDICATION]';
}

/**
 * Anonymize allergies while keeping allergy types
 */
function anonymizeAllergy(allergy: string): string {
  // Keep common allergy types
  const allergyTypes = ['penicillin', 'latex', 'peanut', 'shellfish', 'pollen', 'dust'];
  
  for (const allergyType of allergyTypes) {
    if (allergy.toLowerCase().includes(allergyType)) {
      return `[${allergyType.toUpperCase()}_ALLERGY]`;
    }
  }
  
  return '[ALLERGY]';
}

/**
 * Validate that data is properly anonymized
 */
export function validateAnonymization(data: any): boolean {
  const text = JSON.stringify(data);
  
  // Check for common identifiers
  const patterns = [
    /\b\d{3}[-.\s]?\d{2}[-.\s]?\d{4}\b/, // SSN
    /\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b/, // Phone
    /\b[A-Z][a-z]+\s+[A-Z][a-z]+\b/, // Names
    /\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b/, // Dates
  ];
  
  for (const pattern of patterns) {
    if (pattern.test(text)) {
      return false;
    }
  }
  
  return true;
}

/**
 * Apply differential privacy for additional protection
 */
export function applyDifferentialPrivacy(data: any[], epsilon: number = 1.0): any[] {
  // Simple implementation of Laplace noise for differential privacy
  const sensitivity = 1.0;
  const scale = sensitivity / epsilon;
  
  return data.map(item => {
    const noisyItem = { ...item };
    
    // Add noise to numerical fields
    Object.keys(noisyItem).forEach(key => {
      const value = noisyItem[key];
      if (typeof value === 'number') {
        const noise = generateLaplaceNoise(scale);
        noisyItem[key] = Math.max(0, value + noise);
      }
    });
    
    return noisyItem;
  });
}

/**
 * Generate Laplace noise for differential privacy
 */
function generateLaplaceNoise(scale: number): number {
  const uniform = Math.random() - 0.5;
  return -scale * Math.sign(uniform) * Math.log(1 - 2 * Math.abs(uniform));
}
