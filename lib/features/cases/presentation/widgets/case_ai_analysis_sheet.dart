import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/claude_ai_service.dart';
import '../../../../design_system/design_system.dart';

/// KONSENXIA — Vaka AI Analiz Bottom Sheet
///
/// Case detail'deki "AI" butonuna basıldığında açılır.
/// Meditron-7B/Claude API üzerinden:
///   - Diferansiyel tanı listesi
///   - Önerilen tetkikler
///   - Risk faktörleri
///   - Kısa klinik yorum
Future<void> showCaseAiAnalysisSheet({
  required BuildContext context,
  required String caseId,
  required String caseTitle,
  required String caseDescription,
  String? specialty,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CaseAiAnalysisSheet(
      caseTitle: caseTitle,
      caseDescription: caseDescription,
      specialty: specialty,
    ),
  );
}

class _CaseAiAnalysisSheet extends StatefulWidget {
  final String caseTitle;
  final String caseDescription;
  final String? specialty;

  const _CaseAiAnalysisSheet({
    required this.caseTitle,
    required this.caseDescription,
    this.specialty,
  });

  @override
  State<_CaseAiAnalysisSheet> createState() => _CaseAiAnalysisSheetState();
}

class _CaseAiAnalysisSheetState extends State<_CaseAiAnalysisSheet> {
  final _questionCtrl = TextEditingController();
  final _apiClient = ApiClient();

  String? _analysisResult;
  bool _loading = false;
  String? _error;
  String _source = '';

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis([String? question]) async {
    setState(() { _loading = true; _error = null; _analysisResult = null; });

    // Önce backend'i dene, başarısız olursa doğrudan Claude API kullan
    try {
      final result = await _apiClient.caseAnalysis(
        caseTitle: widget.caseTitle,
        caseDescription: widget.caseDescription,
        specialty: widget.specialty,
        question: question,
      );

      final data = result['data'] as Map<String, dynamic>? ?? result;
      setState(() {
        _analysisResult = data['result'] as String? ?? 'Sonuç alınamadı.';
        _source = data['source'] as String? ?? '';
        _loading = false;
      });
    } catch (_) {
      // Backend erişilemez → Claude AI direct fallback
      try {
        final claudeAI = GetIt.instance<ClaudeAIService>();

        ClaudeResponse response;
        if (question != null && question.isNotEmpty) {
          // Spesifik soru — vaka bağlamıyla birlikte
          response = await claudeAI.sendMessage(
            message: question,
            doctorContext: 'Vaka: ${widget.caseTitle}\n${widget.caseDescription}',
          );
        } else {
          // Tam vaka analizi
          response = await claudeAI.analyzeCase(
            caseTitle: widget.caseTitle,
            caseDescription: widget.caseDescription,
            specialty: widget.specialty,
          );
        }

        setState(() {
          _analysisResult = response.text;
          _source = response.source;
          _loading = false;
        });
      } catch (e2) {
        setState(() {
          _error = 'AI servisi yanıt vermedi. Lütfen internet bağlantınızı kontrol edin.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final maxH = MediaQuery.of(context).size.height * 0.88;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: topPad + 40),
      constraints: BoxConstraints(maxHeight: maxH),
      padding: EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 0),
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: KxColors.border),
          left: BorderSide(color: KxColors.border),
          right: BorderSide(color: KxColors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: KxColors.textDisabled,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: KxColors.teal400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Vaka Analizi',
                              style: KxTypography.headingSm),
                          Text(
                            widget.caseTitle,
                            style: KxTypography.caption.copyWith(
                              color: KxColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: KxColors.textSecondary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: KxColors.border, height: 16),

          // Analiz içeriği
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _loading
                  ? _LoadingIndicator()
                  : _error != null
                      ? _ErrorView(error: _error!, onRetry: _runAnalysis)
                      : _AnalysisResult(
                          result: _analysisResult!,
                          source: _source,
                        ),
            ),
          ),

          // Soru sorma alanı
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: KxColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: KxTextField(
                    controller: _questionCtrl,
                    hint: 'Belirli bir soru sorun...',
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loading ? null : () {
                    final q = _questionCtrl.text.trim();
                    _questionCtrl.clear();
                    _runAnalysis(q.isEmpty ? null : q);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: _loading
                          ? null
                          : const LinearGradient(
                              colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                            ),
                      color: _loading ? KxColors.bgCard : null,
                      borderRadius: KxSpacing.radiusMd,
                    ),
                    child: _loading
                        ? const Center(
                            child: SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: KxColors.teal400,
                              ),
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yükleniyor ────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2, color: KxColors.teal400,
          ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: KxColors.teal400),
          const SizedBox(height: 16),
          Text(
            'AI analiz yapıyor...',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Diferansiyel tanı ve tetkik önerileri hazırlanıyor.',
            style: KxTypography.caption,
          ),
        ],
      ),
    );
  }
}

// ── Hata Görünümü ────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: KxColors.crimson400),
          const SizedBox(height: 12),
          Text(error,
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          KxButton.secondary(label: 'Tekrar Dene', onPressed: onRetry),
        ],
      ),
    );
  }
}

// ── Analiz Sonucu ─────────────────────────────────────────────────

class _AnalysisResult extends StatelessWidget {
  final String result;
  final String source;
  const _AnalysisResult({required this.result, required this.source});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kaynak badge
        if (source.isNotEmpty) ...[
          Row(
            children: [
              KxBadge.teal(
                source.startsWith('groq')
                    ? '⚡ Groq AI'
                    : source == 'meditron' || source == 'meditron-7b'
                        ? '⚕ Meditron-7B'
                        : source.startsWith('offline')
                            ? '📴 Çevrimdışı'
                            : 'AI',
              ),
              const SizedBox(width: 6),
              Text('tarafından üretildi',
                  style: KxTypography.caption),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Analiz metni (bölümlere ayrılmış)
        ..._parseResult(result).map((section) =>
          _ResultSection(
            title: section.title,
            content: section.content,
          ).animate().fadeIn(delay: 80.ms)
        ),

        const SizedBox(height: 24),

        // Uyarı
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: KxColors.amber300.withOpacity(0.06),
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(
              color: KxColors.amber300.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 16, color: KxColors.amber300),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bu analiz tıbbi karar desteği amaçlıdır; '
                  'klinik değerlendirmenin yerini tutmaz.',
                  style: KxTypography.caption.copyWith(
                    color: KxColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<_Section> _parseResult(String text) {
    // **Başlık:** formatında bölümlere ayır
    final sections = <_Section>[];
    final lines = text.split('\n');

    String currentTitle = 'Analiz';
    final currentContent = <String>[];

    for (final line in lines) {
      if (line.startsWith('**') && line.endsWith('**') ||
          (line.startsWith('**') && line.contains(':**'))) {
        if (currentContent.isNotEmpty) {
          sections.add(_Section(
            title: currentTitle,
            content: currentContent.join('\n').trim(),
          ));
          currentContent.clear();
        }
        currentTitle = line.replaceAll('**', '').replaceAll(':', '').trim();
      } else if (line.isNotEmpty) {
        currentContent.add(line);
      }
    }

    if (currentContent.isNotEmpty) {
      sections.add(_Section(
        title: currentTitle,
        content: currentContent.join('\n').trim(),
      ));
    }

    if (sections.isEmpty) {
      return [_Section(title: 'Analiz', content: text)];
    }
    return sections;
  }
}

class _Section {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String content;
  const _ResultSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3, height: 14,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: KxColors.teal400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(title, style: KxTypography.labelMd
                    .copyWith(color: KxColors.teal400)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textPrimary,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
