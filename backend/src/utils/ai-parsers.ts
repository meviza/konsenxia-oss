import { AIInsight, InsightType } from '../types/ai.types';

export class AIParser {
    /**
     * Parse insights from AI response
     */
    static parseInsightsFromConsultation(response: string): AIInsight[] {
        const insights: AIInsight[] = [];

        // Extract diagnosis insights
        const diagnosisMatch = response.match(/differential diagnosis:?([^]*?)(?=\n\n|\n[A-Z]|\$)/i);
        if (diagnosisMatch) {
            insights.push({
                id: `insight_diagnosis_${Date.now()}`,
                insight: diagnosisMatch[1].trim(),
                confidence: 0.85,
                references: [],
                type: InsightType.DIAGNOSIS,
                category: 'diagnosis',
                data: { source: 'ai_response' },
                generatedAt: new Date(),
            });
        }

        // Extract treatment insights
        const treatmentMatch = response.match(/treatment suggestions:?([^]*?)(?=\n\n|\n[A-Z]|\$)/i);
        if (treatmentMatch) {
            insights.push({
                id: `insight_treatment_${Date.now()}`,
                insight: treatmentMatch[1].trim(),
                confidence: 0.80,
                references: [],
                type: InsightType.TREATMENT,
                category: 'treatment',
                data: { source: 'ai_response' },
                generatedAt: new Date(),
            });
        }

        // Extract diagnostic insights
        const diagnosticMatch = response.match(/diagnostic tests:?([^]*?)(?=\n\n|\n[A-Z]|\$)/i);
        if (diagnosticMatch) {
            insights.push({
                id: `insight_diagnostic_${Date.now()}`,
                insight: diagnosticMatch[1].trim(),
                confidence: 0.90,
                references: [],
                type: InsightType.RECOMMENDATION,
                category: 'diagnostic',
                data: { source: 'ai_response' },
                generatedAt: new Date(),
            });
        }

        // Extract red flags
        const redFlagsMatch = response.match(/red flags?:?([^]*?)(?=\n\n|\n[A-Z]|\$)/i);
        if (redFlagsMatch) {
            insights.push({
                id: `insight_warning_${Date.now()}`,
                insight: redFlagsMatch[1].trim(),
                confidence: 0.95,
                references: [],
                type: InsightType.WARNING,
                category: 'safety',
                data: { source: 'ai_response' },
                generatedAt: new Date(),
            });
        }

        return insights;
    }

    static extractReferences(response: string): string[] {
        const references: string[] = [];

        // Look for common medical reference patterns
        const referencePatterns = [
            /\[([^\]]+)\]/g,
            /see:? ([^]*?)(?=\n\n|\n[A-Z]|\$)/gi,
            /reference:? ([^]*?)(?=\n\n|\n[A-Z]|\$)/gi,
        ];

        referencePatterns.forEach(pattern => {
            const matches = response.match(pattern);
            if (matches) {
                matches.forEach(match => {
                    const cleanRef = match.replace(/[\[\]]/g, '').trim();
                    if (cleanRef.length > 5 && !references.includes(cleanRef)) {
                        references.push(cleanRef);
                    }
                });
            }
        });

        return references.slice(0, 5); // Limit to 5 references
    }

    static parseGeneralAIResponse(response: string, request: any): any {
        try {
            const parsed = JSON.parse(response);
            return {
                text: parsed.text || response,
                suggestions: Array.isArray(parsed.suggestions) ? parsed.suggestions : [],
                confidence: parsed.confidence || 0.8,
                category: parsed.category || 'GENERAL',
                metadata: parsed.metadata || {},
            };
        } catch {
            return {
                text: response,
                suggestions: [],
                confidence: 0.7,
                category: 'GENERAL',
                metadata: {},
            };
        }
    }

    static parseSuggestionsArray(response: string): string[] {
        try {
            const parsed = JSON.parse(response);
            return Array.isArray(parsed) ? parsed : [];
        } catch {
            // Extract suggestions from text if JSON parsing fails
            const suggestions = response
                .split('\n')
                .filter(line => line.trim().startsWith('-') || line.trim().startsWith('*'))
                .map(line => line.replace(/^[-*]\s*/, '').trim())
                .filter(suggestion => suggestion.length > 0);

            return suggestions.slice(0, 5); // Limit to 5 suggestions
        }
    }

    static parseAnalysisResponse(response: string): any {
        try {
            return JSON.parse(response);
        } catch {
            return {
                findings: response,
                trends: [],
                riskFactors: [],
                recommendations: [response],
                confidence: 0.7,
            };
        }
    }
}
