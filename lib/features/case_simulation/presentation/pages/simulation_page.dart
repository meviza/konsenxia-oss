import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/entities/simulation_entity.dart';
import '../bloc/simulation_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SIMULATION PAGE — Root
// ─────────────────────────────────────────────────────────────────────────────

class SimulationPage extends StatelessWidget {
  const SimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: BlocBuilder<SimulationBloc, SimulationState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: _buildView(context, state),
          );
        },
      ),
    );
  }

  Widget _buildView(BuildContext context, SimulationState state) {
    if (state is ScenariosLoading) {
      return const _LoadingView(key: ValueKey('loading'));
    }
    if (state is ScenariosLoaded) {
      return _ScenarioSelectionView(
        key: const ValueKey('scenarios'),
        scenarios: state.scenarios,
      );
    }
    if (state is SimulationActive) {
      return _ActiveSimulationView(
        key: const ValueKey('active'),
        simulation: state.simulation,
        isAiTyping: state.isAiTyping,
      );
    }
    if (state is SimulationCompleted) {
      return _CompletionView(
        key: const ValueKey('completed'),
        simulation: state.simulation,
        score: state.score,
      );
    }
    if (state is SimulationError) {
      return _ErrorView(key: const ValueKey('error'), message: state.message);
    }
    // SimulationInitial — trigger load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulationBloc>().add(LoadScenariosEvent());
    });
    return const _LoadingView(key: ValueKey('initial'));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: KxColors.teal400,
            ),
          ),
          const SizedBox(height: KxSpacing.lg),
          Text(
            'Loading scenarios...',
            style: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KxSpacing.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KxColors.crimson400.withOpacity(0.12),
              ),
              child: Icon(Icons.warning_rounded,
                  color: KxColors.crimson400, size: 28),
            ),
            const SizedBox(height: KxSpacing.xl),
            Text(
              'Something went wrong',
              style: KxTypography.headingLg
                  .copyWith(color: KxColors.textPrimary),
            ),
            const SizedBox(height: KxSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
            ),
            const SizedBox(height: KxSpacing.xl3),
            GestureDetector(
              onTap: () =>
                  context.read<SimulationBloc>().add(LoadScenariosEvent()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KxSpacing.xl2,
                  vertical: KxSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: KxColors.teal400,
                  borderRadius: KxSpacing.radiusLg,
                ),
                child: Text(
                  'Try Again',
                  style:
                      KxTypography.labelLg.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENARIO SELECTION VIEW — Swipeable PageView cards with parallax
// ─────────────────────────────────────────────────────────────────────────────

class _ScenarioSelectionView extends StatefulWidget {
  final List<SimulationEntity> scenarios;
  const _ScenarioSelectionView({super.key, required this.scenarios});

  @override
  State<_ScenarioSelectionView> createState() =>
      _ScenarioSelectionViewState();
}

class _ScenarioSelectionViewState extends State<_ScenarioSelectionView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _staggerController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88)
      ..addListener(() {
        setState(() => _currentPage = _pageController.page ?? 0);
      });
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topPad + KxSpacing.xl2),
        // Header
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _staggerController,
              curve: const Interval(0, 0.5, curve: Curves.easeOut),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: KxSpacing.xl2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case Simulation',
                    style: KxTypography.displaySm.copyWith(
                      color: KxColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: KxSpacing.xs),
                  Text(
                    'Choose a clinical scenario to begin',
                    style: KxTypography.bodyLg.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: KxSpacing.xl4),
        // Scenario cards
        Expanded(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve:
                  const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
            )),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _staggerController,
                curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.scenarios.length,
                itemBuilder: (context, index) {
                  final scenario = widget.scenarios[index];
                  final delta =
                      (index - _currentPage).abs().clamp(0.0, 1.0);
                  final parallaxOffset = (index - _currentPage) * 24.0;

                  return Transform.translate(
                    offset: Offset(0, delta * 20),
                    child: Opacity(
                      opacity: (1 - delta * 0.3).clamp(0.0, 1.0),
                      child: _ScenarioCard(
                        scenario: scenario,
                        parallaxOffset: parallaxOffset,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context
                              .read<SimulationBloc>()
                              .add(StartSimulationEvent(scenario.id));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Page indicator
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.5, 1, curve: Curves.easeOut),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).padding.bottom + KxSpacing.xl2,
              top: KxSpacing.xl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  List.generate(widget.scenarios.length, (i) {
                final isActive = i == _currentPage.round();
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isActive
                        ? KxColors.teal400
                        : KxColors.textMuted.withOpacity(0.25),
                    boxShadow:
                        isActive ? KxShadows.tealGlow() : null,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Scenario Card ──

class _ScenarioCard extends StatelessWidget {
  final SimulationEntity scenario;
  final double parallaxOffset;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.parallaxOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: KxSpacing.sm,
          vertical: KxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: KxSpacing.radiusXl,
          border:
              Border.all(color: KxColors.borderSubtle, width: 0.5),
          boxShadow: KxShadows.lg,
        ),
        child: ClipRRect(
          borderRadius: KxSpacing.radiusXl,
          child: Stack(
            children: [
              // Background gradient accent
              Positioned(
                top: -60 + parallaxOffset * 0.5,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        KxColors.teal400.withOpacity(0.08),
                        KxColors.teal400.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              // Secondary accent
              Positioned(
                bottom: -80 + parallaxOffset * 0.3,
                left: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        KxColors.blue400.withOpacity(0.05),
                        KxColors.blue400.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(KxSpacing.xl2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialty badge
                    Transform.translate(
                      offset: Offset(parallaxOffset * 0.2, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KxSpacing.md,
                          vertical: KxSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.12),
                          borderRadius: KxSpacing.radiusFull,
                          boxShadow: KxShadows.tealGlow(),
                        ),
                        child: Text(
                          scenario.specialty,
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.teal300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: KxSpacing.xl),
                    // Title
                    Transform.translate(
                      offset: Offset(parallaxOffset * 0.35, 0),
                      child: Text(
                        scenario.scenarioTitle,
                        style: KxTypography.displaySm.copyWith(
                          color: KxColors.textPrimary,
                          height: 1.15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: KxSpacing.md),
                    // Description
                    Transform.translate(
                      offset: Offset(parallaxOffset * 0.15, 0),
                      child: Text(
                        scenario.scenarioDescription,
                        style: KxTypography.bodyMd.copyWith(
                          color: KxColors.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // Bottom row: difficulty + start button
                    Row(
                      children: [
                        _DifficultyIndicator(
                            difficulty: scenario.difficulty),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KxSpacing.xl,
                            vertical: KxSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: KxColors.teal400,
                            borderRadius: KxSpacing.radiusFull,
                            boxShadow: KxShadows.tealGlow(),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Begin',
                                style: KxTypography.labelLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: KxSpacing.sm),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Difficulty Indicator ──

class _DifficultyIndicator extends StatelessWidget {
  final SimulationDifficulty difficulty;
  const _DifficultyIndicator({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final level = difficulty.index + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          difficulty.label.toUpperCase(),
          style: KxTypography.overline.copyWith(
            color: KxColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: KxSpacing.xs),
        Row(
          children: List.generate(3, (i) {
            final active = i < level;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 20,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: active
                    ? (level == 3
                        ? KxColors.crimson400
                        : level == 2
                            ? KxColors.amber500
                            : KxColors.jade500)
                    : KxColors.textMuted.withOpacity(0.15),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE SIMULATION VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveSimulationView extends StatefulWidget {
  final SimulationEntity simulation;
  final bool isAiTyping;

  const _ActiveSimulationView({
    super.key,
    required this.simulation,
    required this.isAiTyping,
  });

  @override
  State<_ActiveSimulationView> createState() =>
      _ActiveSimulationViewState();
}

class _ActiveSimulationViewState extends State<_ActiveSimulationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _patientInfoExpanded = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ActiveSimulationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.simulation.messages.length !=
        oldWidget.simulation.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<SimulationBloc>().add(SendMessageEvent(text));
    _messageController.clear();
  }

  void _showDiagnosisSheet() {
    HapticFeedback.mediumImpact();
    final diagnosisController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DiagnosisBottomSheet(
        controller: diagnosisController,
        onSubmit: (diagnosis) {
          HapticFeedback.mediumImpact();
          context
              .read<SimulationBloc>()
              .add(SubmitDiagnosisEvent(diagnosis: diagnosis, treatmentPlan: ''));
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final simulation = widget.simulation;
    final phase = simulation.currentPhase;

    return Column(
      children: [
        SizedBox(height: topPad),
        // ── Top bar ──
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KxSpacing.lg,
            vertical: KxSpacing.sm,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<SimulationBloc>()
                      .add(BackToScenariosEvent());
                },
                child: Container(
                  width: KxSpacing.touchTarget,
                  height: KxSpacing.touchTarget,
                  decoration: BoxDecoration(
                    color: KxColors.bgSurface,
                    borderRadius:
                        KxSpacing.radiusMd,
                    border: Border.all(
                        color: KxColors.borderSubtle, width: 0.5),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: KxColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: KxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      simulation.scenarioTitle,
                      style: KxTypography.headingSm.copyWith(
                        color: KxColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phase.label,
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.teal400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Phase stepper ──
        _PhaseStepper(currentPhase: phase),

        // ── Patient info collapsible ──
        _CollapsiblePatientInfo(
            patient: simulation.patient,
            expanded: _patientInfoExpanded,
            onToggle: () => setState(
                () => _patientInfoExpanded = !_patientInfoExpanded),
          ),

        // ── Chat area ──
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: KxSpacing.lg,
              vertical: KxSpacing.sm,
            ),
            itemCount: simulation.messages.length +
                (widget.isAiTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == simulation.messages.length &&
                  widget.isAiTyping) {
                return const _TypingIndicator();
              }
              return _ChatBubble(
                message: simulation.messages[index],
                index: index,
              );
            },
          ),
        ),

        // ── Test ordering chips (during tests phase) ──
        if (phase == SimulationPhase.tests)
          _TestOrderChips(
            availableTests: const ['Tam Kan Sayimi', 'EKG', 'Akciğer Grafisi', 'BT', 'MR', 'Kan Biyokimyasi', 'İdrar Tahlili', 'Troponin', 'D-Dimer', 'Kan Gazı'],
            onOrderTest: (test) {
              HapticFeedback.lightImpact();
              context
                  .read<SimulationBloc>()
                  .add(OrderTestEvent(test));
            },
          ),

        // ── Input bar ──
        _InputBar(
          controller: _messageController,
          phase: phase,
          onSend: _sendMessage,
          onAdvancePhase: () {
            HapticFeedback.lightImpact();
            context.read<SimulationBloc>().add(AdvancePhaseEvent());
          },
          onDiagnosis: _showDiagnosisSheet,
          bottomPadding: bottomPad,
        ),
      ],
    );
  }
}

// ── Phase Stepper ──

class _PhaseStepper extends StatelessWidget {
  final SimulationPhase currentPhase;
  const _PhaseStepper({required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final phases = SimulationPhase.values
        .where((p) => p != SimulationPhase.completed)
        .toList();

    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: KxSpacing.lg),
      child: Row(
        children: List.generate(phases.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final phaseIdx = i ~/ 2;
            final isCompleted =
                phases[phaseIdx].index < currentPhase.index;
            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: isCompleted
                      ? KxColors.teal400.withOpacity(0.5)
                      : KxColors.borderSubtle,
                ),
              ),
            );
          }
          final phaseIdx = i ~/ 2;
          final p = phases[phaseIdx];
          final isActive = p == currentPhase;
          final isCompleted = p.index < currentPhase.index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: isActive ? 36 : 28,
            height: isActive ? 36 : 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? KxColors.teal400
                  : isCompleted
                      ? KxColors.teal400.withOpacity(0.2)
                      : KxColors.bgSurface,
              border: Border.all(
                color: isActive
                    ? KxColors.teal400
                    : isCompleted
                        ? KxColors.teal400.withOpacity(0.4)
                        : KxColors.borderSubtle,
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive ? KxShadows.tealGlow() : null,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: KxColors.teal400,
                    )
                  : Text(
                      '${phaseIdx + 1}',
                      style: KxTypography.labelSm.copyWith(
                        color: isActive
                            ? Colors.white
                            : KxColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Collapsible Patient Info ──

class _CollapsiblePatientInfo extends StatelessWidget {
  final PatientProfile patient;
  final bool expanded;
  final VoidCallback onToggle;

  const _CollapsiblePatientInfo({
    required this.patient,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(
          horizontal: KxSpacing.lg,
          vertical: KxSpacing.xs,
        ),
        padding:
            EdgeInsets.all(expanded ? KxSpacing.lg : KxSpacing.md),
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: KxSpacing.radiusLg,
          border:
              Border.all(color: KxColors.borderSubtle, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KxColors.blue400.withOpacity(0.12),
                  ),
                  child: Icon(Icons.person_rounded,
                      size: 16, color: KxColors.blue400),
                ),
                const SizedBox(width: KxSpacing.sm),
                Expanded(
                  child: Text(
                    '${patient.age}y ${patient.gender}',
                    style: KxTypography.headingSm.copyWith(
                      color: KxColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: KxColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: KxSpacing.md),
                child: Wrap(
                  spacing: KxSpacing.sm,
                  runSpacing: KxSpacing.sm,
                  children: [
                    _VitalBadge(
                        label: 'Chief',
                        value: patient.chiefComplaint,
                        color: KxColors.crimson400,
                      ),
                    ...patient.vitals.entries.map(
                      (v) => _VitalBadge(
                        label: v.key,
                        value: v.value,
                        color: KxColors.teal400,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _VitalBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KxSpacing.sm,
        vertical: KxSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: KxSpacing.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: KxTypography.labelSm.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: KxTypography.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ──

class _ChatBubble extends StatefulWidget {
  final SimulationMessage message;
  final int index;
  const _ChatBubble({required this.message, required this.index});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final isDoctor = msg.role == SimulationMessageRole.doctor;
    final isSystem = msg.role == SimulationMessageRole.system;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: KxSpacing.md),
          child: isSystem
              ? _buildSystemMessage(msg)
              : _buildChatMessage(msg, isDoctor),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(SimulationMessage msg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: KxSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: KxSpacing.lg,
          vertical: KxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: KxColors.amber500.withOpacity(0.08),
          borderRadius:
              KxSpacing.radiusFull,
          border: Border.all(
            color: KxColors.amber500.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Text(
          msg.content,
          textAlign: TextAlign.center,
          style: KxTypography.labelSm
              .copyWith(color: KxColors.amber300),
        ),
      ),
    );
  }

  Widget _buildChatMessage(SimulationMessage msg, bool isDoctor) {
    return Align(
      alignment:
          isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KxSpacing.lg,
          vertical: KxSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDoctor ? KxColors.teal400 : KxColors.bgElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isDoctor ? 18 : 4),
            bottomRight: Radius.circular(isDoctor ? 4 : 18),
          ),
          boxShadow: KxShadows.sm,
        ),
        child: Text(
          msg.content,
          style: KxTypography.bodyMd.copyWith(
            color: isDoctor ? Colors.white : KxColors.textPrimary,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

// ── Typing Indicator with 3 bouncing dots ──

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: KxSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: KxSpacing.xl,
          vertical: KxSpacing.md,
        ),
        decoration: BoxDecoration(
          color: KxColors.bgElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: KxShadows.sm,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t =
                    ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
                final bounce = sin(t * pi);
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Transform.translate(
                    offset: Offset(0, -bounce * 4),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KxColors.textMuted
                            .withOpacity(0.3 + bounce * 0.4),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ── Test Order Chips ──

class _TestOrderChips extends StatelessWidget {
  final List<String> availableTests;
  final ValueChanged<String> onOrderTest;

  const _TestOrderChips({
    required this.availableTests,
    required this.onOrderTest,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTests.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: KxSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: KxSpacing.lg),
        itemCount: availableTests.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: KxSpacing.sm),
        itemBuilder: (context, index) {
          final test = availableTests[index];
          return GestureDetector(
            onTap: () => onOrderTest(test),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KxSpacing.lg,
                vertical: KxSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: KxColors.blue400.withOpacity(0.1),
                borderRadius:
                    KxSpacing.radiusFull,
                border: Border.all(
                  color: KxColors.blue400.withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.science_rounded,
                    size: 14,
                    color: KxColors.blue300,
                  ),
                  const SizedBox(width: KxSpacing.xs),
                  Text(
                    test,
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.blue300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Input Bar ──

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final SimulationPhase phase;
  final VoidCallback onSend;
  final VoidCallback onAdvancePhase;
  final VoidCallback onDiagnosis;
  final double bottomPadding;

  const _InputBar({
    required this.controller,
    required this.phase,
    required this.onSend,
    required this.onAdvancePhase,
    required this.onDiagnosis,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: KxSpacing.lg,
        right: KxSpacing.lg,
        top: KxSpacing.md,
        bottom: bottomPadding + KxSpacing.md,
      ),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(
          top: BorderSide(color: KxColors.borderSubtle, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Action button based on phase
          if (phase == SimulationPhase.diagnosis)
            _ActionButton(
              icon: Icons.medical_information_rounded,
              label: 'Diagnose',
              color: KxColors.amber500,
              onTap: onDiagnosis,
            )
          else if (!phase.isLast)
            _ActionButton(
              icon: Icons.skip_next_rounded,
              label: 'Next',
              color: KxColors.teal400,
              onTap: onAdvancePhase,
            ),
          if (phase == SimulationPhase.diagnosis || !phase.isLast)
            const SizedBox(width: KxSpacing.sm),
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: KxColors.bgBase,
                borderRadius:
                    KxSpacing.radiusXl,
                border: Border.all(
                    color: KxColors.borderSubtle, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: KxTypography.bodyMd.copyWith(
                        color: KxColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask the patient...',
                        hintStyle: KxTypography.bodyMd.copyWith(
                          color: KxColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: KxSpacing.lg,
                          vertical: KxSpacing.md,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KxColors.teal400,
                        boxShadow: KxShadows.tealGlow(),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KxSpacing.md,
          vertical: KxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius:
              KxSpacing.radiusFull,
          border: Border.all(
              color: color.withOpacity(0.25), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: KxSpacing.xs),
            Text(
              label,
              style: KxTypography.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Diagnosis Bottom Sheet ──

class _DiagnosisBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  const _DiagnosisBottomSheet({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: KxShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(KxSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KxColors.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KxSpacing.xl2),
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KxColors.amber500.withOpacity(0.12),
                    boxShadow: KxShadows.amberGlow(),
                  ),
                  child: Icon(
                    Icons.medical_information_rounded,
                    color: KxColors.amber500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: KxSpacing.md),
                Text(
                  'Submit Diagnosis',
                  style: KxTypography.headingLg.copyWith(
                    color: KxColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KxSpacing.xs),
            Text(
              'Based on your findings, what is your clinical diagnosis?',
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textSecondary,
              ),
            ),
            const SizedBox(height: KxSpacing.xl),
            // Input
            Container(
              decoration: BoxDecoration(
                color: KxColors.bgBase,
                borderRadius:
                    KxSpacing.radiusLg,
                border: Border.all(
                    color: KxColors.borderSubtle, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                style: KxTypography.bodyLg.copyWith(
                  color: KxColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your diagnosis...',
                  hintStyle: KxTypography.bodyLg.copyWith(
                    color: KxColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.all(KxSpacing.lg),
                ),
              ),
            ),
            const SizedBox(height: KxSpacing.xl),
            // Submit button
            GestureDetector(
              onTap: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) onSubmit(text);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: KxSpacing.lg),
                decoration: BoxDecoration(
                  color: KxColors.teal400,
                  borderRadius:
                      KxSpacing.radiusLg,
                  boxShadow: KxShadows.tealGlow(),
                ),
                child: Center(
                  child: Text(
                    'Submit Diagnosis',
                    style: KxTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETION VIEW — Score gauge, grade, breakdown, XP celebration
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionView extends StatefulWidget {
  final SimulationEntity simulation;
  final SimulationScore score;

  const _CompletionView({
    super.key,
    required this.simulation,
    required this.score,
  });

  @override
  State<_CompletionView> createState() => _CompletionViewState();
}

class _CompletionViewState extends State<_CompletionView>
    with TickerProviderStateMixin {
  late final AnimationController _gaugeController;
  late final AnimationController _contentController;
  late final AnimationController _shimmerController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _gaugeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _contentController.forward();
    });

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final score = widget.score;

    return Stack(
      children: [
        // Subtle particle effect behind content
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ParticlePainter(
                progress: _particleController.value,
                color: KxColors.teal400,
                secondaryColor: KxColors.amber500,
              ),
            );
          },
        ),
        // Main content
        SingleChildScrollView(
          padding: EdgeInsets.only(
            top: topPad + KxSpacing.xl2,
            bottom: bottomPad + KxSpacing.xl4,
            left: KxSpacing.xl2,
            right: KxSpacing.xl2,
          ),
          child: Column(
            children: [
              // Title
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _gaugeController,
                  curve: const Interval(0, 0.3, curve: Curves.easeOut),
                ),
                child: Text(
                  'Simulation Complete',
                  style: KxTypography.displaySm.copyWith(
                    color: KxColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: KxSpacing.sm),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _gaugeController,
                  curve: const Interval(0.1, 0.4,
                      curve: Curves.easeOut),
                ),
                child: Text(
                  widget.simulation.scenarioTitle,
                  textAlign: TextAlign.center,
                  style: KxTypography.bodyMd.copyWith(
                    color: KxColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: KxSpacing.xl5),

              // ── Radial Score Gauge ──
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _gaugeController,
                  builder: (context, _) {
                    final springValue = Curves.elasticOut.transform(
                        _gaugeController.value.clamp(0.0, 1.0));
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: _ScoreGaugePainter(
                            progress: springValue *
                                score.percentage /
                                100,
                            trackColor: KxColors.borderSubtle,
                            progressColor:
                                _gradeColor(score.grade),
                            glowColor: _gradeColor(score.grade)
                                .withOpacity(0.3),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.5 + springValue * 0.5,
                              child: Opacity(
                                opacity: _gaugeController.value
                                    .clamp(0.0, 1.0),
                                child: Text(
                                  score.grade,
                                  style: KxTypography.displayLg
                                      .copyWith(
                                    color: _gradeColor(
                                        score.grade),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 56,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${(springValue * score.percentage).toInt()}%',
                              style:
                                  KxTypography.headingMd.copyWith(
                                color: KxColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${score.totalPoints}/${score.maxPoints} pts',
                              style:
                                  KxTypography.labelSm.copyWith(
                                color: KxColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: KxSpacing.xl5),

              // ── XP Earned with shimmer ──
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _contentController,
                  curve: const Interval(0, 0.3, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _contentController,
                    curve: const Interval(0, 0.4,
                        curve: Curves.easeOutCubic),
                  )),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KxSpacing.xl2,
                          vertical: KxSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              KxColors.amber500.withOpacity(0.08),
                              KxColors.amber500.withOpacity(0.15),
                              KxColors.amber500.withOpacity(0.08),
                            ],
                            stops: [
                              0.0,
                              (0.3 +
                                      _shimmerController.value *
                                          0.4)
                                  .clamp(0.0, 1.0),
                              1.0,
                            ],
                          ),
                          borderRadius: KxSpacing.radiusLg,
                          border: Border.all(
                            color:
                                KxColors.amber500.withOpacity(0.2),
                            width: 0.5,
                          ),
                          boxShadow: KxShadows.amberGlow(),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rounded,
                                color: KxColors.amber500,
                                size: 24),
                            const SizedBox(width: KxSpacing.sm),
                            Text(
                              '+${score.xpEarned} XP',
                              style:
                                  KxTypography.headingLg.copyWith(
                                color: KxColors.amber300,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: KxSpacing.xl3),

              // ── Score Breakdown ──
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _contentController,
                  curve: const Interval(0.2, 0.6,
                      curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _contentController,
                    curve: const Interval(0.2, 0.6,
                        curve: Curves.easeOutCubic),
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(KxSpacing.xl),
                    decoration: BoxDecoration(
                      color: KxColors.bgSurface,
                      borderRadius: KxSpacing.radiusLg,
                      border: Border.all(
                          color: KxColors.borderSubtle,
                          width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCORE BREAKDOWN',
                          style: KxTypography.overline.copyWith(
                            color: KxColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: KxSpacing.xl),
                        _ScoreBar(
                          label: 'Anamnesis',
                          score: score.anamnesisScore,
                          color: KxColors.teal400,
                          controller: _contentController,
                          delayStart: 0.3,
                        ),
                        const SizedBox(height: KxSpacing.lg),
                        _ScoreBar(
                          label: 'Examination',
                          score: score.examinationScore,
                          color: KxColors.blue400,
                          controller: _contentController,
                          delayStart: 0.4,
                        ),
                        const SizedBox(height: KxSpacing.lg),
                        _ScoreBar(
                          label: 'Tests',
                          score: score.testScore,
                          color: KxColors.jade500,
                          controller: _contentController,
                          delayStart: 0.5,
                        ),
                        const SizedBox(height: KxSpacing.lg),
                        _ScoreBar(
                          label: 'Diagnosis',
                          score: score.diagnosisScore,
                          color: KxColors.amber500,
                          controller: _contentController,
                          delayStart: 0.6,
                        ),
                        const SizedBox(height: KxSpacing.lg),
                        _ScoreBar(
                          label: 'Treatment',
                          score: score.treatmentScore,
                          color: KxColors.crimson400,
                          controller: _contentController,
                          delayStart: 0.7,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KxSpacing.xl3),

              // ── Feedback ──
              if (score.feedback.isNotEmpty)
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _contentController,
                    curve: const Interval(0.5, 1,
                        curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _contentController,
                      curve: const Interval(0.5, 1,
                          curve: Curves.easeOutCubic),
                    )),
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(KxSpacing.xl),
                      decoration: BoxDecoration(
                        color: KxColors.bgSurface,
                        borderRadius: KxSpacing.radiusLg,
                        border: Border.all(
                            color: KxColors.borderSubtle,
                            width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FEEDBACK',
                            style:
                                KxTypography.overline.copyWith(
                              color: KxColors.textMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: KxSpacing.md),
                          Text(
                            score.feedback,
                            style: KxTypography.bodyMd
                                .copyWith(
                              color: KxColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: KxSpacing.xl3),

              // ── Back button ──
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _contentController,
                  curve: const Interval(0.7, 1,
                      curve: Curves.easeOut),
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context
                        .read<SimulationBloc>()
                        .add(BackToScenariosEvent());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: KxSpacing.lg),
                    decoration: BoxDecoration(
                      color: KxColors.bgSurface,
                      borderRadius: KxSpacing.radiusLg,
                      border: Border.all(
                          color: KxColors.borderSubtle,
                          width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        'Back to Scenarios',
                        style: KxTypography.labelLg.copyWith(
                          color: KxColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return KxColors.teal400;
      case 'B+':
      case 'B':
        return KxColors.blue400;
      case 'C+':
      case 'C':
        return KxColors.amber500;
      default:
        return KxColors.crimson400;
    }
  }
}

// ── Score Bar (animated horizontal) ──

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final AnimationController controller;
  final double delayStart;

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.color,
    required this.controller,
    required this.delayStart,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delayStart + 0.3).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Interval(delayStart, end,
                curve: Curves.easeOutCubic)
            .transform(controller.value);
        final normalizedScore =
            score.toDouble().clamp(0.0, 100.0) / 100.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: KxTypography.labelMd.copyWith(
                    color: KxColors.textSecondary,
                  ),
                ),
                Text(
                  '${(t * score).toInt()}%',
                  style: KxTypography.monoSm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KxSpacing.xs),
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color.withOpacity(0.1),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor:
                      (t * normalizedScore).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(3),
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Score Gauge CustomPainter ──

class _ScoreGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  _ScoreGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 8.0;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Glow
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ── Particle Effect Painter ──

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color secondaryColor;

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // Deterministic seed for stable particles

    for (int i = 0; i < 20; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble();
      final useSecondary = rng.nextBool();

      final t = ((progress * speed + phase) % 1.0);
      final y = baseY - t * size.height * 0.3;
      final x = baseX + sin(t * pi * 2) * 15;
      final opacity = sin(t * pi) * 0.12;
      final radius = 1.5 + rng.nextDouble() * 2;

      if (opacity > 0.01) {
        final paint = Paint()
          ..color = (useSecondary ? secondaryColor : color)
              .withOpacity(opacity.clamp(0.0, 1.0));

        canvas.drawCircle(
          Offset(x % size.width, y % size.height),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
