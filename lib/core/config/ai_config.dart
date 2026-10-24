/// KONSENXIA AI Servis Yapilandirmasi
///
/// API anahtarlari `--dart-define` ile gecilir:
/// ```bash
/// flutter run \
///   --dart-define=GROQ_API_KEY=gsk_... \
///   --dart-define=OPENROUTER_API_KEY=sk-or-v1-...
/// ```
class AIConfig {
  AIConfig._();

  // ── Groq API (hizli, birincil) ───────────────────────────────────────
  // Ucretsiz katman: 30 req/dk
  static const groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
  static const groqBaseUrl = 'https://api.groq.com/openai/v1';

  // ── OpenRouter API (tibbi uzman, ikincil) ────────────────────────────
  // Meditron, Nemotron, ve diger tibbi modellere tek API ile erisim
  // https://openrouter.ai/keys
  static const openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
  static const openRouterBaseUrl = 'https://openrouter.ai/api/v1';

  // ── NVIDIA NIM API (opsiyonel yedek) ─────────────────────────────────
  static const nvidiaApiKey = String.fromEnvironment(
    'NVIDIA_API_KEY',
    defaultValue: '',
  );
  static const nvidiaBaseUrl = 'https://integrate.api.nvidia.com/v1';

  // ── Model Tanimlari ──────────────────────────────────────────────────

  // Groq modelleri (hizli, genel amacli)
  static const groqTextModel = 'llama-3.3-70b-versatile';
  static const groqVisionModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const groqFastModel = 'llama-3.1-8b-instant';

  // OpenRouter modelleri (tibbi uzman)
  static const openRouterMedicalModel = 'openrouter/auto'; // En uygun modeli otomatik sec
  static const openRouterNemotronModel = 'nvidia/llama-3.1-nemotron-70b-instruct';
  static const openRouterLargeModel = 'meta-llama/llama-3.3-70b-instruct';

  // NVIDIA NIM modeli
  static const nvidiaModel = 'nvidia/llama-3.1-nemotron-ultra-253b-v1';

  /// En az bir API anahtari yapilandirilmis mi?
  static bool get isAnyConfigured =>
      groqApiKey.isNotEmpty || openRouterApiKey.isNotEmpty || nvidiaApiKey.isNotEmpty;

  static bool get isGroqConfigured => groqApiKey.isNotEmpty;
  static bool get isOpenRouterConfigured => openRouterApiKey.isNotEmpty;
  static bool get isNvidiaConfigured => nvidiaApiKey.isNotEmpty;
}
