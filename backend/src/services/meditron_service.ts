import axios from 'axios';
import { logger } from '../utils/logger';

/**
 * KONSENXIA — MeditronService
 *
 * Meditron-7B (HuggingFace Inference API) üzerinden tıbbi AI çağrıları.
 * - POST /medical-ai/report-assistant : Rapor yazma yardımcısı
 * - POST /medical-ai/case-analysis    : Vaka analizi, DD listesi
 *
 * HuggingFace ücretsiz inference cold start: 20-60s.
 * Production için HF Pro ($9/ay) veya Ollama önerilir.
 * Claude API fallback aktif; HF başarısız olursa Claude kullanılır.
 */

const HF_MODEL = 'epfl-llm/meditron-7b';
const HF_API_BASE = 'https://api-inference.huggingface.co/models';
const HF_TOKEN = process.env['HF_TOKEN'] ?? '';

// Fallback: Anthropic Claude API
const ANTHROPIC_KEY = process.env['ANTHROPIC_API_KEY'] ?? '';

export interface ReportAssistantRequest {
  caseContext: string;
  draftText: string;
  mode: 'complete' | 'suggest';
}

export interface CaseAnalysisRequest {
  caseData: {
    title: string;
    description: string;
    vitals?: Record<string, string>;
    specialty?: string;
  };
  question?: string;
}

export interface MedicalAIResponse {
  result: string;
  source: 'meditron' | 'claude' | 'fallback';
  processingMs: number;
}

export class MeditronService {
  /**
   * Rapor tamamlama / öneri üretme
   */
  async reportAssistant(req: ReportAssistantRequest): Promise<MedicalAIResponse> {
    const start = Date.now();

    const prompt = this._buildReportPrompt(req);

    try {
      const result = await this._callHuggingFace(prompt);
      return { result, source: 'meditron', processingMs: Date.now() - start };
    } catch (hfErr) {
      logger.warn('HuggingFace call failed, falling back to Claude', { error: hfErr });
      try {
        const result = await this._callClaude(prompt);
        return { result, source: 'claude', processingMs: Date.now() - start };
      } catch (claudeErr) {
        logger.error('Both HF and Claude failed', { claudeErr });
        return {
          result: 'AI servisi şu anda yanıt veremiyor. Lütfen daha sonra tekrar deneyin.',
          source: 'fallback',
          processingMs: Date.now() - start,
        };
      }
    }
  }

  /**
   * Vaka analizi: Diferansiyel tanı + önerilen tetkikler
   */
  async caseAnalysis(req: CaseAnalysisRequest): Promise<MedicalAIResponse> {
    const start = Date.now();

    const prompt = this._buildAnalysisPrompt(req);

    try {
      const result = await this._callHuggingFace(prompt);
      return { result, source: 'meditron', processingMs: Date.now() - start };
    } catch (hfErr) {
      logger.warn('HuggingFace call failed, falling back to Claude', { error: hfErr });
      try {
        const result = await this._callClaude(prompt);
        return { result, source: 'claude', processingMs: Date.now() - start };
      } catch {
        return {
          result: 'AI servisi şu anda yanıt veremiyor. Lütfen daha sonra tekrar deneyin.',
          source: 'fallback',
          processingMs: Date.now() - start,
        };
      }
    }
  }

  // ── HuggingFace Inference ─────────────────────────────────────────

  private async _callHuggingFace(prompt: string): Promise<string> {
    if (!HF_TOKEN) throw new Error('HF_TOKEN not configured');

    const response = await axios.post(
      `${HF_API_BASE}/${HF_MODEL}`,
      {
        inputs: prompt,
        parameters: {
          max_new_tokens: 512,
          temperature: 0.3,
          do_sample: true,
          return_full_text: false,
        },
        options: {
          wait_for_model: true,
          use_cache: false,
        },
      },
      {
        headers: { Authorization: `Bearer ${HF_TOKEN}` },
        timeout: 90_000, // 90s — cold start için
      }
    );

    const data = response.data;
    if (Array.isArray(data) && data[0]?.generated_text) {
      return data[0].generated_text.trim();
    }
    if (data?.generated_text) {
      return (data.generated_text as string).trim();
    }
    throw new Error('Unexpected HuggingFace response format');
  }

  // ── Claude Fallback ───────────────────────────────────────────────

  private async _callClaude(prompt: string): Promise<string> {
    if (!ANTHROPIC_KEY) throw new Error('ANTHROPIC_API_KEY not configured');

    const response = await axios.post(
      'https://api.anthropic.com/v1/messages',
      {
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 512,
        system:
          'Sen KONSENXIA platformu için tıbbi AI asistanısın. ' +
          'Türkçe yanıt ver. Kısa, net ve klinik olarak doğru ol. ' +
          'Diferansiyel tanı ve öneriler için madde işareti formatı kullan.',
        messages: [{ role: 'user', content: prompt }],
      },
      {
        headers: {
          'x-api-key': ANTHROPIC_KEY,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        timeout: 30_000,
      }
    );

    const content = response.data?.content?.[0]?.text;
    if (!content) throw new Error('Empty Claude response');
    return content;
  }

  // ── Prompt Builder'lar ────────────────────────────────────────────

  private _buildReportPrompt(req: ReportAssistantRequest): string {
    const modeLabel = req.mode === 'complete'
      ? 'Mevcut taslak metni tamamla ve geliştir'
      : 'Klinik yazıma uygun öneriler listele';

    return `[KONSENXIA Medical AI - Rapor Asistanı]
Görev: ${modeLabel}

Vaka Bağlamı:
${req.caseContext}

Mevcut Taslak:
${req.draftText}

Tıbbi terminoloji kullan. Kısa ve net ol. Türkçe yanıt ver.
Yanıt:`;
  }

  private _buildAnalysisPrompt(req: CaseAnalysisRequest): string {
    const vitalsText = req.caseData.vitals
      ? Object.entries(req.caseData.vitals)
          .map(([k, v]) => `${k}: ${v}`)
          .join(', ')
      : '';

    return `[KONSENXIA Medical AI - Vaka Analizi]
Vaka: ${req.caseData.title}
Uzmanlık: ${req.caseData.specialty ?? 'Belirtilmemiş'}
${vitalsText ? `Vital Bulgular: ${vitalsText}` : ''}

Klinik Tablo:
${req.caseData.description}

${req.question ? `Soru: ${req.question}\n` : ''}

Lütfen aşağıdaki formatta yanıt ver (Türkçe):

**Diferansiyel Tanı:**
1. [En olası tanı]
2. [İkinci olası tanı]
3. [Üçüncü olası tanı]

**Önerilen Tetkikler:**
- [Tetkik 1]
- [Tetkik 2]

**Risk Faktörleri:**
- [Risk faktörü]

**Kısa Yorum:**
[2-3 cümle klinik yorum]

Yanıt:`;
  }
}
