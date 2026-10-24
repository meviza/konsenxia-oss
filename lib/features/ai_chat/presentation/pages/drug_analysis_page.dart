import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../../core/services/claude_ai_service.dart';

/// KONSENXIA — İlaç Etkileşim Analiz Sayfası
///
/// Birden fazla ilaç girişi → CYP450 etkileşimleri, şiddet derecelendirmesi,
/// mekanizma açıklaması ve klinik yönetim önerileri.
class DrugAnalysisPage extends StatefulWidget {
  const DrugAnalysisPage({super.key});

  @override
  State<DrugAnalysisPage> createState() => _DrugAnalysisPageState();
}

class _DrugAnalysisPageState extends State<DrugAnalysisPage> {
  final _scrollCtrl = ScrollController();
  final List<TextEditingController> _drugControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isLoading = false;
  ClaudeResponse? _result;
  String? _errorText;

  static const _accent = KxColors.amber300;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in _drugControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addDrugField() {
    if (_drugControllers.length >= 6) return;
    setState(() => _drugControllers.add(TextEditingController()));
  }

  void _removeDrugField(int index) {
    if (_drugControllers.length <= 2) return;
    setState(() {
      _drugControllers[index].dispose();
      _drugControllers.removeAt(index);
    });
  }

  Future<void> _analyze() async {
    final drugs = _drugControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (drugs.length < 2) {
      setState(() => _errorText = 'En az 2 ilaç girmeniz gerekiyor.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _result = null;
    });

    try {
      final service = GetIt.instance<ClaudeAIService>();
      final response = await service.analyzeDrugInteractions(drugs);
      if (!mounted) return;
      setState(() {
        _result = response;
        _isLoading = false;
      });
      _scrollToResults();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Analiz sırasında hata: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: KxColors.bgSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: KxColors.textPrimary, size: 18),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/profile'),
            ),
            title: Row(
              children: [
                const Icon(Icons.medication_rounded,
                    color: _accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('İlaç Etkileşim Analizi',
                          style: KxTypography.headingSm),
                      Text('CYP450 & Klinik Etkileşim',
                          style: KxTypography.caption
                              .copyWith(color: _accent)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: KxSpacing.radiusPill,
                  border: Border.all(color: _accent.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: _accent, size: 12),
                  const SizedBox(width: 4),
                  Text('AI Pro',
                      style:
                          KxTypography.caption.copyWith(color: _accent)),
                ]),
              ),
            ],
          ),

          // ── Giriş Bölümü ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık açıklaması
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.06),
                      borderRadius: KxSpacing.radiusMd,
                      border:
                          Border.all(color: _accent.withOpacity(0.15)),
                    ),
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded,
                          color: _accent, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'En az 2 ilaç girerek CYP450 etkileşimlerini, şiddet derecesini ve klinik yönetim önerilerini analiz edin.',
                          style: KxTypography.caption.copyWith(
                              color: KxColors.textSecondary,
                              height: 1.4),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // İlaç giriş alanları
                  Text('İlaçlar',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 10),

                  ...List.generate(_drugControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.12),
                              borderRadius: KxSpacing.radiusFull,
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                  style: KxTypography.caption.copyWith(
                                      color: _accent,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _drugControllers[i],
                              style: KxTypography.bodyMd.copyWith(
                                  color: KxColors.textPrimary),
                              cursorColor: _accent,
                              decoration: InputDecoration(
                                hintText: i == 0
                                    ? 'Ör: Warfarin'
                                    : i == 1
                                        ? 'Ör: Flukonazol'
                                        : 'İlaç adı...',
                                hintStyle: KxTypography.bodyMd
                                    .copyWith(color: KxColors.textMuted),
                                filled: true,
                                fillColor: KxColors.bgCard,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: KxSpacing.radiusMd,
                                  borderSide:
                                      BorderSide(color: KxColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: KxSpacing.radiusMd,
                                  borderSide:
                                      BorderSide(color: KxColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: KxSpacing.radiusMd,
                                  borderSide: BorderSide(
                                      color: _accent, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          if (_drugControllers.length > 2) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _removeDrugField(i),
                              child: Icon(Icons.remove_circle_outline_rounded,
                                  color: KxColors.crimson400, size: 20),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  // İlaç ekle butonu
                  if (_drugControllers.length < 6)
                    GestureDetector(
                      onTap: _addDrugField,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: KxColors.bgCard,
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(
                              color: _accent.withOpacity(0.3),
                              style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: _accent, size: 18),
                            const SizedBox(width: 6),
                            Text('İlaç Ekle',
                                style: KxTypography.labelSm
                                    .copyWith(color: _accent)),
                          ],
                        ),
                      ),
                    ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorText!,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.crimson400)),
                  ],

                  const SizedBox(height: 16),

                  // Örnek etkileşimler
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SuggestionChip(
                        label: 'Warfarin + Flukonazol',
                        onTap: () {
                          _drugControllers[0].text = 'Warfarin';
                          _drugControllers[1].text = 'Flukonazol';
                        },
                      ),
                      _SuggestionChip(
                        label: 'Metformin + Enalapril',
                        onTap: () {
                          _drugControllers[0].text = 'Metformin';
                          _drugControllers[1].text = 'Enalapril';
                        },
                      ),
                      _SuggestionChip(
                        label: 'Simvastatin + Amiodaron',
                        onTap: () {
                          _drugControllers[0].text = 'Simvastatin';
                          _drugControllers[1].text = 'Amiodaron';
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Analiz Et butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _analyze,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.medication_rounded, size: 18),
                      label: Text(_isLoading
                          ? 'Analiz ediliyor...'
                          : 'Etkileşim Analiz Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: KxColors.bgBase,
                        shape: RoundedRectangleBorder(
                            borderRadius: KxSpacing.radiusMd),
                        textStyle: KxTypography.labelMd,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sonuç Bölümü ──────────────────────────────────────────
          if (_result != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: _DrugResultView(
                  result: _result!,
                  drugs: _drugControllers
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList(),
                  onCopy: _copyResult,
                  onShare: _shareResult,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copyResult() {
    if (_result == null) return;
    Clipboard.setData(ClipboardData(text: _result!.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sonuçlar panoya kopyalandı'),
        backgroundColor: KxColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
      ),
    );
  }

  void _shareResult() => _copyResult();
}

// ── Sonuç Görünümü ───────────────────────────────────────────────────────────

class _DrugResultView extends StatelessWidget {
  final ClaudeResponse result;
  final List<String> drugs;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _DrugResultView({
    required this.result,
    required this.drugs,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final severity = _parseSeverity(result.text);
    final severityColor = _severityColor(severity);
    final severityLabel = _severityLabel(severity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Şiddet başlığı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.08),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: severityColor.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: severityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Etkileşim Analizi: ${drugs.join(' + ')}',
                      style: KxTypography.labelMd
                          .copyWith(color: KxColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Şiddet: $severityLabel',
                      style: KxTypography.caption.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.15),
                borderRadius: KxSpacing.radiusPill,
                border: Border.all(color: severityColor.withOpacity(0.4)),
              ),
              child: Text(
                severityLabel,
                style: KxTypography.caption.copyWith(
                    color: severityColor, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ),

        // Detay kartları
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            border: Border(
              left: BorderSide(color: severityColor.withOpacity(0.2)),
              right: BorderSide(color: severityColor.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mekanizma bölümü
              _DetailSection(
                icon: Icons.settings_rounded,
                title: 'Mekanizma',
                color: KxColors.blue400,
                content: _extractSection(result.text, 'Mekanizma'),
              ),
              const SizedBox(height: 12),

              // Klinik sonuç
              _DetailSection(
                icon: Icons.warning_amber_rounded,
                title: 'Klinik Sonuç',
                color: KxColors.amber300,
                content: _extractSection(result.text, 'Klinik Sonuç'),
              ),
              const SizedBox(height: 12),

              // Yönetim önerileri
              _DetailSection(
                icon: Icons.checklist_rounded,
                title: 'Yönetim Önerileri',
                color: KxColors.jade300,
                content: _extractSection(result.text, 'Yönetim'),
              ),
            ],
          ),
        ),

        // Tam yanıt
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            border: Border(
              left: BorderSide(color: severityColor.withOpacity(0.2)),
              right: BorderSide(color: severityColor.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detaylı Rapor',
                  style: KxTypography.labelSm
                      .copyWith(color: KxColors.textSecondary)),
              const SizedBox(height: 8),
              Text(result.text,
                  style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textSecondary, height: 1.6)),
            ],
          ),
        ),

        // Alt bölüm — eylemler
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border(
              left: BorderSide(color: severityColor.withOpacity(0.2)),
              right: BorderSide(color: severityColor.withOpacity(0.2)),
              bottom: BorderSide(color: severityColor.withOpacity(0.2)),
            ),
          ),
          child: Column(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KxColors.bgSurface,
                borderRadius: KxSpacing.radiusSm,
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    color: KxColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bu bilgi klinik karar desteği amaçlıdır. Tedavi kararı hekime aittir.',
                    style: KxTypography.caption
                        .copyWith(color: KxColors.textMuted, fontSize: 10),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Kopyala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KxColors.amber300,
                    side: BorderSide(
                        color: KxColors.amber300.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: KxSpacing.radiusMd),
                    textStyle: KxTypography.labelSm,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Paylaş'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KxColors.amber300,
                    side: BorderSide(
                        color: KxColors.amber300.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: KxSpacing.radiusMd),
                    textStyle: KxTypography.labelSm,
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ],
    );
  }

  String _parseSeverity(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('majör') || lower.contains('major') || lower.contains('ciddi')) {
      return 'major';
    }
    if (lower.contains('orta') || lower.contains('moderate') || lower.contains('moderata')) {
      return 'moderate';
    }
    return 'minor';
  }

  Color _severityColor(String severity) {
    return switch (severity) {
      'major' => KxColors.crimson400,
      'moderate' => KxColors.amber300,
      _ => KxColors.jade300,
    };
  }

  String _severityLabel(String severity) {
    return switch (severity) {
      'major' => 'Majör',
      'moderate' => 'Orta',
      _ => 'Minör',
    };
  }

  String _extractSection(String text, String sectionName) {
    final patterns = [
      '**$sectionName:**',
      '**$sectionName**:',
      '$sectionName:',
      '## $sectionName',
    ];
    for (final p in patterns) {
      final idx = text.indexOf(p);
      if (idx >= 0) {
        final start = idx + p.length;
        // Sonraki bölüm başlığına kadar al
        final nextSection = RegExp(r'\n\s*(?:\*\*|##)').firstMatch(
            text.substring(start));
        final end = nextSection != null
            ? start + nextSection.start
            : (start + 300).clamp(0, text.length);
        return text.substring(start, end).trim();
      }
    }
    return '';
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(title,
                style:
                    KxTypography.labelSm.copyWith(color: color)),
          ]),
          const SizedBox(height: 8),
          Text(content,
              style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusPill,
          border: Border.all(color: KxColors.border),
        ),
        child: Text(label,
            style: KxTypography.caption
                .copyWith(color: KxColors.textSecondary)),
      ),
    );
  }
}
