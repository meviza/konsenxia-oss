import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/organisms/kx_body_map.dart';
import '../../../../design_system/organisms/kx_diagnosis_graph.dart';
import '../../domain/entities/diagnosis_entity.dart';
import '../bloc/diagnosis_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class DifferentialDiagnosisPage extends StatelessWidget {
  const DifferentialDiagnosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagnosisBloc, DiagnosisState>(
      builder: (context, state) {
        if (state is DiagnosisAnalyzing) {
          return const _AnalyzingView();
        }
        if (state is DiagnosisResultState) {
          return _ResultView(session: state.session);
        }
        if (state is DiagnosisError) {
          return _ErrorView(message: state.message, lastInput: state.lastInput);
        }
        if (state is DiagnosisInputState) {
          return _InputView(
            input: state.input,
            suggestedSymptoms: state.suggestedSymptoms,
          );
        }
        return const _InputView(input: null, suggestedSymptoms: []);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INPUT VIEW — Wizard-style
// ─────────────────────────────────────────────────────────────────────────────

class _InputView extends StatefulWidget {
  final DiagnosisInput? input;
  final List<String> suggestedSymptoms;

  const _InputView({required this.input, required this.suggestedSymptoms});

  @override
  State<_InputView> createState() => _InputViewState();
}

class _InputViewState extends State<_InputView> with TickerProviderStateMixin {
  late final TextEditingController _complaintCtrl;
  late final TextEditingController _notesCtrl;
  late final FocusNode _complaintFocus;
  late final AnimationController _pulseCtrl;
  late final AnimationController _buttonCtrl;
  late final Animation<double> _pulseAnim;

  // Section expansion
  final Map<String, bool> _expanded = {
    'demographics': true,
    'complaint': true,
    'symptoms': false,
    'vitals': false,
    'notes': false,
  };

  // Local state
  int _age = 35;
  String _gender = 'Erkek';

  // Vitals controllers
  late final TextEditingController _bpSysCtrl;
  late final TextEditingController _bpDiaCtrl;
  late final TextEditingController _hrCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _rrCtrl;
  late final TextEditingController _spo2Ctrl;

  @override
  void initState() {
    super.initState();
    final inp = widget.input;
    _age = inp?.patientAge ?? 35;
    _gender = inp?.patientGender ?? 'Erkek';
    _complaintCtrl = TextEditingController(text: inp?.chiefComplaint ?? '');
    _notesCtrl = TextEditingController(text: inp?.additionalNotes ?? '');
    _complaintFocus = FocusNode();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    final vitals = inp?.vitals;
    _bpSysCtrl = TextEditingController(text: vitals?['bpSystolic'] ?? '');
    _bpDiaCtrl = TextEditingController(text: vitals?['bpDiastolic'] ?? '');
    _hrCtrl = TextEditingController(text: vitals?['heartRate'] ?? '');
    _tempCtrl = TextEditingController(text: vitals?['temperature'] ?? '');
    _rrCtrl = TextEditingController(text: vitals?['respiratoryRate'] ?? '');
    _spo2Ctrl = TextEditingController(text: vitals?['spo2'] ?? '');

    _complaintFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _notesCtrl.dispose();
    _complaintFocus.dispose();
    _pulseCtrl.dispose();
    _buttonCtrl.dispose();
    _bpSysCtrl.dispose();
    _bpDiaCtrl.dispose();
    _hrCtrl.dispose();
    _tempCtrl.dispose();
    _rrCtrl.dispose();
    _spo2Ctrl.dispose();
    super.dispose();
  }

  DiagnosisInput _buildInput() {
    final vitals = <String, String>{};
    if (_bpSysCtrl.text.isNotEmpty) vitals['bpSystolic'] = _bpSysCtrl.text;
    if (_bpDiaCtrl.text.isNotEmpty) vitals['bpDiastolic'] = _bpDiaCtrl.text;
    if (_hrCtrl.text.isNotEmpty) vitals['heartRate'] = _hrCtrl.text;
    if (_tempCtrl.text.isNotEmpty) vitals['temperature'] = _tempCtrl.text;
    if (_rrCtrl.text.isNotEmpty) vitals['respiratoryRate'] = _rrCtrl.text;
    if (_spo2Ctrl.text.isNotEmpty) vitals['spo2'] = _spo2Ctrl.text;

    return (widget.input ?? DiagnosisInput(
      patientAge: _age,
      patientGender: _gender,
      chiefComplaint: '',
      symptoms: [],
    )).copyWith(
      patientAge: _age,
      patientGender: _gender,
      chiefComplaint: _complaintCtrl.text,
      additionalNotes: _notesCtrl.text,
      vitals: vitals.isEmpty ? null : vitals,
    );
  }

  void _syncInput() {
    context.read<DiagnosisBloc>().add(UpdateInputEvent(_buildInput()));
  }

  void _toggleSection(String key) {
    HapticFeedback.selectionClick();
    setState(() => _expanded[key] = !(_expanded[key] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = widget.input?.symptoms ?? [];
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: KxColors.bgBase,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: KxColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: KxSpacing.xl2, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayirici Tani',
                    style: KxTypography.displaySm.copyWith(
                      color: KxColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Yapay zeka destekli analiz',
                    style: KxTypography.labelSm.copyWith(
                      color: KxColors.teal400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              KxSpacing.xl2,
              KxSpacing.sm,
              KxSpacing.xl2,
              pad.bottom + 100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Demographics Section ──
                _SectionHeader(
                  icon: Icons.person_outline_rounded,
                  title: 'Demografik Bilgiler',
                  expanded: _expanded['demographics']!,
                  onTap: () => _toggleSection('demographics'),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _expanded['demographics']!
                      ? Padding(
                          padding: EdgeInsets.only(bottom: KxSpacing.xl2),
                          child: Column(
                            children: [
                              SizedBox(height: KxSpacing.md),
                              _AgeSelector(
                                age: _age,
                                onChanged: (v) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _age = v);
                                  _syncInput();
                                },
                              ),
                              SizedBox(height: KxSpacing.lg),
                              _GenderToggle(
                                selected: _gender,
                                onChanged: (v) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _gender = v);
                                  _syncInput();
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Chief Complaint ──
                _SectionHeader(
                  icon: Icons.edit_note_rounded,
                  title: 'Basvuru Sikayeti',
                  expanded: _expanded['complaint']!,
                  onTap: () => _toggleSection('complaint'),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _expanded['complaint']!
                      ? Padding(
                          padding: EdgeInsets.only(bottom: KxSpacing.xl2),
                          child: Column(
                            children: [
                              SizedBox(height: KxSpacing.md),
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (context, child) {
                                  final isFocused = _complaintFocus.hasFocus;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: KxSpacing.radiusLg,
                                      boxShadow: isFocused
                                          ? [
                                              BoxShadow(
                                                color: KxColors.teal400.withOpacity(
                                                  0.15 + _pulseAnim.value * 0.1,
                                                ),
                                                blurRadius: 12 + _pulseAnim.value * 6,
                                                spreadRadius: -2,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: child,
                                  );
                                },
                                child: _KxTextField(
                                  controller: _complaintCtrl,
                                  focusNode: _complaintFocus,
                                  hint: 'Hastanin ana sikayetini girin...',
                                  maxLines: 3,
                                  onChanged: (_) {
                                    _syncInput();
                                    if (_complaintCtrl.text.length > 3) {
                                      context.read<DiagnosisBloc>().add(
                                            GetSuggestedSymptomsEvent(_complaintCtrl.text),
                                          );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Symptoms ──
                _SectionHeader(
                  icon: Icons.medical_information_outlined,
                  title: 'Semptomlar',
                  expanded: _expanded['symptoms']!,
                  onTap: () => _toggleSection('symptoms'),
                  badge: symptoms.isNotEmpty ? '${symptoms.length}' : null,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _expanded['symptoms']!
                      ? Padding(
                          padding: EdgeInsets.only(bottom: KxSpacing.xl2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: KxSpacing.md),
                              // ── Interactive Body Map ──
                              Center(
                                child: KxBodyMap(
                                  selectedRegions: const {},
                                  onRegionTapped: (_) {},
                                  onSymptomSelected: (symptom) {
                                    HapticFeedback.lightImpact();
                                    context.read<DiagnosisBloc>().add(AddSymptomEvent(symptom));
                                  },
                                  height: 320,
                                ),
                              ),
                              SizedBox(height: KxSpacing.lg),
                              _SymptomChipGrid(
                                symptoms: symptoms,
                                onRemove: (s) {
                                  HapticFeedback.lightImpact();
                                  context.read<DiagnosisBloc>().add(RemoveSymptomEvent(s));
                                },
                              ),
                              if (widget.suggestedSymptoms.isNotEmpty) ...[
                                SizedBox(height: KxSpacing.lg),
                                Text(
                                  'AI ONERILERI',
                                  style: KxTypography.overline.copyWith(
                                    color: KxColors.teal400,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: KxSpacing.sm),
                                _SuggestedChipGrid(
                                  suggestions: widget.suggestedSymptoms
                                      .where((s) => !symptoms.contains(s))
                                      .toList(),
                                  onAdd: (s) {
                                    HapticFeedback.lightImpact();
                                    context.read<DiagnosisBloc>().add(AddSymptomEvent(s));
                                  },
                                ),
                              ],
                              SizedBox(height: KxSpacing.md),
                              _AddSymptomField(
                                onAdd: (s) {
                                  HapticFeedback.lightImpact();
                                  context.read<DiagnosisBloc>().add(AddSymptomEvent(s));
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Vitals ──
                _SectionHeader(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Vital Bulgular',
                  expanded: _expanded['vitals']!,
                  onTap: () => _toggleSection('vitals'),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _expanded['vitals']!
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: KxSpacing.md,
                            bottom: KxSpacing.xl2,
                          ),
                          child: _VitalsGrid(
                            bpSysCtrl: _bpSysCtrl,
                            bpDiaCtrl: _bpDiaCtrl,
                            hrCtrl: _hrCtrl,
                            tempCtrl: _tempCtrl,
                            rrCtrl: _rrCtrl,
                            spo2Ctrl: _spo2Ctrl,
                            onChanged: _syncInput,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Notes ──
                _SectionHeader(
                  icon: Icons.note_alt_outlined,
                  title: 'Ek Notlar',
                  expanded: _expanded['notes']!,
                  onTap: () => _toggleSection('notes'),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _expanded['notes']!
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: KxSpacing.md,
                            bottom: KxSpacing.xl2,
                          ),
                          child: _KxTextField(
                            controller: _notesCtrl,
                            hint: 'Oykuye ait ek notlar...',
                            maxLines: 4,
                            onChanged: (_) => _syncInput(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
        ],
      ),

      // ── Analyze Button ──
      bottomSheet: Container(
        color: KxColors.bgBase,
        padding: EdgeInsets.fromLTRB(
          KxSpacing.xl2,
          KxSpacing.md,
          KxSpacing.xl2,
          pad.bottom + KxSpacing.md,
        ),
        child: ScaleTransition(
          scale: _buttonCtrl,
          child: GestureDetector(
            onTapDown: (_) => _buttonCtrl.reverse(),
            onTapUp: (_) {
              _buttonCtrl.forward();
              HapticFeedback.mediumImpact();
              final input = _buildInput();
              context.read<DiagnosisBloc>().add(UpdateInputEvent(input));
              context.read<DiagnosisBloc>().add(AnalyzeEvent());
            },
            onTapCancel: () => _buttonCtrl.forward(),
            child: Container(
              width: double.infinity,
              height: KxSpacing.touchTarget + 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KxColors.teal500, KxColors.teal400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: KxSpacing.radiusLg,
                boxShadow: KxShadows.tealGlow(),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                    SizedBox(width: KxSpacing.sm),
                    Text(
                      'ANALIZ ET',
                      style: KxTypography.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final String? badge;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: KxSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: KxColors.teal400.withOpacity(0.1),
                borderRadius: KxSpacing.radiusMd,
              ),
              child: Icon(icon, color: KxColors.teal400, size: 18),
            ),
            SizedBox(width: KxSpacing.md),
            Expanded(
              child: Text(
                title,
                style: KxTypography.headingMd.copyWith(color: KxColors.textPrimary),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.15),
                  borderRadius: KxSpacing.radiusFull,
                ),
                child: Text(
                  badge!,
                  style: KxTypography.labelSm.copyWith(color: KxColors.teal400),
                ),
              ),
            SizedBox(width: KxSpacing.sm),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: KxColors.textMuted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AGE SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _AgeSelector extends StatelessWidget {
  final int age;
  final ValueChanged<int> onChanged;

  const _AgeSelector({required this.age, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KxSpacing.lg),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YAS',
                  style: KxTypography.overline.copyWith(
                    color: KxColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: KxSpacing.xs),
                Text(
                  '$age',
                  style: KxTypography.monoLg.copyWith(
                    color: KxColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _CircleButton(
                icon: Icons.add,
                onTap: () => onChanged((age + 1).clamp(0, 120)),
              ),
              SizedBox(height: KxSpacing.sm),
              _CircleButton(
                icon: Icons.remove,
                onTap: () => onChanged((age - 1).clamp(0, 120)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KxColors.bgElevated,
          border: Border.all(color: KxColors.borderSubtle),
        ),
        child: Icon(icon, color: KxColors.teal400, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENDER TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

class _GenderToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderToggle({required this.selected, required this.onChanged});

  static const _options = ['Erkek', 'Kadin', 'Diger'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.borderSubtle),
      ),
      child: Row(
        children: _options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: KxSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? KxColors.teal400.withOpacity(0.15) : Colors.transparent,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border.all(
                    color: isSelected ? KxColors.teal400.withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: KxTypography.labelMd.copyWith(
                      color: isSelected ? KxColors.teal400 : KxColors.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SYMPTOM CHIP GRID
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomChipGrid extends StatelessWidget {
  final List<String> symptoms;
  final ValueChanged<String> onRemove;

  const _SymptomChipGrid({required this.symptoms, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (symptoms.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(KxSpacing.xl2),
          child: Text(
            'Henuz semptom eklenmedi',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textDisabled),
          ),
        ),
      );
    }
    return Wrap(
      spacing: KxSpacing.sm,
      runSpacing: KxSpacing.sm,
      children: symptoms.map((s) {
        return _AnimatedChipEntry(
          key: ValueKey('sym_$s'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: KxSpacing.md, vertical: KxSpacing.sm),
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.12),
              borderRadius: KxSpacing.radiusFull,
              border: Border.all(color: KxColors.teal400.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s,
                  style: KxTypography.labelMd.copyWith(color: KxColors.teal300),
                ),
                SizedBox(width: KxSpacing.xs),
                GestureDetector(
                  onTap: () => onRemove(s),
                  child: Icon(Icons.close_rounded, size: 16, color: KxColors.teal400),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AnimatedChipEntry extends StatefulWidget {
  final Widget child;

  const _AnimatedChipEntry({super.key, required this.child});

  @override
  State<_AnimatedChipEntry> createState() => _AnimatedChipEntryState();
}

class _AnimatedChipEntryState extends State<_AnimatedChipEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUGGESTED SYMPTOM CHIPS (AI shimmer)
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestedChipGrid extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onAdd;

  const _SuggestedChipGrid({required this.suggestions, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KxSpacing.sm,
      runSpacing: KxSpacing.sm,
      children: suggestions.map((s) {
        return _ShimmerChip(label: s, onTap: () => onAdd(s));
      }).toList(),
    );
  }
}

class _ShimmerChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ShimmerChip({required this.label, required this.onTap});

  @override
  State<_ShimmerChip> createState() => _ShimmerChipState();
}

class _ShimmerChipState extends State<_ShimmerChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: KxSpacing.md, vertical: KxSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: KxSpacing.radiusFull,
              border: Border.all(
                color: KxColors.teal400.withOpacity(0.2 + 0.15 * sin(_ctrl.value * 2 * pi)),
              ),
              gradient: LinearGradient(
                colors: [
                  KxColors.teal400.withOpacity(0.04),
                  KxColors.teal400.withOpacity(0.08 + 0.04 * sin(_ctrl.value * 2 * pi)),
                  KxColors.teal400.withOpacity(0.04),
                ],
                stops: [0.0, _ctrl.value, 1.0],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14, color: KxColors.teal400),
                SizedBox(width: KxSpacing.xs),
                Text(
                  widget.label,
                  style: KxTypography.labelMd.copyWith(color: KxColors.teal400),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD SYMPTOM TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────

class _AddSymptomField extends StatefulWidget {
  final ValueChanged<String> onAdd;

  const _AddSymptomField({required this.onAdd});

  @override
  State<_AddSymptomField> createState() => _AddSymptomFieldState();
}

class _AddSymptomFieldState extends State<_AddSymptomField> {
  final _ctrl = TextEditingController();

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KxTextField(
            controller: _ctrl,
            hint: 'Semptom ekle...',
            onSubmitted: (_) => _submit(),
          ),
        ),
        SizedBox(width: KxSpacing.sm),
        GestureDetector(
          onTap: _submit,
          child: Container(
            width: KxSpacing.touchTarget,
            height: KxSpacing.touchTarget,
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.15),
              borderRadius: KxSpacing.radiusMd,
            ),
            child: Icon(Icons.add_rounded, color: KxColors.teal400),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VITALS GRID
// ─────────────────────────────────────────────────────────────────────────────

class _VitalsGrid extends StatelessWidget {
  final TextEditingController bpSysCtrl;
  final TextEditingController bpDiaCtrl;
  final TextEditingController hrCtrl;
  final TextEditingController tempCtrl;
  final TextEditingController rrCtrl;
  final TextEditingController spo2Ctrl;
  final VoidCallback onChanged;

  const _VitalsGrid({
    required this.bpSysCtrl,
    required this.bpDiaCtrl,
    required this.hrCtrl,
    required this.tempCtrl,
    required this.rrCtrl,
    required this.spo2Ctrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _VitalTile(
                icon: Icons.favorite_outline_rounded,
                label: 'Sistolik',
                unit: 'mmHg',
                controller: bpSysCtrl,
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: KxSpacing.md),
            Expanded(
              child: _VitalTile(
                icon: Icons.favorite_outline_rounded,
                label: 'Diastolik',
                unit: 'mmHg',
                controller: bpDiaCtrl,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: KxSpacing.md),
        Row(
          children: [
            Expanded(
              child: _VitalTile(
                icon: Icons.monitor_heart_outlined,
                label: 'Nabiz',
                unit: 'bpm',
                controller: hrCtrl,
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: KxSpacing.md),
            Expanded(
              child: _VitalTile(
                icon: Icons.thermostat_outlined,
                label: 'Ates',
                unit: '\u00b0C',
                controller: tempCtrl,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: KxSpacing.md),
        Row(
          children: [
            Expanded(
              child: _VitalTile(
                icon: Icons.air_rounded,
                label: 'Solunum',
                unit: '/dk',
                controller: rrCtrl,
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: KxSpacing.md),
            Expanded(
              child: _VitalTile(
                icon: Icons.bloodtype_outlined,
                label: 'SpO2',
                unit: '%',
                controller: spo2Ctrl,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VitalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String unit;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _VitalTile({
    required this.icon,
    required this.label,
    required this.unit,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KxSpacing.md),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: KxColors.textMuted),
              SizedBox(width: KxSpacing.xs),
              Text(
                label,
                style: KxTypography.labelSm.copyWith(color: KxColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: KxSpacing.sm),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: KxTypography.monoMd.copyWith(color: KxColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '---',
              hintStyle: KxTypography.monoMd.copyWith(color: KxColors.textDisabled),
              suffixText: unit,
              suffixStyle: KxTypography.labelSm.copyWith(color: KxColors.textMuted),
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KX TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────

class _KxTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _KxTextField({
    required this.controller,
    this.focusNode,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      style: KxTypography.bodyLg.copyWith(color: KxColors.textPrimary),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: KxTypography.bodyLg.copyWith(color: KxColors.textDisabled),
        filled: true,
        fillColor: KxColors.bgSurface,
        contentPadding: EdgeInsets.all(KxSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: KxSpacing.radiusLg,
          borderSide: BorderSide(color: KxColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusLg,
          borderSide: BorderSide(color: KxColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusLg,
          borderSide: BorderSide(color: KxColors.teal400, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYZING VIEW — Pulsing circles + cycling text
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyzingView extends StatefulWidget {
  const _AnalyzingView();

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _textCtrl;
  int _textIndex = 0;

  static const _messages = [
    'Semptomlar degerlendiriliyor...',
    'Ayirici tani olusturuluyor...',
    'Risk faktorleri analiz ediliyor...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _textCtrl.addListener(() {
      final newIndex = (_textCtrl.value * _messages.length).floor() % _messages.length;
      if (newIndex != _textIndex) {
        setState(() => _textIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing circles
            SizedBox(
              width: 120,
              height: 40,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final offset = i * 0.2;
                      final value = ((_pulseCtrl.value + offset) % 1.0);
                      final scale = 0.5 + 0.5 * sin(value * pi);
                      final opacity = 0.3 + 0.7 * sin(value * pi);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: KxSpacing.sm),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KxColors.teal400.withOpacity(opacity),
                              boxShadow: [
                                BoxShadow(
                                  color: KxColors.teal400.withOpacity(opacity * 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: KxSpacing.xl4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                _messages[_textIndex],
                key: ValueKey(_textIndex),
                style: KxTypography.bodyLg.copyWith(color: KxColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ResultView extends StatefulWidget {
  final DiagnosisSession session;

  const _ResultView({required this.session});

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> with TickerProviderStateMixin {
  late final AnimationController _gaugeCtrl;
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _gaugeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _gaugeCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _gaugeCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.session.result!;
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: KxColors.bgBase,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: KxColors.textPrimary, size: 20),
              onPressed: () {
                context.read<DiagnosisBloc>().add(ClearResultEvent());
              },
            ),
            title: Text(
              'Sonuclar',
              style: KxTypography.headingLg.copyWith(color: KxColors.textPrimary),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.bookmark_border_rounded, color: KxColors.teal400),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<DiagnosisBloc>().add(SaveSessionEvent());
                },
              ),
            ],
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              KxSpacing.xl2,
              KxSpacing.md,
              KxSpacing.xl2,
              pad.bottom + KxSpacing.xl4,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Confidence Gauge ──
                Center(
                  child: AnimatedBuilder(
                    animation: _gaugeCtrl,
                    builder: (context, _) {
                      return _ConfidenceGauge(
                        score: result.confidenceScore,
                        progress: CurvedAnimation(
                          parent: _gaugeCtrl,
                          curve: Curves.easeOutCubic,
                        ).value,
                      );
                    },
                  ),
                ),
                SizedBox(height: KxSpacing.sm),
                Center(
                  child: Text(
                    '${result.processingMs}ms islem suresi',
                    style: KxTypography.caption.copyWith(color: KxColors.textMuted),
                  ),
                ),
                SizedBox(height: KxSpacing.xl4),

                // ── Diagnosis Network Graph ──
                Text(
                  'TANI ILISKILERI',
                  style: KxTypography.overline.copyWith(
                    color: KxColors.teal400,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: KxSpacing.md),
                KxDiagnosisGraph(
                  chiefComplaint: widget.session.input.chiefComplaint,
                  nodes: result.differentials.map((d) => DiagnosisNode(
                    id: '${d.rank}',
                    name: d.diagnosis,
                    probability: d.probability,
                    type: d.probability > 0.3
                        ? NodeType.primary
                        : d.probability > 0.15
                            ? NodeType.secondary
                            : NodeType.excluded,
                    connectedTo: result.differentials
                        .where((other) => other.rank != d.rank)
                        .take(2)
                        .map((other) => '${other.rank}')
                        .toList(),
                    reasoning: d.reasoning,
                  )).toList(),
                  onNodeTapped: (_) {},
                  height: 320,
                ),
                SizedBox(height: KxSpacing.xl4),

                // ── Red Flags ──
                if (result.redFlags.isNotEmpty) ...[
                  Text(
                    'KIRMIZI BAYRAKLAR',
                    style: KxTypography.overline.copyWith(
                      color: KxColors.crimson400,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: KxSpacing.md),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: result.redFlags.length,
                      separatorBuilder: (_, __) => SizedBox(width: KxSpacing.md),
                      itemBuilder: (context, i) {
                        return Container(
                          width: 220,
                          padding: EdgeInsets.all(KxSpacing.md),
                          decoration: BoxDecoration(
                            color: KxColors.crimson400.withOpacity(0.08),
                            borderRadius: KxSpacing.radiusLg,
                            border: Border.all(color: KxColors.crimson400.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: KxColors.crimson400,
                                size: 22,
                              ),
                              SizedBox(width: KxSpacing.sm),
                              Expanded(
                                child: Text(
                                  result.redFlags[i],
                                  style: KxTypography.labelMd.copyWith(
                                    color: KxColors.crimson300,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: KxSpacing.xl4),
                ],

                // ── Differentials ──
                Text(
                  'AYIRICI TANILAR',
                  style: KxTypography.overline.copyWith(
                    color: KxColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: KxSpacing.md),
                ...result.differentials.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final diff = entry.value;
                  return _DifferentialCard(
                    item: diff,
                    delay: Duration(milliseconds: 50 * idx),
                  );
                }),
                SizedBox(height: KxSpacing.xl4),

                // ── Recommended Tests ──
                if (result.recommendedTests.isNotEmpty) ...[
                  Text(
                    'ONERILEN TESTLER',
                    style: KxTypography.overline.copyWith(
                      color: KxColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: KxSpacing.md),
                  ..._groupTestsByPriority(result.recommendedTests).entries.map((entry) {
                    return _TestPriorityGroup(
                      priority: entry.key,
                      tests: entry.value,
                    );
                  }),
                  SizedBox(height: KxSpacing.xl4),
                ],

                // ── Risk Factors ──
                if (result.riskFactors.isNotEmpty) ...[
                  Text(
                    'RISK FAKTORLERI',
                    style: KxTypography.overline.copyWith(
                      color: KxColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: KxSpacing.md),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: result.riskFactors.length,
                      separatorBuilder: (_, __) => SizedBox(width: KxSpacing.md),
                      itemBuilder: (context, i) {
                        final risk = result.riskFactors[i];
                        return _RiskCard(risk: risk);
                      },
                    ),
                  ),
                  SizedBox(height: KxSpacing.xl4),
                ],

                // ── Clinical Comment ──
                if (result.clinicalComment.isNotEmpty) ...[
                  Text(
                    'KLINIK YORUM',
                    style: KxTypography.overline.copyWith(
                      color: KxColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: KxSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(KxSpacing.xl),
                    decoration: BoxDecoration(
                      color: KxColors.bgSurface.withOpacity(0.7),
                      borderRadius: KxSpacing.radiusLg,
                      border: Border.all(color: KxColors.teal400.withOpacity(0.25)),
                      boxShadow: KxShadows.tealGlow(),
                    ),
                    child: Text(
                      result.clinicalComment,
                      style: KxTypography.bodyLg.copyWith(
                        color: KxColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: KxSpacing.xl4),
                ],

                // ── Bottom Actions ──
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Yeni Analiz',
                        icon: Icons.refresh_rounded,
                        filled: false,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.read<DiagnosisBloc>().add(ClearResultEvent());
                        },
                      ),
                    ),
                    SizedBox(width: KxSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        label: 'Kaydet',
                        icon: Icons.save_outlined,
                        filled: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.read<DiagnosisBloc>().add(SaveSessionEvent());
                        },
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Map<TestPriority, List<RecommendedTest>> _groupTestsByPriority(
    List<RecommendedTest> tests,
  ) {
    final grouped = <TestPriority, List<RecommendedTest>>{};
    for (final t in tests) {
      grouped.putIfAbsent(t.priority, () => []).add(t);
    }
    // Sort by priority: stat > urgent > routine
    final sorted = <TestPriority, List<RecommendedTest>>{};
    for (final p in [TestPriority.stat, TestPriority.urgent, TestPriority.routine]) {
      if (grouped.containsKey(p)) sorted[p] = grouped[p]!;
    }
    return sorted;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIDENCE GAUGE (CustomPainter)
// ─────────────────────────────────────────────────────────────────────────────

class _ConfidenceGauge extends StatelessWidget {
  final double score; // 0..1
  final double progress;

  const _ConfidenceGauge({required this.score, required this.progress});

  @override
  Widget build(BuildContext context) {
    final displayScore = (score * progress * 100).round();
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _GaugePainter(
          score: score,
          progress: progress,
          trackColor: KxColors.bgElevated,
          fillColor: _gaugeColor(score),
          glowColor: _gaugeColor(score).withOpacity(0.3),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$displayScore',
                style: KxTypography.monoLg.copyWith(
                  color: KxColors.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'GUVEN',
                style: KxTypography.overline.copyWith(
                  color: KxColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _gaugeColor(double s) {
    if (s >= 0.75) return KxColors.jade500;
    if (s >= 0.5) return KxColors.teal400;
    if (s >= 0.25) return KxColors.amber500;
    return KxColors.crimson400;
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final Color glowColor;

  _GaugePainter({
    required this.score,
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 8.0;
    const startAngle = -pi / 2;
    const sweepTotal = 2 * pi;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweep = sweepTotal * score * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweep, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.score != score;
}

// ─────────────────────────────────────────────────────────────────────────────
// DIFFERENTIAL CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DifferentialCard extends StatefulWidget {
  final DifferentialItem item;
  final Duration delay;

  const _DifferentialCard({required this.item, required this.delay});

  @override
  State<_DifferentialCard> createState() => _DifferentialCardState();
}

class _DifferentialCardState extends State<_DifferentialCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _expanded = !_expanded);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: KxSpacing.md),
            padding: EdgeInsets.all(KxSpacing.lg),
            decoration: BoxDecoration(
              color: KxColors.bgSurface,
              borderRadius: KxSpacing.radiusLg,
              border: Border.all(color: KxColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: KxColors.teal400.withOpacity(0.12),
                        borderRadius: KxSpacing.radiusSm,
                      ),
                      child: Center(
                        child: Text(
                          '#${item.rank}',
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.teal400,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: KxSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.diagnosis,
                            style: KxTypography.headingSm.copyWith(
                              color: KxColors.textPrimary,
                            ),
                          ),
                          if (item.icdCode.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.icdCode,
                              style: KxTypography.monoSm.copyWith(color: KxColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      item.probabilityText,
                      style: KxTypography.labelLg.copyWith(
                        color: _probabilityColor(item.probability),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KxSpacing.md),

                // Probability bar
                ClipRRect(
                  borderRadius: KxSpacing.radiusFull,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: item.probability),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        backgroundColor: KxColors.bgElevated,
                        valueColor: AlwaysStoppedAnimation(
                          _probabilityColor(item.probability),
                        ),
                      );
                    },
                  ),
                ),

                // Expandable details
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: KxSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.reasoning,
                          style: KxTypography.bodyMd.copyWith(
                            color: KxColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        if (item.supportingFindings.isNotEmpty) ...[
                          SizedBox(height: KxSpacing.md),
                          _FindingsList(
                            title: 'Destekleyen Bulgular',
                            items: item.supportingFindings,
                            color: KxColors.jade500,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                        if (item.againstFindings.isNotEmpty) ...[
                          SizedBox(height: KxSpacing.md),
                          _FindingsList(
                            title: 'Aleyhte Bulgular',
                            items: item.againstFindings,
                            color: KxColors.crimson400,
                            icon: Icons.cancel_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState:
                      _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeOutCubic,
                ),

                // Expand indicator
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: KxSpacing.sm),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: KxColors.textDisabled,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _probabilityColor(double p) {
    if (p >= 0.6) return KxColors.jade500;
    if (p >= 0.3) return KxColors.amber500;
    return KxColors.textMuted;
  }
}

class _FindingsList extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;

  const _FindingsList({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: KxTypography.labelSm.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: KxSpacing.xs),
        ...items.map((f) => Padding(
              padding: EdgeInsets.only(bottom: KxSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 14, color: color.withOpacity(0.7)),
                  SizedBox(width: KxSpacing.sm),
                  Expanded(
                    child: Text(
                      f,
                      style: KxTypography.bodySm.copyWith(color: KxColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST PRIORITY GROUP
// ─────────────────────────────────────────────────────────────────────────────

class _TestPriorityGroup extends StatelessWidget {
  final TestPriority priority;
  final List<RecommendedTest> tests;

  const _TestPriorityGroup({required this.priority, required this.tests});

  Color get _accentColor {
    switch (priority) {
      case TestPriority.stat:
        return KxColors.crimson400;
      case TestPriority.urgent:
        return KxColors.amber500;
      case TestPriority.routine:
        return KxColors.teal400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: KxSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: KxSpacing.md, vertical: KxSpacing.xs),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: KxSpacing.radiusSm,
            ),
            child: Text(
              priority.label.toUpperCase(),
              style: KxTypography.labelSm.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: KxSpacing.sm),
          ...tests.map((t) => Container(
                margin: EdgeInsets.only(bottom: KxSpacing.sm),
                padding: EdgeInsets.all(KxSpacing.md),
                decoration: BoxDecoration(
                  color: KxColors.bgSurface,
                  borderRadius: KxSpacing.radiusMd,
                  border: Border(
                    left: BorderSide(color: _accentColor, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: KxTypography.headingSm.copyWith(color: KxColors.textPrimary),
                    ),
                    SizedBox(height: KxSpacing.xs),
                    Text(
                      t.rationale,
                      style: KxTypography.bodySm.copyWith(color: KxColors.textSecondary),
                    ),
                    if (t.expectedFinding.isNotEmpty) ...[
                      SizedBox(height: KxSpacing.xs),
                      Text(
                        'Beklenen: ${t.expectedFinding}',
                        style: KxTypography.bodySm.copyWith(
                          color: KxColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RISK CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RiskCard extends StatelessWidget {
  final RiskFactor risk;

  const _RiskCard({required this.risk});

  Color get _color {
    switch (risk.level) {
      case RiskLevel.critical:
        return KxColors.crimson400;
      case RiskLevel.high:
        return KxColors.crimson500;
      case RiskLevel.moderate:
        return KxColors.amber500;
      case RiskLevel.low:
        return KxColors.jade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(KxSpacing.md),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: KxSpacing.radiusXs,
                ),
                child: Text(
                  risk.level.label.toUpperCase(),
                  style: KxTypography.overline.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: KxSpacing.sm),
          Text(
            risk.factor,
            style: KxTypography.labelMd.copyWith(color: KxColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: KxSpacing.xs),
          Expanded(
            child: Text(
              risk.explanation,
              style: KxTypography.bodySm.copyWith(color: KxColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          height: KxSpacing.touchTarget + 4,
          decoration: BoxDecoration(
            gradient: widget.filled
                ? LinearGradient(
                    colors: [KxColors.teal500, KxColors.teal400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.filled ? null : Colors.transparent,
            borderRadius: KxSpacing.radiusLg,
            border: widget.filled
                ? null
                : Border.all(color: KxColors.borderSubtle),
            boxShadow: widget.filled ? KxShadows.tealGlow() : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.filled ? Colors.white : KxColors.textSecondary,
                ),
                SizedBox(width: KxSpacing.sm),
                Text(
                  widget.label,
                  style: KxTypography.labelLg.copyWith(
                    color: widget.filled ? Colors.white : KxColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final DiagnosisInput? lastInput;

  const _ErrorView({required this.message, this.lastInput});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: KxSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KxColors.crimson400.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: KxColors.crimson400,
                ),
              ),
              SizedBox(height: KxSpacing.xl2),
              Text(
                'Bir Hata Olustu',
                style: KxTypography.displaySm.copyWith(
                  color: KxColors.textPrimary,
                ),
              ),
              SizedBox(height: KxSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: KxTypography.bodyLg.copyWith(
                  color: KxColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Geri Don',
                      icon: Icons.arrow_back_rounded,
                      filled: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<DiagnosisBloc>().add(ClearResultEvent());
                      },
                    ),
                  ),
                  if (lastInput != null) ...[
                    SizedBox(width: KxSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        label: 'Tekrar Dene',
                        icon: Icons.refresh_rounded,
                        filled: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.read<DiagnosisBloc>().add(
                                UpdateInputEvent(lastInput!),
                              );
                          context.read<DiagnosisBloc>().add(AnalyzeEvent());
                        },
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: pad.bottom + KxSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
