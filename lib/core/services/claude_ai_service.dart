import 'package:dio/dio.dart';
import '../config/ai_config.dart';
import '../../features/medical_files/domain/entities/medical_image_analysis.dart';

/// KONSENXIA — Tibbi AI Servis Katmani (Hibrit)
///
/// Oncelik sirasi:
///   1. **Groq** (Llama 3.3 70B — ucretsiz, super hizli LPU)
///   2. **NVIDIA NIM** (Nemotron Ultra 253B — yedek)
///   3. **Groq Fast** (Llama 3.1 8B — hizli yedek)
///   4. Offline triage yanitlari (internet yokken)
///
/// Groq avantajlari:
/// - Ucretsiz API (rate limit: 30 req/dk, 14.4K token/dk)
/// - Llama 3.3 70B — cok guclu tibbi reasoning
/// - Llama 4 Scout 17B — multimodal (goruntu analizi)
/// - Super hizli yanit (~0.4 saniye) — ozel LPU cipleri
/// - OpenAI-uyumlu API formati
///
/// NVIDIA NIM avantajlari:
/// - Nemotron Ultra 253B — en guclu acik model
/// - Ucretsiz API kredileri (build.nvidia.com)
/// - OpenAI-uyumlu API formati
class ClaudeAIService {
  late final Dio _groqDio;
  late final Dio _openRouterDio;
  late final Dio _nvidiaDio;

  // ── Tibbi Uzman System Prompt ────────────────────────────────────
  static const _systemPrompt = '''Sen KONSENXIA platformunun kidemli tibbi AI danismanisin. Adin "KX Medikal Asistan".

## Kimligin ve Uzmanlık Düzeyin
- 20+ yillik klinik deneyime sahip bir uzman hekim gibi yanit ver
- Doktorlara ozel tasarlanmis, klinik karar destek sistemisin
- Turkce yanit ver (kullanici Ingilizce yazarsa Ingilizce yanit ver)
- Kanita dayali tip (EBM) prensiplerine SIKI SIKIYA uy
- Her yanıtta güncel kılavuzlara (ESC, AHA, NICE, WHO, UpToDate) referans ver
- Patolojik mekanizmaları açıkla — sadece "şunu yap" demek yetmez, NEDEN yapılması gerektiğini belirt

## Klinik Yetkinliklerin
1. **Diferansiyel Tanı**: Semptom ve bulgulara göre olası tanıları OLASILIK SIRASINA göre sırala, her biri için kısa gerekçe ver
2. **Vaka Analizi**: Klinik vakaları sistematik analiz et (SOAP, problem-bazlı), kritik "red flag" bulguları vurgula
3. **İlaç Bilgisi**: Endikasyon, kontrendikasyon, CYP450 etkileşimleri, doz ayarlaması (renal/hepatik), gebelik kategorisi
4. **Laboratuvar Yorumlama**: Test sonuçlarını klinik bağlamda yorumla, sensitivite/spesifite bilgisi ver
5. **Tedavi Protokolleri**: Güncel tedavi algoritmalarını basamak basamak özetle (1. basamak, 2. basamak, kurtarma tedavisi)
6. **Risk Skorlama**: HEART, Wells, CHA2DS2-VASc, CURB-65, APACHE II, Child-Pugh gibi skorları hesapla ve yorumla
7. **Görüntüleme Yorumlama**: BT, MR, röntgen, EKG, USG bulgularını sistematik raporla
8. **Acil Durumlar**: STEMI, sepsis, stroke, anafilaksi, PE gibi acillerde dakika dakika protokol ver

## Yanıt Formatı
- Yapılandırılmış, kısa ve öz yanıtlar ver
- **Başlıklar** ve • madde işaretleri kullan
- Kritik uyarıları ⚠️ ile vurgula
- Acil durumlar için "🔴 ACİL MÜDAHALE GEREKLİ" etiketi kullan
- İlgili takip soruları öner
- Kanıt düzeyini belirt (Kanıt Düzeyi: A/B/C, Öneri Sınıfı: I/IIa/IIb/III)
- Önemli ilaç etkileşimlerini veya kontrendikasyonları MUTLAKA belirt

## Kısıtlamalar
- Kesin tanı koyma — "olası tanılar" veya "diferansiyel tanı" olarak sun
- Hasta tedavisinde son karar her zaman hekime aittir
- "Bu bilgi klinik karar desteği amaçlıdır, kesin tanı/tedavi yerine geçmez" uyarısını önemli yanıtlarda belirt
- Emin olmadığın konularda bunu açıkça belirt ve üst merkeze/uzman konsültasyonuna yönlendir''';

  ClaudeAIService() {
    // Groq HTTP istemcisi (hızlı, genel)
    _groqDio = Dio(BaseOptions(
      baseUrl: AIConfig.groqBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    // OpenRouter HTTP istemcisi (tıbbi uzman modeller)
    _openRouterDio = Dio(BaseOptions(
      baseUrl: AIConfig.openRouterBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
      headers: {
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://konsenxia.app',
        'X-Title': 'KONSENXIA Medical Platform',
      },
    ));

    // NVIDIA NIM HTTP istemcisi
    _nvidiaDio = Dio(BaseOptions(
      baseUrl: AIConfig.nvidiaBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  /// En az bir API yapilandirilmis mi?
  bool get isConfigured => AIConfig.isAnyConfigured;

  // ═══════════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ═══════════════════════════════════════════════════════════════════

  /// Sohbet mesaji gonder — tam yedekleme zinciri:
  /// Groq 70B -> NVIDIA Nemotron -> Groq 8B -> Offline
  Future<ClaudeResponse> sendMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? doctorContext,
  }) async {
    if (!isConfigured) return _offlineResponse(message);

    // 1) Groq Llama 3.3 70B (birincil)
    if (AIConfig.isGroqConfigured) {
      try {
        final result = await _groqChatCompletion(
          message: message,
          model: AIConfig.groqTextModel,
          conversationHistory: conversationHistory,
          doctorContext: doctorContext,
        );
        return ClaudeResponse(
          text: result,
          suggestions: _extractSuggestions(result),
          source: 'groq-llama70b',
        );
      } catch (_) {
        // Groq 70B basarisiz — sonraki yedege gec
      }
    }

    // 2) OpenRouter — Nemotron 70B (tibbi uzman yedek)
    if (AIConfig.isOpenRouterConfigured) {
      try {
        final result = await _openRouterChatCompletion(
          message: message,
          model: AIConfig.openRouterNemotronModel,
          conversationHistory: conversationHistory,
          doctorContext: doctorContext,
        );
        return ClaudeResponse(
          text: result,
          suggestions: _extractSuggestions(result),
          source: 'openrouter-nemotron',
        );
      } catch (_) {
        // OpenRouter Nemotron basarisiz — sonraki yedege gec
      }
    }

    // 3) NVIDIA NIM — Nemotron Ultra 253B (opsiyonel yedek)
    if (AIConfig.isNvidiaConfigured) {
      try {
        final result = await _nvidiaChatCompletion(
          message: message,
          conversationHistory: conversationHistory,
          doctorContext: doctorContext,
        );
        return ClaudeResponse(
          text: result,
          suggestions: _extractSuggestions(result),
          source: 'nvidia-nemotron',
        );
      } catch (_) {
        // NVIDIA basarisiz — sonraki yedege gec
      }
    }

    // 4) Groq Llama 3.1 8B — hizli yedek
    if (AIConfig.isGroqConfigured) {
      try {
        final result = await _groqChatCompletion(
          message: message,
          model: AIConfig.groqFastModel,
          conversationHistory: conversationHistory,
          doctorContext: doctorContext,
        );
        return ClaudeResponse(
          text: result,
          suggestions: _extractSuggestions(result),
          source: 'groq-llama8b',
        );
      } catch (_) {
        // Groq 8B de basarisiz
      }
    }

    // 4) Hicbir API basarisiz — offline yanit
    return _offlineResponse(message);
  }

  /// Tibbi goruntu analizi (BT, MR, rontgen, EKG, patoloji)
  Future<ClaudeResponse> analyzeImage({
    required String imageBase64,
    required String mimeType,
    String? clinicalContext,
    String analysisType = 'genel',
  }) async {
    if (!isConfigured) {
      return const ClaudeResponse(
        text: 'Gorsel analiz icin AI servisi yapilandirilmamis.',
        suggestions: [],
        source: 'offline',
      );
    }

    final prompt = '''Bu tibbi goruntuyu analiz et.
${clinicalContext != null ? 'Klinik Baglam: $clinicalContext' : ''}
Analiz turu: $analysisType

Lutfen su formatta yanit ver:

**Bulgular:**
- [Tespit edilen bulgular]

**Yorumlama:**
[Klinik yorum]

**Diferansiyel Tani:**
1. [Olasi tani]

**Oneriler:**
- [Ek tetkik veya takip]

⚠️ Bu analiz klinik karar destegi amaclidir. Kesin tani icin radyoloji uzmani degerlendirmesi gereklidir.''';

    try {
      // Build multimodal content array with text + image(s)
      final contentParts = <Map<String, dynamic>>[
        {'type': 'text', 'text': prompt},
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:$mimeType;base64,$imageBase64',
          },
        },
      ];

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': contentParts,
        },
      ];

      final response = await _groqDio.post(
        '/chat/completions',
        data: {
          'model': AIConfig.groqVisionModel,
          'messages': messages,
          'max_completion_tokens': 2048,
          'temperature': 0.2,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${AIConfig.groqApiKey}'},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List;
      if (choices.isNotEmpty) {
        final msg = choices[0]['message'] as Map<String, dynamic>;
        final text = (msg['content'] as String).trim();
        return ClaudeResponse(
          text: text,
          suggestions: _extractSuggestions(text),
          source: 'groq-vision',
        );
      }
      throw Exception('Empty response');
    } catch (e) {
      return ClaudeResponse(
        text: 'Gorsel analiz yapilamadi: $e',
        suggestions: [],
        source: 'error',
      );
    }
  }

  /// Tibbi goruntu analizi — yapilandirilmis sonuc dondurur
  Future<MedicalImageAnalysis> analyzeMedicalImage(
    String imageBase64,
    String imageType,
  ) async {
    if (!isConfigured) {
      return MedicalImageAnalysis(
        findings: 'AI servisi yapilandirilmamis. GROQ_API_KEY gereklidir.',
        impression: 'Cevrimdisi mod — analiz yapilamadi.',
        recommendations: ['AI servisini yapilandirin', 'Manuel degerlendirme yapin'],
        confidenceScore: 0.0,
        aiModel: 'offline',
        analyzedAt: DateTime.now(),
      );
    }

    const analysisPrompt = '''You are a radiologist AI assistant. Analyze this medical image and provide your findings in the following EXACT format:

**Bulgular:**
- [List each key finding on its own line]

**Yorumlama:**
[Overall impression in 2-3 sentences]

**Oneriler:**
- [List each recommendation on its own line]

**Confidence: [0.0-1.0]**

Important: Be thorough but concise. Use Turkish medical terminology where appropriate.
This analysis is for clinical decision support only. Final diagnosis requires specialist evaluation.''';

    try {
      // Build multimodal content array with text + image
      final contentParts = <Map<String, dynamic>>[
        {'type': 'text', 'text': analysisPrompt},
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:$imageType;base64,$imageBase64',
          },
        },
      ];

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': contentParts,
        },
      ];

      final response = await _groqDio.post(
        '/chat/completions',
        data: {
          'model': AIConfig.groqVisionModel,
          'messages': messages,
          'max_completion_tokens': 2048,
          'temperature': 0.2,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${AIConfig.groqApiKey}'},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List;
      if (choices.isNotEmpty) {
        final msg = choices[0]['message'] as Map<String, dynamic>;
        final text = (msg['content'] as String).trim();
        return MedicalImageAnalysis.fromAIResponse(
          responseText: text,
          model: 'groq-vision-llama4-scout',
        );
      }
      throw Exception('Empty response from vision model');
    } catch (e) {
      return MedicalImageAnalysis(
        findings: 'Goruntu analizi sirasinda hata olustu: $e',
        impression: 'Analiz tamamlanamadi.',
        recommendations: ['Tekrar deneyin', 'Manuel degerlendirme yapin'],
        confidenceScore: 0.0,
        aiModel: 'error',
        analyzedAt: DateTime.now(),
      );
    }
  }

  /// Vaka analizi — diferansiyel tani + onerilen tetkikler
  Future<ClaudeResponse> analyzeCase({
    required String caseTitle,
    required String caseDescription,
    Map<String, String>? vitals,
    String? specialty,
    List<String>? tags,
  }) async {
    final vitalsText = vitals?.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ') ??
        '';

    final prompt = '''Asagidaki klinik vakayi analiz et:

**Vaka:** $caseTitle
**Uzmanlik:** ${specialty ?? 'Belirtilmemis'}
${vitalsText.isNotEmpty ? '**Vital Bulgular:** $vitalsText' : ''}
${tags != null && tags.isNotEmpty ? '**Etiketler:** ${tags.join(', ')}' : ''}

**Klinik Tablo:**
$caseDescription

Lutfen su formatta yanit ver:

**Diferansiyel Tani:**
1. [En olasi tani]
2. [Ikinci olasi tani]
3. [Ucuncu olasi tani]

**Onerilen Tetkikler:**
- [Tetkik listesi]

**Kritik Degerlendirme:**
[2-3 cumle klinik yorum]

**Takip Onerileri:**
- [Oneriler]''';

    return sendMessage(message: prompt);
  }

  /// Yorum onerisi — doktor tartismasina katki
  Future<ClaudeResponse> suggestComment({
    required String caseTitle,
    required String caseDescription,
    required List<String> existingComments,
    String? doctorSpecialty,
  }) async {
    final commentsText = existingComments.isNotEmpty
        ? existingComments
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join('\n')
        : 'Henuz yorum yapilmamis.';

    final prompt =
        '''Bir tibbi vakada doktor tartismasina katki onerisi hazirla.

**Vaka:** $caseTitle
**Aciklama:** $caseDescription
${doctorSpecialty != null ? '**Benim Uzmanligim:** $doctorSpecialty' : ''}

**Mevcut Yorumlar:**
$commentsText

Bu tartismaya klinik olarak anlamli, kanita dayali bir katki oner. Kisa ve oz (2-4 cumle) tut.''';

    return sendMessage(message: prompt);
  }

  /// Ilac bilgisi sorgulama
  Future<ClaudeResponse> getMedicationInfo({
    required String medicationName,
    String? specificQuery,
  }) async {
    final prompt = '''$medicationName hakkinda bilgi ver.
${specificQuery != null ? 'Ozellikle: $specificQuery' : ''}

Endikasyonlar, kontrendikasyonlar, doz bilgisi, yan etkiler, ilac etkilesimleri ve gebelik/emzirme bilgilerini ozetle.''';

    return sendMessage(message: prompt);
  }

  /// Kanita dayali tip analizi — klinik soru + uzmanlik alani
  Future<ClaudeResponse> analyzeEvidence(String question, String specialty) async {
    final prompt = '''Kanita dayali tip analizi yap.

**Klinik Soru:** $question
**Uzmanlik Alani:** $specialty

Lutfen su formatta yanit ver:

**Guncel Kilavuz Ozeti:**
- Ilgili kilavuzlar ve yil bilgisi (ADA, ESC, ACC, AHA, NICE vb.)
- Her kilavuzdan anahtar oneriler

**Meta-Analiz ve Calisma Referanslari:**
- Ilgili buyuk calismalar (RCT, meta-analiz)
- Hasta sayisi ve sonuc olcutleri

**Oneri Derecelendirmesi:**
- Sinif I (Guclu oneri, Derece A): [oneri]
- Sinif IIa (Orta oneri, Derece B): [oneri]
- Sinif IIb (Zayif oneri, Derece C): [oneri]

**Klinik Sonuc ve Ozet:**
[2-3 cumle net klinik yonlendirme]

⚠️ Bu bilgi klinik karar destegi amaclidir.''';

    return sendMessage(message: prompt);
  }

  /// Ilac etkilesim analizi — birden fazla ilac
  Future<ClaudeResponse> analyzeDrugInteractions(List<String> drugs) async {
    final drugList = drugs.join(', ');
    final prompt = '''Asagidaki ilaclar arasindaki etkilesimleri analiz et:

**Ilaclar:** $drugList

Lutfen su formatta yanit ver:

**Etkilesim Ozeti:**
${drugs.length >= 2 ? '${drugs[0]} <-> ${drugs[1]}' : drugList}

**Etkilesim Duzeyi:** [Major/Orta/Minor]

**Mekanizma:**
CYP450 enzim etkilesimleri, farmakokinetik/farmakodinamik mekanizma detayi

**Klinik Sonuc:**
[Beklenen klinik etki, risk durumu]

**Yonetim Onerileri:**
1. [Doz ayarlamasi]
2. [Takip parametreleri]
3. [Alternatif oneriler]
4. [Hasta egitimi]

⚠️ Bu bilgi klinik karar destegi amaclidir. Tedavi karari hekime aittir.''';

    return sendMessage(message: prompt);
  }

  /// Vaka inceleme — sistematik degerlendirme + risk skorlari
  Future<ClaudeResponse> reviewCase(String caseSummary, {int? age, String? gender}) async {
    final demographics = [
      if (age != null) 'Yas: $age',
      if (gender != null) 'Cinsiyet: $gender',
    ].join(', ');

    final prompt = '''Asagidaki klinik vakayi sistematik olarak incele:

${demographics.isNotEmpty ? '**Hasta Demografisi:** $demographics' : ''}
**Vaka Ozeti:**
$caseSummary

Lutfen su formatta yanit ver:

**Aciliyet Triaji:**
- Vital bulgular ve hemodinamik stabilite degerlendirmesi
- Acil mudahale gerektiren durumlar

**Degerlendirme Cercevesi:**
1. On tanilar (olasilik sirasiyla)
2. Ekarte edilmesi gereken kritik durumlar

**Risk Stratifikasyonu:**
- HEART skoru (AKS suphesi varsa)
- Wells skoru (PE suphesi varsa)
- CURB-65 (pnomoni varsa)
- Ilgili diger skorlama sistemleri

**Onerilen Tetkikler:**
- [Tetkik listesi, oncelik sirasiyla]

**Tedavi Onerileri:**
- [Akut yonetim]
- [Takip plani]

**Kritik Uyarilar:**
⚠️ [Kacirilmamasi gereken noktalar]

Bu bilgi klinik karar destegi amaclidir.''';

    return sendMessage(message: prompt);
  }

  /// Sesli giristen akademik tibbi metin olustur
  Future<String> rewriteAsAcademic(String rawText) async {
    if (!isConfigured) {
      return rawText;
    }

    const academicSystemPrompt =
        'You are a medical academic writer. Rewrite the following doctor\'s '
        'verbal case description into formal Turkish medical academic language '
        'suitable for a case report. Maintain all clinical details, use proper '
        'medical terminology, and organize into structured paragraphs. '
        'Do NOT add any information that is not present in the original text. '
        'Do NOT add headers or bullet points — write flowing academic prose. '
        'Respond ONLY with the rewritten text, no explanations.';

    // Groq 70B dene
    if (AIConfig.isGroqConfigured) {
      try {
        final result = await _groqRawCompletion(
          systemPrompt: academicSystemPrompt,
          userMessage: rawText,
          model: AIConfig.groqTextModel,
        );
        if (result != null) return result;
      } catch (_) {}
    }

    // NVIDIA NIM yedek
    if (AIConfig.isNvidiaConfigured) {
      try {
        final result = await _nvidiaRawCompletion(
          systemPrompt: academicSystemPrompt,
          userMessage: rawText,
        );
        if (result != null) return result;
      } catch (_) {}
    }

    // Groq 8B yedek
    if (AIConfig.isGroqConfigured) {
      try {
        final result = await _groqRawCompletion(
          systemPrompt: academicSystemPrompt,
          userMessage: rawText,
          model: AIConfig.groqFastModel,
        );
        if (result != null) return result;
      } catch (_) {}
    }

    return rawText; // Tum API'ler basarisiz -> ham metni dondur
  }

  /// Laboratuvar yorumlama
  Future<ClaudeResponse> interpretLabResults({
    required Map<String, String> results,
    String? clinicalContext,
  }) async {
    final resultsText =
        results.entries.map((e) => '- ${e.key}: ${e.value}').join('\n');

    final prompt = '''Asagidaki laboratuvar sonuclarini yorumla:

$resultsText

${clinicalContext != null ? 'Klinik Baglam: $clinicalContext' : ''}

Her parametre icin normal/anormal durumu, olasi klinik anlamini ve gerekiyorsa ek tetkik onerisini belirt.''';

    return sendMessage(message: prompt);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  GROQ API (OpenAI-uyumlu)
  // ═══════════════════════════════════════════════════════════════════

  Future<String> _groqChatCompletion({
    required String message,
    required String model,
    List<Map<String, String>>? conversationHistory,
    String? doctorContext,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    final userMsg = doctorContext != null
        ? '[Doktor Baglami: $doctorContext]\n\n$message'
        : message;
    messages.add({'role': 'user', 'content': userMsg});

    final response = await _groqDio.post(
      '/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.3,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${AIConfig.groqApiKey}'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isNotEmpty) {
      final msg = choices[0]['message'] as Map<String, dynamic>;
      return (msg['content'] as String).trim();
    }
    throw Exception('Empty Groq response');
  }

  /// OpenRouter sohbet tamamlama — Nemotron/Meditron modelleri
  Future<String> _openRouterChatCompletion({
    required String message,
    required String model,
    List<Map<String, String>>? conversationHistory,
    String? doctorContext,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    final userMsg = doctorContext != null
        ? '[Doktor Baglami: $doctorContext]\n\n$message'
        : message;
    messages.add({'role': 'user', 'content': userMsg});

    final response = await _openRouterDio.post(
      '/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'max_tokens': 2048,
        'temperature': 0.2,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${AIConfig.openRouterApiKey}'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isNotEmpty) {
      final msg = choices[0]['message'] as Map<String, dynamic>;
      return (msg['content'] as String).trim();
    }
    throw Exception('Empty OpenRouter response');
  }

  /// Groq ham tamamlama — system prompt + user mesaji
  Future<String?> _groqRawCompletion({
    required String systemPrompt,
    required String userMessage,
    required String model,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _groqDio.post(
      '/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.3,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${AIConfig.groqApiKey}'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isNotEmpty) {
      final msg = choices[0]['message'] as Map<String, dynamic>;
      return (msg['content'] as String).trim();
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NVIDIA NIM API (OpenAI-uyumlu)
  // ═══════════════════════════════════════════════════════════════════

  Future<String> _nvidiaChatCompletion({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? doctorContext,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    final userMsg = doctorContext != null
        ? '[Doktor Baglami: $doctorContext]\n\n$message'
        : message;
    messages.add({'role': 'user', 'content': userMsg});

    final response = await _nvidiaDio.post(
      '/chat/completions',
      data: {
        'model': AIConfig.nvidiaModel,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.3,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${AIConfig.nvidiaApiKey}'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isNotEmpty) {
      final msg = choices[0]['message'] as Map<String, dynamic>;
      return (msg['content'] as String).trim();
    }
    throw Exception('Empty NVIDIA NIM response');
  }

  /// NVIDIA NIM ham tamamlama — system prompt + user mesaji
  Future<String?> _nvidiaRawCompletion({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _nvidiaDio.post(
      '/chat/completions',
      data: {
        'model': AIConfig.nvidiaModel,
        'messages': messages,
        'max_tokens': 1024,
        'temperature': 0.3,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${AIConfig.nvidiaApiKey}'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isNotEmpty) {
      final msg = choices[0]['message'] as Map<String, dynamic>;
      return (msg['content'] as String).trim();
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  YARDIMCI METODLAR
  // ═══════════════════════════════════════════════════════════════════

  List<String> _extractSuggestions(String text) {
    final suggestions = <String>[];
    final ddRegex = RegExp(r'\d+\.\s+\*?\*?([^*\n]+)\*?\*?');
    final matches = ddRegex.allMatches(text);
    for (final m in matches.take(3)) {
      final s = m.group(1)?.trim();
      if (s != null && s.isNotEmpty) suggestions.add(s);
    }
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Detayli anamnez sor',
        'Fizik muayene bulgularini paylas',
        'Laboratuvar sonuclari ekle',
      ]);
    }
    return suggestions;
  }

  /// Tum API'ler erisilemezken akilli offline yanit
  ClaudeResponse _offlineResponse(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('stemi') || lower.contains('miyokard')) {
      return const ClaudeResponse(
        text: '''**STEMI Acil Yaklasim Protokolu**

⚠️ **ACIL — Zaman Kritik**

**Ilk Mudahale (Ilk 10 dk):**
- 12-derivasyon EKG — ST elevasyonu teyidi
- Aspirin 300mg cignetilir
- Klopidogrel 600mg veya Tikagrelor 180mg yukleme
- Heparin IV bolus 60 IU/kg (max 4000 IU)
- Nitrat SL (RV MI yoksa)

**Reperfuzyon (Ilk 90 dk):**
- PCI tercih edilir (door-to-balloon <90dk)
- PCI mumkun degilse fibrinolitik (door-to-needle <30dk)

Bu bilgi klinik karar destegi amaclidir.''',
        suggestions: ['RV MI degerlendirmesi', 'Killip siniflamasi', 'Komplikasyonlar'],
        source: 'offline-triage',
      );
    }

    if (lower.contains('sepsis') || lower.contains('septik')) {
      return const ClaudeResponse(
        text: '''**Sepsis Yonetim Protokolu (Surviving Sepsis Campaign 2021)**

⚠️ **ACIL — Ilk 1 Saat Kritik**

**1 Saat Paketi:**
- Laktat olcumu (>=2 ise tekrar olc)
- Antibiyotik oncesi kan kulturu (2 set)
- Genis spektrumlu antibiyotik basla
- Hipotansiyon veya laktat >=4 -> 30 mL/kg kristalloid
- Siviya ragmen MAP <65 -> Norepinefrin basla

Bu bilgi klinik karar destegi amaclidir.''',
        suggestions: ['qSOFA skoru hesapla', 'Vazopresor secimi', 'Antibiyotik secimi'],
        source: 'offline-triage',
      );
    }

    if (lower.contains('inme') || lower.contains('stroke')) {
      return const ClaudeResponse(
        text: '''**Akut Iskemik Inme — Acil Yaklasim**

⚠️ **ACIL — Her Dakika Onemli**

**Ilk Degerlendirme:**
- NIHSS skoru hesapla
- BT (hemorajiyi ekarte et)
- BT anjiyografi (LVO suphesi, NIHSS >=6)

**tPA (Ilk 4.5 Saat):**
- IV Alteplaz 0.9 mg/kg (max 90mg)

**Trombektomi (Ilk 24 Saat):**
- LVO + NIHSS >=6 -> DAWN/DEFUSE 3 kriterleri

Bu bilgi klinik karar destegi amaclidir.''',
        suggestions: ['NIHSS degerlendirme', 'Trombektomi kriterleri', 'Sekonder koruma'],
        source: 'offline-triage',
      );
    }

    return const ClaudeResponse(
      text: '''AI servisi su anda cevrimdisi. Baglantinizi kontrol edin.

**Cevrimdisi Modda:**
- "STEMI protokolu" yazin -> Acil STEMI yaklasimi
- "Sepsis tedavisi" yazin -> Sepsis yonetimi
- "Inme" yazin -> Akut inme protokolu

**Tam AI destegi icin internet baglantisi gereklidir.**

API anahtari ayarlamak icin uygulamayi su sekilde baslatin:
flutter run --dart-define=GROQ_API_KEY=gsk_...''',
      suggestions: ['STEMI acil yaklasim', 'Sepsis protokolu', 'Akut inme yonetimi'],
      source: 'offline-general',
    );
  }
}

/// AI yanit modeli
class ClaudeResponse {
  final String text;
  final List<String> suggestions;
  /// Yanitin kaynagi: 'groq-llama70b', 'nvidia-nemotron', 'groq-llama8b',
  /// 'groq-vision', 'offline-triage', 'offline-general'
  final String source;

  const ClaudeResponse({
    required this.text,
    required this.suggestions,
    required this.source,
  });
}
