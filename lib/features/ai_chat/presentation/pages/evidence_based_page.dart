import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../../../core/services/claude_ai_service.dart';

/// KONSENXIA — Kanıta Dayalı Tıp Analiz Sayfası
///
/// Klinik soru + uzmanlık alanı girişi → AI ile güncel kılavuz özetleri,
/// meta-analiz referansları ve öneri dereceleri (A/B/C/D) üretir.
class EvidenceBasedPage extends StatefulWidget {
  const EvidenceBasedPage({super.key});

  @override
  State<EvidenceBasedPage> createState() => _EvidenceBasedPageState();
}

class _EvidenceBasedPageState extends State<EvidenceBasedPage> {
  final _questionCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _selectedSpecialty = 'Genel';
  bool _isLoading = false;
  ClaudeResponse? _result;
  String? _errorText;

  static const _specialties = [
    'Genel',
    'Kardiyoloji',
    'Endokrinoloji',
    'Nöroloji',
    'Onkoloji',
    'Pulmoner',
    'Gastroenteroloji',
    'Nefroloji',
    'Romatoloji',
    'Enfeksiyon',
    'Pediatri',
    'Psikiyatri',
  ];

  static const _accent = KxColors.blue400;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final question = _questionCtrl.text.trim();
    if (question.isEmpty) {
      setState(() => _errorText = 'Lütfen klinik sorunuzu girin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _result = null;
    });

    try {
      final service = GetIt.instance<ClaudeAIService>();
      final response = await service.analyzeEvidence(question, _selectedSpecialty);
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
                const Icon(Icons.science_rounded, color: _accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kanıta Dayalı Tıp',
                          style: KxTypography.headingSm),
                      Text('Kılavuz & Meta-Analiz Sorgulama',
                          style: KxTypography.caption.copyWith(color: _accent)),
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
                      style: KxTypography.caption.copyWith(color: _accent)),
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
                  // Uzmanlık seçici
                  Text('Uzmanlık Alanı',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialties.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final s = _specialties[i];
                        final sel = s == _selectedSpecialty;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSpecialty = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _accent.withOpacity(0.15)
                                  : KxColors.bgCard,
                              borderRadius: KxSpacing.radiusPill,
                              border: Border.all(
                                  color: sel
                                      ? _accent.withOpacity(0.5)
                                      : KxColors.border),
                            ),
                            child: Text(
                              s,
                              style: KxTypography.labelSm.copyWith(
                                  color: sel ? _accent : KxColors.textMuted),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Soru girişi
                  Text('Klinik Soru',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionCtrl,
                    maxLines: 4,
                    minLines: 3,
                    style: KxTypography.bodyMd
                        .copyWith(color: KxColors.textPrimary),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      hintText:
                          'Ör: Tip 2 DM yönetiminde SGLT2i vs GLP-1a ilk seçenek mi?',
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
                        borderSide: BorderSide(color: _accent, width: 1.5),
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

                  // Öneri çipleri
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SuggestionChip(
                        label: 'AF antikoagülasyon kriterleri',
                        onTap: () => _questionCtrl.text =
                            'AF\'de antikoagülasyon başlama kriteri nedir?',
                      ),
                      _SuggestionChip(
                        label: 'Statin LDL hedefi',
                        onTap: () => _questionCtrl.text =
                            'Statin tedavisinde LDL hedefi ne olmalı?',
                      ),
                      _SuggestionChip(
                        label: 'HT tedavi basamağı',
                        onTap: () => _questionCtrl.text =
                            'Hipertansiyon tedavisinde ilk basamak ilaç seçimi nedir?',
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
                          : const Icon(Icons.science_rounded, size: 18),
                      label: Text(
                          _isLoading ? 'Analiz ediliyor...' : 'Analiz Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
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
                child: _EvidenceResultView(
                  result: _result!,
                  specialty: _selectedSpecialty,
                  onCopy: () => _copyResult(),
                  onShare: () => _shareResult(),
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

  void _shareResult() {
    // Paylaşım — şu an kopyala ile aynı
    _copyResult();
  }
}

// ── Sonuç Görünümü ───────────────────────────────────────────────────────────

class _EvidenceResultView extends StatelessWidget {
  final ClaudeResponse result;
  final String specialty;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _EvidenceResultView({
    required this.result,
    required this.specialty,
    required this.onCopy,
    required this.onShare,
  });

  static const _accent = KxColors.blue400;

  @override
  Widget build(BuildContext context) {
    // Kılavuz referanslarını ayrıştır
    final guidelines = _parseGuidelines(result.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Text('Kanıta Dayalı Analiz Sonuçları',
                style:
                    KxTypography.labelMd.copyWith(color: _accent)),
            const Spacer(),
            KxBadge.blue(specialty),
          ]),
        ),

        // Ana içerik
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kılavuz kartları
              if (guidelines.isNotEmpty) ...[
                ...guidelines.map((g) => _GuidelineCard(guideline: g)),
                const SizedBox(height: 12),
              ],

              // Tam yanıt
              Text(result.text,
                  style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textSecondary, height: 1.6)),

              const SizedBox(height: 16),

              // Kaynak bilgisi
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
                      'Kaynak: ${result.source} — Bu bilgi klinik karar desteği amaçlıdır.',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textMuted, fontSize: 10),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 12),

              // Eylem butonları
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
            ],
          ),
        ),
      ],
    );
  }

  List<_GuidelineInfo> _parseGuidelines(String text) {
    final guidelines = <_GuidelineInfo>[];
    // Basit ayrıştırma: kılavuz referanslarını bul
    final regExp = RegExp(
        r'(?:ADA|ESC|ACC|AHA|WHO|NICE|KDIGO|GOLD|GINA|JNC|EULAR|ACR|IDSA)\s*[\d/]*\s*(?:\d{4})?');
    final matches = regExp.allMatches(text);
    final seen = <String>{};
    for (final m in matches) {
      final name = m.group(0)?.trim() ?? '';
      if (name.isNotEmpty && seen.add(name)) {
        // Öneri derecesini tahmin et
        final grade = _guessGrade(text, name);
        guidelines.add(_GuidelineInfo(name: name, grade: grade));
      }
    }
    return guidelines.take(4).toList();
  }

  String _guessGrade(String text, String guideline) {
    final idx = text.indexOf(guideline);
    if (idx < 0) return 'B';
    final nearby = text.substring(
        idx, (idx + 200).clamp(0, text.length));
    if (nearby.contains('Sınıf I') ||
        nearby.contains('güçlü öneri') ||
        nearby.contains('Grade A')) return 'A';
    if (nearby.contains('Sınıf IIa') || nearby.contains('Grade B')) return 'B';
    if (nearby.contains('Sınıf IIb') || nearby.contains('Grade C')) return 'C';
    if (nearby.contains('Sınıf III') || nearby.contains('Grade D')) return 'D';
    return 'B';
  }
}

class _GuidelineInfo {
  final String name;
  final String grade;
  const _GuidelineInfo({required this.name, required this.grade});
}

class _GuidelineCard extends StatelessWidget {
  final _GuidelineInfo guideline;
  const _GuidelineCard({required this.guideline});

  Color _gradeColor(String grade) {
    return switch (grade) {
      'A' => KxColors.jade300,
      'B' => KxColors.blue400,
      'C' => KxColors.amber300,
      'D' => KxColors.crimson400,
      _ => KxColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(guideline.grade);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(guideline.name,
                style: KxTypography.labelSm
                    .copyWith(color: KxColors.textPrimary)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: KxSpacing.radiusPill,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              'Derece ${guideline.grade}',
              style: KxTypography.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
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
