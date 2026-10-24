import { MedicalConsultation } from '../types/consultation.types';

export class AIPromptBuilder {
    /**
     * Create medical prompt for AI Consultation
     */
    static createMedicalPrompt(consultation: any, doctorContext?: any): string {
        const specialties = doctorContext?.specialties?.join(', ') || 'General Practice';

        return `
You are a medical AI assistant assisting Dr. ${doctorContext?.name || 'Smith'}, a ${specialties} specialist.

PATIENT CASE (ANONYMIZED):
- Age Group: ${consultation.patientAgeGroup || 'Unknown'}
- Gender: ${consultation.patientGender || 'Unknown'}
- Symptoms: ${consultation.symptoms?.join(', ') || 'Not specified'}
- Duration: ${consultation.symptomDuration || 'Unknown'}
- Medical History: ${consultation.medicalHistory || 'Not provided'}
- Current Medications: ${consultation.currentMedications?.join(', ') || 'None'}
- Allergies: ${consultation.allergies?.join(', ') || 'None listed'}

CONSULTATION DETAILS:
- Type: ${consultation.type}
- Urgency: ${consultation.urgency || 'medium'}
- Previous Treatments: ${consultation.previousTreatments || 'None'}
- Specific Questions: ${consultation.questions?.join('; ') || 'None provided'}

DOCTOR'S SPECIALTY: ${specialties}

Please provide:
1. Differential diagnosis with probability rankings
2. Recommended diagnostic tests
3. Treatment suggestions with alternatives
4. Red flags to watch for
5. When to refer to specialist
6. Drug interaction considerations if applicable

Format your response clearly with sections and include confidence levels for each recommendation.
Consider the doctor's specialty and provide specialty-specific insights.
If this is outside your scope or requires immediate emergency care, state this clearly.

IMPORTANT: This is for medical professional assistance only. All patient data is anonymized.
    `.trim();
    }

    static buildGeneralMessagePrompt(request: any): string {
        const roleContext = this.getRoleContext(request.userRole);

        return `
      You are a professional healthcare AI assistant. ${roleContext}
      
      User Message: ${request.message}
      
      Please provide a helpful, accurate, and empathetic response.
      Include relevant suggestions for follow-up questions or actions.
      
      Format your response as JSON:
      {
        "text": "your response here",
        "suggestions": ["suggestion 1", "suggestion 2", "suggestion 3"],
        "confidence": 0.95,
        "category": "GENERAL",
        "metadata": {}
      }
    `;
    }

    private static getRoleContext(userRole: string): string {
        switch (userRole) {
            case 'PATIENT':
                return 'You are speaking with a patient. Use simple, clear language and provide actionable advice. Always recommend consulting with healthcare professionals for serious concerns.';
            case 'DOCTOR':
                return 'You are speaking with a medical professional. Use appropriate medical terminology and provide detailed, evidence-based information.';
            case 'ADMIN':
                return 'You are speaking with a system administrator. Provide technical and administrative support.';
            default:
                return 'You are a healthcare AI assistant.';
        }
    }

    static buildAnalysisPrompt(data: any): string {
        return `
      Analyze the following health data and provide insights:
      
      Analysis Type: ${data.analysisType}
      Patient Data: ${JSON.stringify(data.patientData, null, 2)}
      
      Please provide:
      1. Key findings and trends
      2. Risk factors (if any)
      3. Recommendations
      4. Confidence levels
      
      Format as JSON with proper structure.
    `;
    }

    static buildSuggestionsPrompt(context: any): string {
        return `
      Generate 3-5 relevant health suggestions based on the context:
      
      User Role: ${context.userRole}
      Context: ${JSON.stringify(context.context, null, 2)}
      
      Suggestions should be:
      - Actionable and practical
      - Relevant to the context
      - Appropriate for the user role
      
      Format as a JSON array of strings.
    `;
    }

    static buildMedicalInfoPrompt(query: any): string {
        return `
      Provide accurate medical information for the following query:
      
      Query: ${query.query}
      Category: ${query.category || 'GENERAL'}
      Language: ${query.language || 'English'}
      
      Please provide:
      - Clear and accurate information
      - Relevant context
      - Disclaimer about professional medical advice
      - References to reliable sources (if applicable)
    `;
    }
}
