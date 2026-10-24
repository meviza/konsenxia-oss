import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/claude_ai_service.dart';
import '../../../../core/services/voice_input_service.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/usecases/create_case_usecase.dart';

/// KONSENXIA — Yeni Vaka Oluştur Sayfası
///
/// 4 adımlı form:
///   1. Temel Bilgiler (başlık, özet, aciliyet)
///   2. Klinik Tablo & Vitaller
///   3. Etiketler & Uzmanlık Alanları
///   4. Önizleme & Gönder

class CreateCasePage extends StatefulWidget {
  const CreateCasePage({super.key});

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage>
    with TickerProviderStateMixin {
  int _step = 0;
  final _pageCtrl = PageController();
  late final AnimationController _progressCtrl;

  // ── Step 1 ─────────────────────────────────────────────────────
  final _titleCtrl    = TextEditingController();
  final _summaryCtrl  = TextEditingController();
  CaseUrgency _urgency = CaseUrgency.urgent;

  // ── Step 2 ─────────────────────────────────────────────────────
  final _clinicalCtrl  = TextEditingController();
  final _patientCtrl   = TextEditingController();
  final List<_VitalEntry> _vitals = [];

  // ── Step 3 ─────────────────────────────────────────────────────
  final Set<String> _selectedSpecialties = {};
  final Set<String> _selectedTags        = {};
  final _tagInputCtrl = TextEditingController();

  // ── Voice Input ──────────────────────────────────────────────────
  final VoiceInputService _voiceService = VoiceInputService();
  final ClaudeAIService _aiService = ClaudeAIService();

  // ── File Attachments ───────────────────────────────────────────
  final List<File> _attachedFiles = [];
  static const int _maxFiles = 10;
  static const int _maxFileSizeBytes = 20 * 1024 * 1024; // 20MB
  static const List<String> _allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'dcm',
  ];

  // ── Submit state ────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Helpers ────────────────────────────────────────────────────
  static const int _totalSteps = 4;

  bool get _canProceedStep0 =>
      _titleCtrl.text.trim().length >= 10 &&
      _summaryCtrl.text.trim().length >= 20;

  bool get _canProceedStep1 =>
      _clinicalCtrl.text.trim().length >= 30 &&
      _patientCtrl.text.trim().isNotEmpty;

  bool get _canProceedStep2 => _selectedSpecialties.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1 / _totalSteps,
    );

    // Rebuild on text change for validation
    _titleCtrl.addListener(() => setState(() {}));
    _summaryCtrl.addListener(() => setState(() {}));
    _clinicalCtrl.addListener(() => setState(() {}));
    _patientCtrl.addListener(() => setState(() {}));

    // Initialize voice service in background
    _voiceService.initialize();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _progressCtrl.dispose();
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    _clinicalCtrl.dispose();
    _patientCtrl.dispose();
    _tagInputCtrl.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressCtrl.animateTo((_step + 1) / _totalSteps);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressCtrl.animateTo((_step + 1) / _totalSteps);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final createCase = GetIt.instance<CreateCaseUseCase>();

      // Convert _VitalEntry list to VitalSign list for the use case
      final vitals = _vitals
          .map((v) => VitalSign(
                label: v.label,
                value: v.value,
                unit: v.unit,
                range: v.range,
              ))
          .toList();

      await createCase(CreateCaseParams(
        title: _titleCtrl.text.trim(),
        description: _summaryCtrl.text.trim(),
        clinicalPresentation: _clinicalCtrl.text.trim(),
        patientSummary: _patientCtrl.text.trim(),
        urgency: _urgency,
        specialties: _selectedSpecialties.toList(),
        tags: _selectedTags.toList(),
        vitals: vitals,
      ));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.teal400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: KxColors.bgVoid, size: 18),
              const SizedBox(width: 10),
              Text(
                'Vakaniz basariyla yayinlandi!',
                style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
              ),
            ],
          ),
        ),
      );
      context.go('/cases');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: KxColors.crimson400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: KxColors.bgVoid, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vaka olusturulamadi: $errorMsg',
                  style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  // ── Wide layout: sidebar + centered form ──────────────────────

  Widget _buildWide() {
    return _buildFormArea();
  }

  Widget _buildNarrow() => _buildFormArea();

  // ── Main form area ─────────────────────────────────────────────

  Widget _buildFormArea() {
    return Column(
      children: [
        _buildTopBar(),
        _buildProgressRow(),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep0(),
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  // ── Top bar ────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(bottom: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded,
                    size: 18, color: KxColors.textMuted),
                const SizedBox(width: 6),
                Text('Geri',
                    style: KxTypography.labelSm
                        .copyWith(color: KxColors.textMuted)),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Yeni Vaka Paylas',
            style: KxTypography.headingSm.copyWith(color: KxColors.textPrimary),
          ),
          const Spacer(),
          // Step indicator
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.12),
              borderRadius: KxSpacing.radiusPill,
              border:
                  Border.all(color: KxColors.teal400.withOpacity(0.3)),
            ),
            child: Text(
              '${_step + 1} / $_totalSteps',
              style:
                  KxTypography.caption.copyWith(color: KxColors.teal400),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress bar ───────────────────────────────────────────────

  Widget _buildProgressRow() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: List.generate(_totalSteps, (i) {
              final done    = i < _step;
              final current = i == _step;
              return Expanded(
                child: Row(
                  children: [
                    // Step dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: current ? 28 : 22,
                      height: current ? 28 : 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? KxColors.teal400
                            : current
                                ? KxColors.teal400
                                : KxColors.bgCard,
                        border: Border.all(
                          color: done || current
                              ? KxColors.teal400
                              : KxColors.border,
                          width: current ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 12, color: KxColors.bgVoid)
                            : Text(
                                '${i + 1}',
                                style: KxTypography.caption.copyWith(
                                  color: current
                                      ? KxColors.bgVoid
                                      : KxColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    // Connector (not last)
                    if (i < _totalSteps - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          color: i < _step
                              ? KxColors.teal400
                              : KxColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _stepTitle(_step),
          style: KxTypography.caption.copyWith(color: KxColors.textMuted),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _stepTitle(int step) => switch (step) {
        0 => 'Temel Bilgiler',
        1 => 'Klinik Tablo & Vitaller',
        2 => 'Uzmanlik & Etiketler',
        3 => 'Onizleme & Gonder',
        _ => '',
      };

  // ── Bottom nav bar ─────────────────────────────────────────────

  Widget _buildBottomBar() {
    final bool canContinue = switch (_step) {
      0 => _canProceedStep0,
      1 => _canProceedStep1,
      2 => _canProceedStep2,
      _ => true,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(top: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            KxButton.secondary(
              label: '\u2190 Onceki',
              onPressed: _goBack,
            ),
          const Spacer(),
          if (_step < _totalSteps - 1)
            KxButton.primary(
              label: 'Devam \u2192',
              onPressed: canContinue ? _goNext : null,
            )
          else
            _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: KxColors.teal400,
                    ),
                  )
                : KxButton.primary(
                    label: 'Vakayi Gonder',
                    onPressed: _submit,
                    icon: Icons.send_rounded,
                  ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 0 — Temel Bilgiler
  // ══════════════════════════════════════════════════════════════

  Widget _buildStep0() {
    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.description_outlined,
            title: 'Vaka Basligi',
            subtitle: 'Vakayi tanimlayan kisa ve net bir baslik girin.',
          ),
          const SizedBox(height: 12),
          KxTextField(
            controller: _titleCtrl,
            hint: 'orn. 65 yasinda erkek hasta, ani gogus agrisi ve dispne',
            maxLength: 120,
          ),
          const SizedBox(height: 24),

          _SectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'Hasta Ozeti',
            subtitle: 'Anonim hasta bilgisi: yas, cinsiyet, semptomlar.',
          ),
          const SizedBox(height: 12),
          _VoiceEnabledTextField(
            controller: _summaryCtrl,
            hint: 'orn. 65 Y/E, 3 saatlik gogus agrisi ve nefes darligi ile basvuru.',
            maxLines: 3,
            maxLength: 280,
            voiceService: _voiceService,
            aiService: _aiService,
            fieldLabel: 'Hasta Ozeti',
          ),
          const SizedBox(height: 24),

          _SectionHeader(
            icon: Icons.warning_amber_rounded,
            title: 'Aciliyet Duzeyi',
            subtitle: 'Vakanin klinik aciliyetini tanimlayin.',
          ),
          const SizedBox(height: 12),
          _UrgencySelector(
            selected: _urgency,
            onChanged: (v) => setState(() => _urgency = v),
          ),

          const SizedBox(height: 32),
          if (!_canProceedStep0)
            _ValidationHint(
              'Baslik en az 10, hasta ozeti en az 20 karakter olmalidir.',
            ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04, end: 0);
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 1 — Klinik Tablo & Vitaller
  // ══════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.medical_information_outlined,
            title: 'Klinik Tablo',
            subtitle:
                'Hastanin klinik durumunu, basvuru sikayetlerini ve muayene bulgularini detayli aciklayin.',
          ),
          const SizedBox(height: 12),
          _VoiceEnabledTextField(
            controller: _clinicalCtrl,
            hint:
                'Hasta acil servise 3 saatlik gogus agrisi ile basvurdu. Agri sol kola yayiliyor, soguk terleme eslik ediyor. Fizik muayenede...',
            maxLines: 6,
            maxLength: 2000,
            voiceService: _voiceService,
            aiService: _aiService,
            fieldLabel: 'Klinik Tablo',
          ),
          const SizedBox(height: 24),

          _SectionHeader(
            icon: Icons.person_search_outlined,
            title: 'Anonim Hasta Profili',
            subtitle: 'Hastanin kimligini gizleyerek kisa profil yazin.',
          ),
          const SizedBox(height: 12),
          KxTextField(
            controller: _patientCtrl,
            hint: '65 Y/E, bilinen KAH (+), HT (+), DM (-)',
            maxLines: 2,
            maxLength: 200,
          ),
          const SizedBox(height: 24),

          _SectionHeader(
            icon: Icons.monitor_heart_outlined,
            title: 'Vital Bulgular',
            subtitle: 'Kaydedilmis vital degerleri ekleyin.',
            trailing: GestureDetector(
              onTap: _addVital,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.12),
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(color: KxColors.teal400.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: KxColors.teal400),
                    const SizedBox(width: 4),
                    Text('Ekle',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.teal400)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_vitals.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KxColors.bgCard,
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(
                    color: KxColors.border, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: KxColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Vital bulgu eklenmedi. Opsiyonel.',
                    style:
                        KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vitals
                  .map((v) => _VitalChipEditable(
                        vital: v,
                        onDelete: () => setState(() => _vitals.remove(v)),
                      ))
                  .toList(),
            ),

          const SizedBox(height: 28),

          // ── Dosya Ekleme Bolumu ──────────────────────────────────
          _SectionHeader(
            icon: Icons.attach_file_rounded,
            title: 'Dosyalar & Tahliller',
            subtitle:
                'Kan tahlili, tomografi, MR, rontgen vb. ekleyin',
          ),
          const SizedBox(height: 12),
          _FileAttachmentSection(
            attachedFiles: _attachedFiles,
            onFilesChanged: () => setState(() {}),
            maxFiles: _maxFiles,
            maxFileSizeBytes: _maxFileSizeBytes,
            allowedExtensions: _allowedExtensions,
          ),

          const SizedBox(height: 32),
          if (!_canProceedStep1)
            _ValidationHint(
              'Klinik tablo en az 30 karakter, hasta profili doldurulmalidir.',
            ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04, end: 0);
  }

  void _addVital() {
    // Preset vitals for quick add
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: KxColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _VitalPickerSheet(
        onPick: (entry) {
          setState(() => _vitals.add(entry));
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 2 — Uzmanlik & Etiketler
  // ══════════════════════════════════════════════════════════════

  static const List<String> _allSpecialties = [
    'Kardiyoloji', 'Noroloji', 'Dahiliye', 'Acil Tip', 'Gogus Hastaliklari',
    'Gastroenteroloji', 'Endokrinoloji', 'Nefroloji', 'Romatoloji',
    'Hematoloji', 'Onkoloji', 'Enfeksiyon Hastaliklari', 'Psikiyatri',
    'Ortopedi', 'Genel Cerrahi', 'Kadin Dogum', 'Pediatri', 'Radyoloji',
  ];

  static const List<String> _quickTags = [
    'EKG', 'BT', 'MRI', 'Troponin', 'D-Dimer', 'Sepsis', 'Pnomoni',
    'MI', 'PE', 'Inme', 'DKA', 'Akut karin', 'Bobrek yetmezligi',
    'Kalp yetmezligi', 'Aritmia',
  ];

  Widget _buildStep2() {
    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.local_hospital_outlined,
            title: 'Uzmanlik Alanlari',
            subtitle:
                'Bu vakayla ilgili uzmanlik alanlarini secin (en az 1).',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSpecialties.map((s) {
              final selected = _selectedSpecialties.contains(s);
              return GestureDetector(
                onTap: () => setState(() {
                  selected
                      ? _selectedSpecialties.remove(s)
                      : _selectedSpecialties.add(s);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? KxColors.teal400.withOpacity(0.15)
                        : KxColors.bgCard,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                      color: selected ? KxColors.teal400 : KxColors.border,
                    ),
                  ),
                  child: Text(
                    s,
                    style: KxTypography.labelSm.copyWith(
                      color: selected
                          ? KxColors.teal400
                          : KxColors.textSecondary,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          _SectionHeader(
            icon: Icons.label_outline_rounded,
            title: 'Etiketler',
            subtitle: 'Hizli etiket secin veya ozel etiket ekleyin.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTags.map((t) {
              final selected = _selectedTags.contains(t);
              return GestureDetector(
                onTap: () => setState(() {
                  selected
                      ? _selectedTags.remove(t)
                      : _selectedTags.add(t);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected
                        ? KxColors.teal400.withOpacity(0.1)
                        : KxColors.bgCard,
                    borderRadius: KxSpacing.radiusPill,
                    border: Border.all(
                      color: selected
                          ? KxColors.teal400.withOpacity(0.6)
                          : KxColors.border,
                    ),
                  ),
                  child: Text(
                    '# $t',
                    style: KxTypography.caption.copyWith(
                      color: selected
                          ? KxColors.teal400
                          : KxColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom tag input
          Row(
            children: [
              Expanded(
                child: KxTextField(
                  controller: _tagInputCtrl,
                  hint: 'Ozel etiket...',
                  prefixIcon: Icons.add_rounded,
                ),
              ),
              const SizedBox(width: 10),
              KxButton.secondary(
                label: 'Ekle',
                onPressed: () {
                  final tag = _tagInputCtrl.text.trim();
                  if (tag.isNotEmpty) {
                    setState(() {
                      _selectedTags.add(tag);
                      _tagInputCtrl.clear();
                    });
                  }
                },
              ),
            ],
          ),

          if (_selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Secili etiketler:',
                style: KxTypography.caption.copyWith(
                    color: KxColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedTags
                  .map((t) => KxTag.removable(
                        t,
                        onRemove: () =>
                            setState(() => _selectedTags.remove(t)),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),
          if (!_canProceedStep2)
            _ValidationHint('En az bir uzmanlik alani seciniz.'),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04, end: 0);
  }

  // ══════════════════════════════════════════════════════════════
  // STEP 3 — Onizleme & Gonder
  // ══════════════════════════════════════════════════════════════

  Widget _buildStep3() {
    return _StepScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KxColors.bgSurface,
              borderRadius: KxSpacing.radiusLg,
              border: Border.all(color: KxColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Urgency + title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UrgencyBadge(_urgency),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _titleCtrl.text.isEmpty
                            ? '(baslik girilmedi)'
                            : _titleCtrl.text,
                        style: KxTypography.headingSm
                            .copyWith(color: KxColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: KxColors.border),
                const SizedBox(height: 12),

                _PreviewRow(
                  label: 'Hasta Ozeti',
                  value: _summaryCtrl.text.isEmpty
                      ? '\u2014'
                      : _summaryCtrl.text,
                ),
                const SizedBox(height: 10),
                _PreviewRow(
                  label: 'Klinik Tablo',
                  value: _clinicalCtrl.text.isEmpty
                      ? '\u2014'
                      : _clinicalCtrl.text.length > 200
                          ? '${_clinicalCtrl.text.substring(0, 200)}...'
                          : _clinicalCtrl.text,
                ),

                if (_vitals.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Vitaller',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textMuted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _vitals
                        .map((v) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: KxColors.bgCard,
                                borderRadius: KxSpacing.radiusSm,
                                border: Border.all(color: KxColors.border),
                              ),
                              child: Text(
                                '${v.label}: ${v.value}${v.unit != null ? ' ${v.unit}' : ''}',
                                style: KxTypography.caption.copyWith(
                                    color: KxColors.textSecondary),
                              ),
                            ))
                        .toList(),
                  ),
                ],

                if (_attachedFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Ekli Dosyalar (${_attachedFiles.length})',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textMuted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _attachedFiles
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: KxColors.bgCard,
                                borderRadius: KxSpacing.radiusSm,
                                border: Border.all(color: KxColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _FileAttachmentSection.iconForFile(f.path),
                                    size: 12,
                                    color: KxColors.teal400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    f.path.split('/').last,
                                    style: KxTypography.caption.copyWith(
                                        color: KxColors.textSecondary),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 12),
                Divider(color: KxColors.border),
                const SizedBox(height: 12),

                if (_selectedSpecialties.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedSpecialties
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: KxColors.teal400.withOpacity(0.1),
                                borderRadius: KxSpacing.radiusMd,
                                border: Border.all(
                                    color: KxColors.teal400.withOpacity(0.4)),
                              ),
                              child: Text(s,
                                  style: KxTypography.caption
                                      .copyWith(color: KxColors.teal400)),
                            ))
                        .toList(),
                  ),

                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedTags
                        .map((t) => Text('# $t',
                            style: KxTypography.caption
                                .copyWith(color: KxColors.textMuted)))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // XP info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              borderRadius: KxSpacing.radiusLg,
              border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: Color(0xFFF59E0B), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vakaniz yayinlandiginda',
                          style: KxTypography.labelSm
                              .copyWith(color: Color(0xFFF59E0B))),
                      const SizedBox(height: 2),
                      Text(
                        '+50 XP kazanacaksiniz. Yorum ve kabul edilen cevaplardan ek XP.',
                        style: KxTypography.bodyMd
                            .copyWith(color: KxColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Terms
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KxColors.bgCard,
              borderRadius: KxSpacing.radiusMd,
              border: Border.all(color: KxColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined,
                    size: 16, color: KxColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu vakayi paylasarak hasta mahremiyetine uygun, kimlik bilgisi icermeyen anonim bilgiler sundugunuzu onayliyorsunuz. KONSENXIA vaka paylasim standartlari gecerlidir.',
                    style: KxTypography.caption
                        .copyWith(color: KxColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04, end: 0);
  }
}

// ══════════════════════════════════════════════════════════════════
// VOICE-ENABLED TEXT FIELD
// ══════════════════════════════════════════════════════════════════

/// Sesli giris destekli metin alani.
/// Mikrofon butonu ile STT baslatir, sonucu direkt veya AI ile
/// akademik formata donusturerek alana ekler.
class _VoiceEnabledTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final VoiceInputService voiceService;
  final ClaudeAIService aiService;
  final String fieldLabel;

  const _VoiceEnabledTextField({
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    required this.voiceService,
    required this.aiService,
    required this.fieldLabel,
  });

  @override
  State<_VoiceEnabledTextField> createState() =>
      _VoiceEnabledTextFieldState();
}

class _VoiceEnabledTextFieldState extends State<_VoiceEnabledTextField>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessingAI = false;
  String _recognizedText = '';
  late AnimationController _pulseCtrl;
  StreamSubscription<String>? _textSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<bool>? _listeningSub;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _textSub?.cancel();
    _errorSub?.cancel();
    _listeningSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // Önce mikrofon iznini kontrol et ve iste
    final permStatus = await widget.voiceService.requestMicrophonePermission();
    if (permStatus.isDenied) {
      if (mounted) {
        _showError('Mikrofon izni reddedildi. Sesli giris icin izin gereklidir.');
      }
      return;
    }
    if (permStatus.isPermanentlyDenied) {
      if (mounted) {
        _showError('Mikrofon izni reddedildi. Ayarlar\'dan etkinlestirebilirsiniz.');
        openAppSettings();
      }
      return;
    }

    final available = await widget.voiceService.initialize();
    if (!available) {
      if (mounted) {
        _showError('Ses tanima kullanilamilyor. Mikrofon izni gerekli.');
      }
      return;
    }

    // Subscribe to streams
    _textSub?.cancel();
    _errorSub?.cancel();
    _listeningSub?.cancel();

    _textSub = widget.voiceService.textStream.listen((text) {
      if (mounted) {
        setState(() => _recognizedText = text);
      }
    });

    _errorSub = widget.voiceService.errorStream.listen((error) {
      if (mounted) _showError(error);
    });

    _listeningSub = widget.voiceService.listeningStream.listen((listening) {
      if (mounted && !listening && _isRecording) {
        // Dinleme otomatik durdu (timeout vb.)
        _onRecordingStopped();
      }
    });

    _recognizedText = '';
    await widget.voiceService.startListening(locale: 'tr_TR');

    if (mounted) {
      setState(() => _isRecording = true);
      _pulseCtrl.repeat(reverse: true);
    }
  }

  Future<void> _stopRecording() async {
    await widget.voiceService.stopListening();
    _onRecordingStopped();
  }

  void _onRecordingStopped() {
    if (!mounted) return;

    _pulseCtrl.stop();
    _pulseCtrl.reset();

    final text = _recognizedText.isNotEmpty
        ? _recognizedText
        : widget.voiceService.lastRecognizedText;

    setState(() => _isRecording = false);

    _textSub?.cancel();
    _errorSub?.cancel();
    _listeningSub?.cancel();

    if (text.isNotEmpty) {
      _showVoiceResultSheet(text);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: KxColors.crimson400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        content: Row(
          children: [
            const Icon(Icons.mic_off_rounded,
                color: KxColors.bgVoid, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceResultSheet(String rawText) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _VoiceResultSheet(
        rawText: rawText,
        aiService: widget.aiService,
        fieldLabel: widget.fieldLabel,
        onInsertRaw: () {
          _insertText(rawText);
          Navigator.of(ctx).pop();
        },
        onInsertAcademic: (academicText) {
          _insertText(academicText);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _insertText(String text) {
    final current = widget.controller.text;
    if (current.isNotEmpty && !current.endsWith(' ') && !current.endsWith('\n')) {
      widget.controller.text = '$current $text';
    } else {
      widget.controller.text = '$current$text';
    }
    // Move cursor to end
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KxTextField(
                controller: widget.controller,
                hint: widget.hint,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _VoiceInputButton(
                isRecording: _isRecording,
                isProcessing: _isProcessingAI,
                pulseController: _pulseCtrl,
                onTap: _toggleRecording,
              ),
            ),
          ],
        ),
        // Canli tanima gostergesi
        if (_isRecording && _recognizedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KxColors.crimson400.withOpacity(0.08),
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(color: KxColors.crimson400.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.hearing_rounded,
                      size: 14, color: KxColors.crimson400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recognizedText,
                      style: KxTypography.bodyMd.copyWith(
                        color: KxColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// VOICE INPUT BUTTON (Reusable)
// ══════════════════════════════════════════════════════════════════

/// Mikrofon butonu:
/// - Varsayilan: teal mikrofon ikonu
/// - Kayit sirasinda: kirmizi pulsing daire
/// - AI isleme sirasinda: loading spinner
class _VoiceInputButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _VoiceInputButton({
    required this.isRecording,
    required this.isProcessing,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: KxColors.teal400.withOpacity(0.12),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: KxColors.teal400,
            ),
          ),
        ),
      );
    }

    if (isRecording) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            final scale = 1.0 + (pulseController.value * 0.15);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KxColors.crimson400,
                  borderRadius: KxSpacing.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: KxColors.crimson400.withOpacity(
                          0.3 + (pulseController.value * 0.2)),
                      blurRadius: 8 + (pulseController.value * 4),
                      spreadRadius: pulseController.value * 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.stop_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Default state — mic button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: KxColors.teal400.withOpacity(0.12),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.teal400.withOpacity(0.4)),
        ),
        child: const Center(
          child: Icon(
            Icons.mic_rounded,
            size: 22,
            color: KxColors.teal400,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// VOICE RESULT BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════

/// Ses tanima sonucu alt sayfasi.
/// Ham metin gosterir, iki secenek sunar:
///   1. Direkt metin olarak ekle
///   2. AI ile akademik duzenleme
class _VoiceResultSheet extends StatefulWidget {
  final String rawText;
  final ClaudeAIService aiService;
  final String fieldLabel;
  final VoidCallback onInsertRaw;
  final ValueChanged<String> onInsertAcademic;

  const _VoiceResultSheet({
    required this.rawText,
    required this.aiService,
    required this.fieldLabel,
    required this.onInsertRaw,
    required this.onInsertAcademic,
  });

  @override
  State<_VoiceResultSheet> createState() => _VoiceResultSheetState();
}

class _VoiceResultSheetState extends State<_VoiceResultSheet> {
  bool _isRewriting = false;
  String? _academicText;
  String? _rewriteError;

  Future<void> _rewriteAcademic() async {
    setState(() {
      _isRewriting = true;
      _rewriteError = null;
    });

    try {
      final result = await widget.aiService.rewriteAsAcademic(widget.rawText);
      if (mounted) {
        setState(() {
          _academicText = result;
          _isRewriting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rewriteError =
              'AI baglantisi gerekli. Metin olarak eklemeyi deneyin.';
          _isRewriting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: KxColors.teal400.withOpacity(0.3)),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KxColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: KxColors.teal400.withOpacity(0.1),
                      borderRadius: KxSpacing.radiusSm,
                    ),
                    child: const Icon(Icons.mic_rounded,
                        size: 16, color: KxColors.teal400),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ses Tanima Sonucu',
                            style: KxTypography.headingSm
                                .copyWith(color: KxColors.textPrimary)),
                        Text(widget.fieldLabel,
                            style: KxTypography.caption
                                .copyWith(color: KxColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close_rounded,
                        size: 20, color: KxColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Raw text display
              Container(
                width: double.infinity,
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
                        Icon(Icons.format_quote_rounded,
                            size: 14, color: KxColors.textMuted),
                        const SizedBox(width: 6),
                        Text('Algilanan Metin',
                            style: KxTypography.caption
                                .copyWith(color: KxColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.rawText,
                      style: KxTypography.bodyMd
                          .copyWith(color: KxColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Academic preview (if available)
              if (_academicText != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KxColors.teal400.withOpacity(0.06),
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                        color: KxColors.teal400.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 14, color: KxColors.teal400),
                          const SizedBox(width: 6),
                          Text('Akademik Duzenleme',
                              style: KxTypography.caption
                                  .copyWith(color: KxColors.teal400)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _academicText!,
                        style: KxTypography.bodyMd
                            .copyWith(color: KxColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: KxButton.primary(
                    label: 'Akademik Metni Ekle',
                    icon: Icons.check_rounded,
                    onPressed: () =>
                        widget.onInsertAcademic(_academicText!),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: KxButton.secondary(
                    label: 'Ham Metni Ekle',
                    onPressed: widget.onInsertRaw,
                  ),
                ),
              ] else if (_rewriteError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: KxColors.crimson400.withOpacity(0.08),
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                        color: KxColors.crimson400.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16, color: KxColors.crimson400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _rewriteError!,
                          style: KxTypography.bodyMd
                              .copyWith(color: KxColors.crimson400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: KxButton.primary(
                    label: 'Direkt Metin Olarak Ekle',
                    icon: Icons.text_fields_rounded,
                    onPressed: widget.onInsertRaw,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: KxButton.secondary(
                    label: 'Tekrar Dene',
                    onPressed: _rewriteAcademic,
                  ),
                ),
              ] else ...[
                // Two action buttons
                SizedBox(
                  width: double.infinity,
                  child: KxButton.primary(
                    label: 'Direkt Metin Olarak Ekle',
                    icon: Icons.text_fields_rounded,
                    onPressed: widget.onInsertRaw,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: _isRewriting
                      ? Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: KxColors.teal400.withOpacity(0.08),
                            borderRadius: KxSpacing.radiusMd,
                            border: Border.all(
                                color: KxColors.teal400.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: KxColors.teal400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'AI ile duzenleniyor...',
                                style: KxTypography.labelSm
                                    .copyWith(color: KxColors.teal400),
                              ),
                            ],
                          ),
                        )
                      : _AcademicRewriteButton(
                          onTap: _rewriteAcademic,
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// AI ile Akademik Duzenleme butonu — ozel stil
class _AcademicRewriteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AcademicRewriteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              KxColors.teal400.withOpacity(0.15),
              KxColors.teal400.withOpacity(0.08),
            ],
          ),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.teal400.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 18, color: KxColors.teal400),
            const SizedBox(width: 8),
            Text(
              'AI ile Akademik Duzenleme',
              style: KxTypography.labelSm.copyWith(color: KxColors.teal400),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// HELPERS (original)
// ══════════════════════════════════════════════════════════════════

class _StepScroll extends StatelessWidget {
  final Widget child;
  const _StepScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: KxColors.teal400.withOpacity(0.1),
            borderRadius: KxSpacing.radiusSm,
          ),
          child: Icon(icon, size: 16, color: KxColors.teal400),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: KxTypography.labelMd
                      .copyWith(color: KxColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textMuted)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ValidationHint extends StatelessWidget {
  final String message;
  const _ValidationHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KxColors.crimson400.withOpacity(0.08),
        borderRadius: KxSpacing.radiusMd,
        border:
            Border.all(color: KxColors.crimson400.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 14, color: KxColors.crimson400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: KxTypography.caption
                    .copyWith(color: KxColors.crimson400)),
          ),
        ],
      ),
    );
  }
}

// ── Urgency selector ───────────────────────────────────────────

class _UrgencySelector extends StatelessWidget {
  final CaseUrgency selected;
  final ValueChanged<CaseUrgency> onChanged;
  const _UrgencySelector(
      {required this.selected, required this.onChanged});

  static const _items = CaseUrgency.values;

  Color _color(CaseUrgency u) => switch (u) {
        CaseUrgency.routine   => const Color(0xFF6B7280),
        CaseUrgency.urgent    => const Color(0xFFF59E0B),
        CaseUrgency.critical  => const Color(0xFFEF4444),
        CaseUrgency.emergency => const Color(0xFFDC2626),
      };

  IconData _icon(CaseUrgency u) => switch (u) {
        CaseUrgency.routine   => Icons.schedule_rounded,
        CaseUrgency.urgent    => Icons.priority_high_rounded,
        CaseUrgency.critical  => Icons.local_fire_department_rounded,
        CaseUrgency.emergency => Icons.emergency_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items
          .map((u) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onChanged(u),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected == u
                            ? _color(u).withOpacity(0.15)
                            : KxColors.bgCard,
                        borderRadius: KxSpacing.radiusMd,
                        border: Border.all(
                          color: selected == u
                              ? _color(u)
                              : KxColors.border,
                          width: selected == u ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_icon(u),
                              size: 18,
                              color: selected == u
                                  ? _color(u)
                                  : KxColors.textMuted),
                          const SizedBox(height: 4),
                          Text(
                            u.label,
                            style: KxTypography.caption.copyWith(
                              color: selected == u
                                  ? _color(u)
                                  : KxColors.textMuted,
                              fontWeight: selected == u
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Urgency badge (preview) ────────────────────────────────────

class _UrgencyBadge extends StatelessWidget {
  final CaseUrgency urgency;
  const _UrgencyBadge(this.urgency);

  @override
  Widget build(BuildContext context) {
    final color = switch (urgency) {
      CaseUrgency.routine   => const Color(0xFF6B7280),
      CaseUrgency.urgent    => const Color(0xFFF59E0B),
      CaseUrgency.critical  => const Color(0xFFEF4444),
      CaseUrgency.emergency => const Color(0xFFDC2626),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: KxSpacing.radiusPill,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(urgency.label,
          style: KxTypography.caption
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Preview row ────────────────────────────────────────────────

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                KxTypography.caption.copyWith(color: KxColors.textMuted)),
        const SizedBox(height: 3),
        Text(value,
            style: KxTypography.bodyMd
                .copyWith(color: KxColors.textSecondary)),
      ],
    );
  }
}

// ── Vital entry model ──────────────────────────────────────────

class _VitalEntry {
  final String label;
  final String value;
  final String? unit;
  final VitalRange range;

  const _VitalEntry({
    required this.label,
    required this.value,
    this.unit,
    this.range = VitalRange.normal,
  });
}

// ── Vital chip (editable) ──────────────────────────────────────

class _VitalChipEditable extends StatelessWidget {
  final _VitalEntry vital;
  final VoidCallback onDelete;
  const _VitalChipEditable(
      {required this.vital, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = switch (vital.range) {
      VitalRange.normal   => KxColors.teal400,
      VitalRange.warning  => const Color(0xFFF59E0B),
      VitalRange.critical => KxColors.crimson400,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${vital.label}: ${vital.value}${vital.unit != null ? ' ${vital.unit}' : ''}',
            style: KxTypography.caption.copyWith(color: color),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Vital picker bottom sheet ──────────────────────────────────

class _VitalPickerSheet extends StatefulWidget {
  final ValueChanged<_VitalEntry> onPick;
  const _VitalPickerSheet({required this.onPick});

  @override
  State<_VitalPickerSheet> createState() => _VitalPickerSheetState();
}

class _VitalPickerSheetState extends State<_VitalPickerSheet> {
  final _labelCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _unitCtrl  = TextEditingController();
  VitalRange _range = VitalRange.normal;

  static const _presets = [
    ('KB', '120/80', 'mmHg'),
    ('Nabiz', '72', '/dk'),
    ('SpO2', '98', '%'),
    ('Ates', '37.0', '\u00B0C'),
    ('Solunum Hizi', '16', '/dk'),
    ('GKS', '15', 'puan'),
    ('Kan Sekeri', '120', 'mg/dL'),
  ];

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _labelCtrl.text.trim();
    final value = _valueCtrl.text.trim();
    if (label.isNotEmpty && value.isNotEmpty) {
      widget.onPick(_VitalEntry(
        label: label,
        value: value,
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        range: _range,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Vital Ekle',
                    style: KxTypography.headingSm
                        .copyWith(color: KxColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      size: 20, color: KxColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Presets
            Text('Hazir Secenekler',
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presets
                  .map((p) => GestureDetector(
                        onTap: () {
                          _labelCtrl.text = p.$1;
                          _valueCtrl.text = p.$2;
                          _unitCtrl.text  = p.$3;
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: KxColors.bgCard,
                            borderRadius: KxSpacing.radiusMd,
                            border: Border.all(color: KxColors.border),
                          ),
                          child: Text(p.$1,
                              style: KxTypography.caption
                                  .copyWith(
                                      color: KxColors.textSecondary)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: KxTextField(
                    controller: _labelCtrl,
                    hint: 'Parametre',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: KxTextField(
                    controller: _valueCtrl,
                    hint: 'Deger',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: KxTextField(
                    controller: _unitCtrl,
                    hint: 'Birim',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Range picker
            Row(
              children: VitalRange.values.map((r) {
                final selected = _range == r;
                final color = switch (r) {
                  VitalRange.normal   => KxColors.teal400,
                  VitalRange.warning  => const Color(0xFFF59E0B),
                  VitalRange.critical => KxColors.crimson400,
                };
                final label = switch (r) {
                  VitalRange.normal   => 'Normal',
                  VitalRange.warning  => 'Dikkat',
                  VitalRange.critical => 'Kritik',
                };
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _range = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.12)
                              : KxColors.bgCard,
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(
                              color: selected ? color : KxColors.border),
                        ),
                        child: Text(label,
                            textAlign: TextAlign.center,
                            style: KxTypography.caption.copyWith(
                              color: selected ? color : KxColors.textMuted,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: KxButton.primary(
                label: 'Ekle',
                onPressed: _labelCtrl.text.isNotEmpty &&
                        _valueCtrl.text.isNotEmpty
                    ? _submit
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// FILE ATTACHMENT SECTION
// ══════════════════════════════════════════════════════════════════

/// Dosya ekleme bolumu — file_picker ve image_picker destekli.
/// PDF, JPG, PNG, DICOM dosyalari kabul eder.
/// Maks 10 dosya, her biri maks 20MB.
class _FileAttachmentSection extends StatelessWidget {
  final List<File> attachedFiles;
  final VoidCallback onFilesChanged;
  final int maxFiles;
  final int maxFileSizeBytes;
  final List<String> allowedExtensions;

  const _FileAttachmentSection({
    required this.attachedFiles,
    required this.onFilesChanged,
    required this.maxFiles,
    required this.maxFileSizeBytes,
    required this.allowedExtensions,
  });

  /// Dosya uzantisina gore ikon dondur
  static IconData iconForFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf'              => Icons.picture_as_pdf_rounded,
      'jpg' || 'jpeg'    => Icons.image_rounded,
      'png'              => Icons.image_rounded,
      'dcm'              => Icons.biotech_rounded,
      _                  => Icons.insert_drive_file_rounded,
    };
  }

  /// Dosya boyutunu okunabilir formatta dondur
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFiles(BuildContext context) async {
    if (attachedFiles.length >= maxFiles) {
      _showMessage(context, 'En fazla $maxFiles dosya ekleyebilirsiniz.');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      for (final pf in result.files) {
        if (attachedFiles.length >= maxFiles) {
          _showMessage(context, 'Dosya limiti doldu ($maxFiles dosya).');
          break;
        }
        if (pf.path == null) continue;

        final file = File(pf.path!);
        final size = await file.length();

        if (size > maxFileSizeBytes) {
          if (context.mounted) {
            _showMessage(context,
                '${pf.name} cok buyuk (${_formatFileSize(size)}). Maks ${_formatFileSize(maxFileSizeBytes)}.');
          }
          continue;
        }

        // Tekrar eklemeyi onle
        final alreadyAdded =
            attachedFiles.any((f) => f.path == file.path);
        if (!alreadyAdded) {
          attachedFiles.add(file);
        }
      }

      onFilesChanged();
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'Dosya secilirken hata olustu.');
      }
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    if (attachedFiles.length >= maxFiles) {
      _showMessage(context, 'En fazla $maxFiles dosya ekleyebilirsiniz.');
      return;
    }

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (photo == null) return;

      final file = File(photo.path);
      final size = await file.length();

      if (size > maxFileSizeBytes) {
        if (context.mounted) {
          _showMessage(context,
              'Fotograf cok buyuk (${_formatFileSize(size)}). Maks ${_formatFileSize(maxFileSizeBytes)}.');
        }
        return;
      }

      attachedFiles.add(file);
      onFilesChanged();
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'Kamera acilirken hata olustu.');
      }
    }
  }

  void _removeFile(int index) {
    attachedFiles.removeAt(index);
    onFilesChanged();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: KxColors.crimson400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusMd),
        content: Text(
          message,
          style: KxTypography.labelSm.copyWith(color: KxColors.bgVoid),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dosya ekleme alani (dashed border)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(
              color: KxColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              if (attachedFiles.isEmpty) ...[
                Icon(Icons.cloud_upload_outlined,
                    size: 32, color: KxColors.textMuted),
                const SizedBox(height: 8),
                Text(
                  'PDF, JPG, PNG veya DICOM dosyalari ekleyin',
                  style: KxTypography.bodyMd
                      .copyWith(color: KxColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Maks 10 dosya, her biri maks 20MB',
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
              ],

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickFiles(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.12),
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(
                              color: KxColors.teal400.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 16, color: KxColors.teal400),
                            const SizedBox(width: 6),
                            Text(
                              'Dosya Ekle',
                              style: KxTypography.labelSm
                                  .copyWith(color: KxColors.teal400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickFromCamera(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.12),
                          borderRadius: KxSpacing.radiusMd,
                          border: Border.all(
                              color: KxColors.teal400.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 16, color: KxColors.teal400),
                            const SizedBox(width: 6),
                            Text(
                              'Kamera ile Cek',
                              style: KxTypography.labelSm
                                  .copyWith(color: KxColors.teal400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Eklenen dosyalar listesi
        if (attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${attachedFiles.length} / $maxFiles dosya eklendi',
            style: KxTypography.caption.copyWith(color: KxColors.textMuted),
          ),
          const SizedBox(height: 8),
          ...List.generate(attachedFiles.length, (i) {
            final file = attachedFiles[i];
            final name = file.path.split('/').last;
            final ext = name.split('.').last.toLowerCase();

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: KxColors.bgSurface,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(color: KxColors.border),
                ),
                child: Row(
                  children: [
                    // Dosya ikonu
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: KxColors.teal400.withOpacity(0.1),
                        borderRadius: KxSpacing.radiusSm,
                      ),
                      child: Center(
                        child: Icon(
                          iconForFile(file.path),
                          size: 16,
                          color: KxColors.teal400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dosya adi ve boyutu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: KxTypography.labelSm
                                .copyWith(color: KxColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<int>(
                            future: file.length(),
                            builder: (_, snap) {
                              final size = snap.data ?? 0;
                              return Text(
                                '${ext.toUpperCase()} \u2022 ${_formatFileSize(size)}',
                                style: KxTypography.caption
                                    .copyWith(color: KxColors.textMuted),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Sil butonu
                    GestureDetector(
                      onTap: () => _removeFile(i),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: KxColors.crimson400.withOpacity(0.1),
                          borderRadius: KxSpacing.radiusSm,
                        ),
                        child: const Center(
                          child: Icon(Icons.close_rounded,
                              size: 14, color: KxColors.crimson400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
