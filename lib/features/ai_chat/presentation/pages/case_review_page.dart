import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../../core/services/claude_ai_service.dart';

/// KONSENXIA — Vaka İnceleme Sayfası
///
/// Hasta vakası özeti + demografik bilgiler → Sistematik inceleme,
/// risk skorları (HEART, Wells, CURB-65), yapılandırılmış öneriler.
class CaseReviewPage extends StatefulWidget {
  const CaseReviewPage({super.key});

  @override
  State<CaseReviewPage> createState() => _CaseReviewPageState();
}

class _CaseReviewPageState extends State<CaseReviewPage> {
  final _scrollCtrl = ScrollController();
  final _caseSummaryCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _selectedGender = 'Erkek';
  bool _isLoading = false;
  ClaudeResponse? _result;
  String? _errorText;

  static const _accent = KxColors.jade300;

  static const _genderOptions = ['Erkek', 'Kadın', 'Diğer'];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _caseSummaryCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final summary = _caseSummaryCtrl.text.trim();
    if (summary.isEmpty) {
      setState(() => _errorText = 'Lütfen vaka özetini girin.');
      return;
    }

    final age = int.tryParse(_ageCtrl.text.trim());

    setState(() {
      _isLoading = true;
      _errorText = null;
      _result = null;
    });

    try {
      final service = GetIt.instance<ClaudeAIService>();
      final response = await service.reviewCase(
        summary,
        age: age,
        gender: _selectedGender,
      );
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
                const Icon(Icons.folder_open_rounded,
                    color: _accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaka İnceleme', style: KxTypography.headingSm),
                      Text('Sistematik Değerlendirme & Risk Skoru',
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
                  // Hasta demografisi
                  Text('Hasta Demografisi',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Yaş
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          style: KxTypography.bodyMd
                              .copyWith(color: KxColors.textPrimary),
                          cursorColor: _accent,
                          decoration: InputDecoration(
                            hintText: 'Yaş',
                            hintStyle: KxTypography.bodyMd
                                .copyWith(color: KxColors.textMuted),
                            filled: true,
                            fillColor: KxColors.bgCard,
                            prefixIcon: Icon(Icons.cake_outlined,
                                color: KxColors.textMuted, size: 18),
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
                      const SizedBox(width: 12),

                      // Cinsiyet
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: KxColors.bgCard,
                            borderRadius: KxSpacing.radiusMd,
                            border: Border.all(color: KxColors.border),
                          ),
                          child: Row(
                            children: _genderOptions.map((g) {
                              final sel = g == _selectedGender;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedGender = g),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? _accent.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: KxSpacing.radiusSm,
                                      border: sel
                                          ? Border.all(
                                              color:
                                                  _accent.withOpacity(0.4))
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        g,
                                        style: KxTypography.caption.copyWith(
                                            color: sel
                                                ? _accent
                                                : KxColors.textMuted,
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Vaka özeti
                  Text('Vaka Özeti',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _caseSummaryCtrl,
                    maxLines: 6,
                    minLines: 4,
                    style: KxTypography.bodyMd
                        .copyWith(color: KxColors.textPrimary),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      hintText:
                          'Hasta hikayesi, semptomlar, bulgular, mevcut tedavi...\n\nÖr: 63 yaşında erkek hasta, HT ve DM Tip 2 öyküsü. Son 2 saattir göğüs ağrısı. EKG\'de V1-V4 ST elevasyonu.',
                      hintStyle: KxTypography.bodyMd
                          .copyWith(color: KxColors.textMuted),
                      filled: true,
                      fillColor: KxColors.bgCard,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: KxSpacing.radiusMd,
                        borderSide: BorderSide(color: KxColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: KxSpacing.radiusMd,
                        borderSide: BorderSide(color: KxColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: KxSpacing.radiusMd,
                        borderSide:
                            BorderSide(color: _accent, width: 1.5),
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

                  // Örnek vakalar
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SuggestionChip(
                        label: 'STEMI + HT hasta',
                        onTap: () {
                          _ageCtrl.text = '63';
                          _selectedGender = 'Erkek';
                          _caseSummaryCtrl.text =
                              '63 yaşında erkek, HT ve DM Tip 2 öyküsü. Son 2 saattir göğüs ağrısı, sol kola yayılım. EKG\'de V1-V4 ST elevasyonu. Troponin I: 2.4 ng/mL.';
                          setState(() {});
                        },
                      ),
                      _SuggestionChip(
                        label: 'Pnömoni şüphesi',
                        onTap: () {
                          _ageCtrl.text = '72';
                          _selectedGender = 'Kadın';
                          _caseSummaryCtrl.text =
                              '72 yaşında kadın, KOAH öyküsü. 3 gündür ateş, öksürük, balgam. SpO2: %88. AC grafide sağ alt lobda konsolidasyon.';
                          setState(() {});
                        },
                      ),
                      _SuggestionChip(
                        label: 'PE şüphesi',
                        onTap: () {
                          _ageCtrl.text = '45';
                          _selectedGender = 'Kadın';
                          _caseSummaryCtrl.text =
                              '45 yaşında kadın, OKS kullanıyor. Ani başlangıçlı dispne ve plöritik göğüs ağrısı. Taşikardi (HR: 110), D-dimer: 3200 ng/mL.';
                          setState(() {});
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
                          : const Icon(Icons.folder_open_rounded, size: 18),
                      label: Text(_isLoading
                          ? 'İnceleniyor...'
                          : 'Vaka İncele'),
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
                child: _CaseResultView(
                  result: _result!,
                  age: int.tryParse(_ageCtrl.text.trim()),
                  gender: _selectedGender,
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

class _CaseResultView extends StatelessWidget {
  final ClaudeResponse result;
  final int? age;
  final String gender;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _CaseResultView({
    required this.result,
    required this.age,
    required this.gender,
    required this.onCopy,
    required this.onShare,
  });

  static const _accent = KxColors.jade300;

  @override
  Widget build(BuildContext context) {
    final riskScores = _detectRiskScores(result.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.08),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: _accent.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                color: _accent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vaka İnceleme Raporu',
                      style: KxTypography.labelMd
                          .copyWith(color: _accent)),
                  if (age != null)
                    Text('$age yaş / $gender',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: KxSpacing.radiusPill,
              ),
              child: Text('AI Rapor',
                  style: KxTypography.caption.copyWith(
                      color: _accent, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),

        // Risk skorları
        if (riskScores.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KxColors.bgCard,
              border: Border(
                left: BorderSide(color: _accent.withOpacity(0.2)),
                right: BorderSide(color: _accent.withOpacity(0.2)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risk Skorları',
                    style: KxTypography.labelSm
                        .copyWith(color: KxColors.textSecondary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: riskScores
                      .map((s) => _RiskScoreCard(score: s))
                      .toList(),
                ),
              ],
            ),
          ),

        // Ana rapor içeriği
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            border: Border(
              left: BorderSide(color: _accent.withOpacity(0.2)),
              right: BorderSide(color: _accent.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aciliyet Triajı
              _ReviewSection(
                icon: Icons.priority_high_rounded,
                title: 'Aciliyet Triajı',
                color: KxColors.crimson400,
                content: _extractSection(result.text, 'Aciliyet'),
              ),
              const SizedBox(height: 12),

              // Değerlendirme
              _ReviewSection(
                icon: Icons.assignment_rounded,
                title: 'Değerlendirme',
                color: KxColors.blue400,
                content: _extractSection(result.text, 'Değerlendirme'),
              ),
              const SizedBox(height: 12),

              // Öneriler
              _ReviewSection(
                icon: Icons.checklist_rounded,
                title: 'Öneriler',
                color: _accent,
                content: _extractSection(result.text, 'Öneri'),
              ),
            ],
          ),
        ),

        // Tam rapor
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            border: Border(
              left: BorderSide(color: _accent.withOpacity(0.2)),
              right: BorderSide(color: _accent.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detaylı İnceleme Raporu',
                  style: KxTypography.labelSm
                      .copyWith(color: KxColors.textSecondary)),
              const SizedBox(height: 8),
              Text(result.text,
                  style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textSecondary, height: 1.6)),
            ],
          ),
        ),

        // Alt bölüm
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border(
              left: BorderSide(color: _accent.withOpacity(0.2)),
              right: BorderSide(color: _accent.withOpacity(0.2)),
              bottom: BorderSide(color: _accent.withOpacity(0.2)),
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
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withOpacity(0.4)),
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
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withOpacity(0.4)),
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

  List<_RiskScore> _detectRiskScores(String text) {
    final scores = <_RiskScore>[];
    final lower = text.toLowerCase();

    if (lower.contains('heart') && lower.contains('skor')) {
      scores.add(const _RiskScore(
        name: 'HEART',
        description: 'Akut Koroner Sendrom',
        icon: Icons.favorite_rounded,
        color: KxColors.crimson400,
      ));
    }
    if (lower.contains('wells')) {
      scores.add(const _RiskScore(
        name: 'Wells',
        description: 'Pulmoner Emboli',
        icon: Icons.air_rounded,
        color: KxColors.blue400,
      ));
    }
    if (lower.contains('curb') || lower.contains('curb-65')) {
      scores.add(const _RiskScore(
        name: 'CURB-65',
        description: 'Pnömoni Şiddeti',
        icon: Icons.coronavirus_rounded,
        color: KxColors.amber300,
      ));
    }
    if (lower.contains('grace')) {
      scores.add(const _RiskScore(
        name: 'GRACE',
        description: 'AKS Mortalite',
        icon: Icons.monitor_heart_rounded,
        color: KxColors.crimson300,
      ));
    }
    if (lower.contains('cha2ds2') || lower.contains('chads')) {
      scores.add(const _RiskScore(
        name: 'CHA2DS2-VASc',
        description: 'AF İnme Riski',
        icon: Icons.psychology_rounded,
        color: KxColors.teal400,
      ));
    }

    // Varsayılan olarak en az HEART skoru göster
    if (scores.isEmpty) {
      scores.add(const _RiskScore(
        name: 'HEART',
        description: 'Akut Koroner Sendrom',
        icon: Icons.favorite_rounded,
        color: KxColors.crimson400,
      ));
    }

    return scores;
  }

  String _extractSection(String text, String keyword) {
    final patterns = [
      '**$keyword:**',
      '**$keyword**:',
      '**${keyword}ı**',
      '$keyword:',
      '## $keyword',
      '**${keyword}leri:**',
      '**${keyword}ler:**',
    ];
    for (final p in patterns) {
      final idx = text.toLowerCase().indexOf(p.toLowerCase());
      if (idx >= 0) {
        final start = idx + p.length;
        final nextSection =
            RegExp(r'\n\s*(?:\*\*|##)').firstMatch(text.substring(start));
        final end = nextSection != null
            ? start + nextSection.start
            : (start + 300).clamp(0, text.length);
        return text.substring(start, end).trim();
      }
    }
    return '';
  }
}

class _RiskScore {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  const _RiskScore({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _RiskScoreCard extends StatelessWidget {
  final _RiskScore score;
  const _RiskScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: score.color.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: score.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(score.icon, color: score.color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(score.name,
                  style: KxTypography.labelSm.copyWith(
                      color: score.color, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(score.description,
              style: KxTypography.caption
                  .copyWith(color: KxColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String content;

  const _ReviewSection({
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
                style: KxTypography.labelSm.copyWith(color: color)),
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
