import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../domain/entities/emergency_entity.dart';
import '../bloc/emergency_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Emergency Consultation Page
// ─────────────────────────────────────────────────────────────────────────────

class EmergencyConsultationPage extends StatefulWidget {
  const EmergencyConsultationPage({super.key});

  @override
  State<EmergencyConsultationPage> createState() =>
      _EmergencyConsultationPageState();
}

class _EmergencyConsultationPageState extends State<EmergencyConsultationPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fabPulseController;
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    context.read<EmergencyBloc>().add(const LoadConsultationsEvent());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fabPulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: BlocConsumer<EmergencyBloc, EmergencyState>(
        listener: (context, state) {
          if (state is EmergencyLoaded) {
            _staggerController.forward(from: 0);
          }
          if (state is EmergencyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: KxColors.crimson500,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildSliverAppBar(state),
                  if (state is EmergencyLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: _EmergencyLoadingIndicator(),
                      ),
                    )
                  else if (state is EmergencyLoaded) ...[
                    SliverToBoxAdapter(
                      child: _StatsSection(
                        consultations: state.consultations,
                        staggerController: _staggerController,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _ExpertsCarousel(
                        experts: state.availableExperts,
                        staggerController: _staggerController,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: KxSpacing.xl2,
                        right: KxSpacing.xl2,
                        bottom: 120,
                      ),
                      sliver: _ConsultationsList(
                        consultations: state.consultations,
                        staggerController: _staggerController,
                      ),
                    ),
                  ] else if (state is EmergencyInitial)
                    const SliverFillRemaining(
                      child: Center(
                        child: _EmergencyLoadingIndicator(),
                      ),
                    ),
                ],
              ),
              // SOS FAB
              if (state is EmergencyLoaded)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  right: KxSpacing.xl2,
                  child: _SOSButton(
                    controller: _fabPulseController,
                    onTap: () => _showCreateSheet(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(EmergencyState state) {
    final int activeCount = state is EmergencyLoaded
        ? state.consultations.where((c) => !c.isResolved).length
        : 0;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: KxColors.bgBase,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: KxSpacing.xl2,
          bottom: 16,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingRings(controller: _pulseController),
            const SizedBox(width: KxSpacing.sm),
            Text(
              'Acil',
              style: KxTypography.displaySm.copyWith(
                color: KxColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (activeCount > 0) ...[
              const SizedBox(width: KxSpacing.sm),
              _LiveCountBadge(count: activeCount),
            ],
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<EmergencyBloc>().add(const RefreshEvent());
          },
          icon: Icon(
            Icons.refresh_rounded,
            color: KxColors.textSecondary,
          ),
        ),
        const SizedBox(width: KxSpacing.sm),
      ],
    );
  }

  // ── Create Consultation Sheet ───────────────────────────────────────────

  void _showCreateSheet(BuildContext context) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<EmergencyBloc>(),
        child: const _CreateConsultationSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PULSING RINGS — 3 concentric expanding crimson rings
// ═══════════════════════════════════════════════════════════════════════════

class _PulsingRings extends StatelessWidget {
  final AnimationController controller;

  const _PulsingRings({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RingsPainter(controller.value),
            child: child,
          );
        },
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: KxColors.crimson400,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, child);
}

class _RingsPainter extends CustomPainter {
  final double progress;

  _RingsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = ((progress + i * 0.33) % 1.0);
      final radius = maxRadius * 0.3 + maxRadius * 0.7 * ringProgress;
      final opacity = (1.0 - ringProgress).clamp(0.0, 0.6);

      final paint = Paint()
        ..color = KxColors.crimson400.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * (1.0 - ringProgress);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// LIVE COUNT BADGE
// ═══════════════════════════════════════════════════════════════════════════

class _LiveCountBadge extends StatelessWidget {
  final int count;

  const _LiveCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: KxColors.crimson400.withOpacity(0.15),
        borderRadius: KxSpacing.radiusFull,
        border: Border.all(
          color: KxColors.crimson400.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$count aktif',
        style: KxTypography.labelSm.copyWith(
          color: KxColors.crimson400,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOADING INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

class _EmergencyLoadingIndicator extends StatelessWidget {
  const _EmergencyLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: KxColors.crimson400,
          ),
        ),
        const SizedBox(height: KxSpacing.lg),
        Text(
          'Acil konsultasyonlar yukleniyor...',
          style: KxTypography.bodyMd.copyWith(
            color: KxColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATS SECTION — 3 glassmorphism stat cards with animated counts
// ═══════════════════════════════════════════════════════════════════════════

class _StatsSection extends StatelessWidget {
  final List<EmergencyConsultation> consultations;
  final AnimationController staggerController;

  const _StatsSection({
    required this.consultations,
    required this.staggerController,
  });

  @override
  Widget build(BuildContext context) {
    final active = consultations.where((c) => !c.isResolved).length;
    final resolved = consultations.where((c) => c.isResolved).length;
    final critical = consultations
        .where((c) =>
            !c.isResolved &&
            (c.priority == EmergencyPriority.critical ||
                c.priority == EmergencyPriority.lifeThreatening))
        .length;

    final stats = [
      _StatData('Aktif', active, KxColors.crimson400, Icons.local_fire_department_rounded),
      _StatData('Kritik', critical, KxColors.amber500, Icons.warning_rounded),
      _StatData('Cozuldu', resolved, KxColors.jade500, Icons.check_circle_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KxSpacing.xl2,
        vertical: KxSpacing.md,
      ),
      child: Row(
        children: List.generate(stats.length, (index) {
          final interval = Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeOutCubic,
          );
          return Expanded(
            child: AnimatedBuilder(
              animation: staggerController,
              builder: (context, child) {
                final value = interval.transform(staggerController.value);
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < stats.length - 1 ? KxSpacing.sm : 0,
                ),
                child: _GlassStatCard(data: stats[index]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatData(this.label, this.value, this.color, this.icon);
}

class _GlassStatCard extends StatelessWidget {
  final _StatData data;

  const _GlassStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: KxSpacing.radiusLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(KxSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                data.color.withOpacity(0.08),
                data.color.withOpacity(0.03),
              ],
            ),
            borderRadius: KxSpacing.radiusLg,
            border: Border.all(
              color: data.color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: data.color, size: 20),
              const SizedBox(height: KxSpacing.sm),
              _AnimatedCount(
                value: data.value,
                color: data.color,
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: KxTypography.labelSm.copyWith(
                  color: KxColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCount extends StatefulWidget {
  final int value;
  final Color color;

  const _AnimatedCount({required this.value, required this.color});

  @override
  State<_AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<_AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _countAnim = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _countAnim = IntTween(begin: old.value, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
      );
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Text(
          '${_countAnim.value}',
          style: KxTypography.monoLg.copyWith(
            color: widget.color,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXPERTS CAROUSEL — horizontal scrolling expert avatars
// ═══════════════════════════════════════════════════════════════════════════

class _ExpertsCarousel extends StatelessWidget {
  final List<AvailableExpert> experts;
  final AnimationController staggerController;

  const _ExpertsCarousel({
    required this.experts,
    required this.staggerController,
  });

  @override
  Widget build(BuildContext context) {
    if (experts.isEmpty) return const SizedBox.shrink();

    final interval = const Interval(0.25, 0.75, curve: Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: staggerController,
      builder: (context, child) {
        final value = interval.transform(staggerController.value);
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KxSpacing.xl2,
            ),
            child: Row(
              children: [
                Text(
                  'Uygun Uzmanlar',
                  style: KxTypography.headingSm.copyWith(
                    color: KxColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: KxSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: KxColors.jade500.withOpacity(0.12),
                    borderRadius: KxSpacing.radiusFull,
                  ),
                  child: Text(
                    '${experts.where((e) => e.isOnline).length} cevrimici',
                    style: KxTypography.labelSm.copyWith(
                      color: KxColors.jade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KxSpacing.md),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: KxSpacing.xl2,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: experts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: KxSpacing.lg),
              itemBuilder: (context, index) =>
                  _ExpertAvatar(expert: experts[index]),
            ),
          ),
          const SizedBox(height: KxSpacing.xl),
        ],
      ),
    );
  }
}

class _ExpertAvatar extends StatelessWidget {
  final AvailableExpert expert;

  const _ExpertAvatar({required this.expert});

  @override
  Widget build(BuildContext context) {
    final initials = expert.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        KxColors.teal400.withOpacity(0.2),
                        KxColors.blue400.withOpacity(0.15),
                      ],
                    ),
                    border: Border.all(
                      color: expert.isOnline
                          ? KxColors.jade500.withOpacity(0.4)
                          : KxColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: KxTypography.headingSm.copyWith(
                        color: KxColors.teal300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (expert.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _OnlinePulse(),
                  ),
              ],
            ),
            const SizedBox(height: KxSpacing.xs),
            Text(
              expert.name.split(' ').first,
              style: KxTypography.labelSm.copyWith(
                color: KxColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              expert.specialty,
              style: KxTypography.caption.copyWith(
                color: KxColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlinePulse extends StatefulWidget {
  @override
  State<_OnlinePulse> createState() => _OnlinePulseState();
}

class _OnlinePulseState extends State<_OnlinePulse>
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
    return SizedBox(
      width: 16,
      height: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _OnlineDotPainter(_ctrl.value),
          );
        },
      ),
    );
  }
}

class _OnlineDotPainter extends CustomPainter {
  final double progress;

  _OnlineDotPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Pulse ring
    final pulseRadius = 4.0 + 4.0 * progress;
    final pulseOpacity = (1.0 - progress) * 0.4;
    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..color = KxColors.jade500.withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill,
    );

    // Outer ring (bg)
    canvas.drawCircle(
      center,
      5.5,
      Paint()
        ..color = KxColors.bgBase
        ..style = PaintingStyle.fill,
    );

    // Core dot
    canvas.drawCircle(
      center,
      4,
      Paint()
        ..color = KxColors.jade500
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_OnlineDotPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// CONSULTATIONS LIST — staggered entry animation
// ═══════════════════════════════════════════════════════════════════════════

class _ConsultationsList extends StatelessWidget {
  final List<EmergencyConsultation> consultations;
  final AnimationController staggerController;

  const _ConsultationsList({
    required this.consultations,
    required this.staggerController,
  });

  @override
  Widget build(BuildContext context) {
    if (consultations.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyState(),
      );
    }

    // Sort: unresolved first, then by priority severity
    final sorted = List<EmergencyConsultation>.from(consultations)
      ..sort((a, b) {
        if (a.isResolved != b.isResolved) {
          return a.isResolved ? 1 : -1;
        }
        return b.priority.index.compareTo(a.priority.index);
      });

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: KxSpacing.md),
              child: Text(
                'Konsultasyonlar',
                style: KxTypography.headingSm.copyWith(
                  color: KxColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final consultation = sorted[index - 1];
          final staggerIndex = index - 1;
          final interval = Interval(
            (0.35 + staggerIndex * 0.08).clamp(0.0, 0.8),
            (0.7 + staggerIndex * 0.08).clamp(0.5, 1.0),
            curve: Curves.easeOutCubic,
          );

          return AnimatedBuilder(
            animation: staggerController,
            builder: (context, child) {
              final value = interval.transform(staggerController.value);
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: KxSpacing.md),
              child: _ConsultationCard(consultation: consultation),
            ),
          );
        },
        childCount: sorted.length + 1,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KxSpacing.xl6),
      child: Column(
        children: [
          Icon(
            Icons.shield_rounded,
            size: 48,
            color: KxColors.textDisabled,
          ),
          const SizedBox(height: KxSpacing.lg),
          Text(
            'Aktif konsultasyon yok',
            style: KxTypography.headingMd.copyWith(
              color: KxColors.textSecondary,
            ),
          ),
          const SizedBox(height: KxSpacing.xs),
          Text(
            'SOS butonuna basarak acil konsultasyon baslatin',
            style: KxTypography.bodyMd.copyWith(
              color: KxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONSULTATION CARD — priority accent, countdown, swipe to respond
// ═══════════════════════════════════════════════════════════════════════════

class _ConsultationCard extends StatelessWidget {
  final EmergencyConsultation consultation;

  const _ConsultationCard({required this.consultation});

  Color get _priorityColor {
    switch (consultation.priority) {
      case EmergencyPriority.lifeThreatening:
        return KxColors.crimson400;
      case EmergencyPriority.critical:
        return KxColors.amber500;
      case EmergencyPriority.urgent:
        return KxColors.amber300;
    }
  }

  Color get _priorityBg {
    switch (consultation.priority) {
      case EmergencyPriority.lifeThreatening:
        return KxColors.crimson400.withOpacity(0.08);
      case EmergencyPriority.critical:
        return KxColors.amber500.withOpacity(0.08);
      case EmergencyPriority.urgent:
        return KxColors.amber300.withOpacity(0.06);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: consultation.isResolved
            ? KxColors.bgSurface.withOpacity(0.5)
            : KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(
          color: KxColors.borderSubtle,
          width: 1,
        ),
        boxShadow: consultation.isResolved ? null : KxShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: KxSpacing.radiusLg,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: consultation.isResolved
                      ? KxColors.jade500
                      : _priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(KxSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: KxSpacing.sm),
                      _buildTitle(),
                      const SizedBox(height: KxSpacing.sm),
                      _buildPatientVitals(),
                      if (consultation.clinicalSummary.isNotEmpty) ...[
                        const SizedBox(height: KxSpacing.sm),
                        _buildClinicalSummary(),
                      ],
                      if (consultation.responses.isNotEmpty) ...[
                        const SizedBox(height: KxSpacing.md),
                        _buildResponses(context),
                      ],
                    ],
                  ),
                ),
              ),
              // Countdown timer
              if (!consultation.isResolved)
                Padding(
                  padding: const EdgeInsets.only(
                    right: KxSpacing.lg,
                    top: KxSpacing.lg,
                  ),
                  child: _CountdownTimer(consultation: consultation),
                ),
            ],
          ),
        ),
      ),
    );

    // Swipe to respond gesture
    if (consultation.isResolved) return card;

    return Dismissible(
      key: ValueKey(consultation.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        _showRespondDialog(context);
        return false;
      },
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              KxColors.teal400.withOpacity(0.2),
              KxColors.teal400.withOpacity(0.05),
            ],
          ),
          borderRadius: KxSpacing.radiusLg,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: KxSpacing.xl2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reply_rounded, color: KxColors.teal400, size: 22),
            const SizedBox(width: KxSpacing.sm),
            Text(
              'Yanitla',
              style: KxTypography.labelLg.copyWith(
                color: KxColors.teal400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: card,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Priority badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _priorityBg,
            borderRadius: KxSpacing.radiusFull,
            border: Border.all(
              color: _priorityColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                consultation.priority.label,
                style: KxTypography.labelSm.copyWith(
                  color: _priorityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: KxSpacing.sm),
        // Target specialty chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: KxColors.teal400.withOpacity(0.08),
            borderRadius: KxSpacing.radiusSm,
          ),
          child: Text(
            consultation.targetSpecialty,
            style: KxTypography.labelSm.copyWith(
              color: KxColors.teal400,
            ),
          ),
        ),
        const Spacer(),
        // Elapsed time
        Text(
          consultation.elapsedText,
          style: KxTypography.caption.copyWith(
            color: KxColors.textMuted,
          ),
        ),
        if (consultation.isResolved) ...[
          const SizedBox(width: KxSpacing.xs),
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: KxColors.jade500,
          ),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          consultation.title,
          style: KxTypography.headingSm.copyWith(
            color: consultation.isResolved
                ? KxColors.textSecondary
                : KxColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${consultation.requesterName} · ${consultation.requesterSpecialty}',
          style: KxTypography.bodySm.copyWith(
            color: KxColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientVitals() {
    final patient = consultation.patient;
    final vitals = <String>[
      '${patient.age}y ${patient.gender}',
      patient.chiefComplaint,
      ...patient.vitals.entries.map((e) => '${e.key}: ${e.value}'),
    ];

    return Wrap(
      spacing: KxSpacing.xs,
      runSpacing: KxSpacing.xs,
      children: vitals.map((v) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: KxColors.bgHover,
            borderRadius: KxSpacing.radiusSm,
            border: Border.all(
              color: KxColors.borderSubtle,
              width: 0.5,
            ),
          ),
          child: Text(
            v,
            style: KxTypography.monoSm.copyWith(
              color: KxColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClinicalSummary() {
    return Text(
      consultation.clinicalSummary,
      style: KxTypography.bodyMd.copyWith(
        color: KxColors.textSecondary,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildResponses(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 1,
              color: KxColors.borderSubtle,
            ),
            const SizedBox(width: KxSpacing.sm),
            Text(
              '${consultation.responses.length} yanit',
              style: KxTypography.labelSm.copyWith(
                color: KxColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: KxSpacing.sm),
        ...consultation.responses.map((r) => _ResponseTile(
              response: r,
              consultationId: consultation.id,
            )),
      ],
    );
  }

  void _showRespondDialog(BuildContext context) {
    final controller = TextEditingController();
    final actionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(KxSpacing.lg),
          padding: const EdgeInsets.all(KxSpacing.xl2),
          decoration: BoxDecoration(
            color: KxColors.bgSurface,
            borderRadius: KxSpacing.radiusXl,
            border: Border.all(color: KxColors.borderSubtle),
            boxShadow: KxShadows.lg,
          ),
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
                    color: KxColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: KxSpacing.xl),
              Text(
                'Yanit Ver',
                style: KxTypography.headingLg.copyWith(
                  color: KxColors.textPrimary,
                ),
              ),
              Text(
                consultation.title,
                style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textMuted,
                ),
              ),
              const SizedBox(height: KxSpacing.xl),
              TextField(
                controller: controller,
                maxLines: 4,
                style: KxTypography.bodyLg.copyWith(
                  color: KxColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Uzman gorusunuzu yazin...',
                  hintStyle: KxTypography.bodyLg.copyWith(
                    color: KxColors.textDisabled,
                  ),
                  filled: true,
                  fillColor: KxColors.bgHover,
                  border: OutlineInputBorder(
                    borderRadius: KxSpacing.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(KxSpacing.lg),
                ),
              ),
              const SizedBox(height: KxSpacing.md),
              TextField(
                controller: actionController,
                style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Onerilen aksiyon (opsiyonel)',
                  hintStyle: KxTypography.bodyMd.copyWith(
                    color: KxColors.textDisabled,
                  ),
                  filled: true,
                  fillColor: KxColors.bgHover,
                  border: OutlineInputBorder(
                    borderRadius: KxSpacing.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(KxSpacing.lg),
                ),
              ),
              const SizedBox(height: KxSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: KxSpacing.touchTarget,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    HapticFeedback.mediumImpact();
                    context.read<EmergencyBloc>().add(
                          RespondEvent(
                            consultationId: consultation.id,
                            response: ConsultationResponse(
                              id: '',
                              responderId: '',
                              responderName: '',
                              responderSpecialty: '',
                              content: controller.text.trim(),
                              recommendedAction: actionController.text.trim().isEmpty
                                  ? null
                                  : actionController.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          ),
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KxColors.teal400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: KxSpacing.radiusMd,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Yaniti Gonder',
                    style: KxTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Countdown Timer ───────────────────────────────────────────────────────

class _CountdownTimer extends StatelessWidget {
  final EmergencyConsultation consultation;

  const _CountdownTimer({required this.consultation});

  @override
  Widget build(BuildContext context) {
    final targetMinutes = consultation.priority.targetResponseMinutes;
    final elapsed = DateTime.now().difference(consultation.createdAt);
    final elapsedMinutes = elapsed.inMinutes;
    final remaining = max(0, targetMinutes - elapsedMinutes);
    final progress = (elapsedMinutes / targetMinutes).clamp(0.0, 1.0);

    final isOverdue = remaining == 0;
    final color = isOverdue
        ? KxColors.crimson400
        : progress > 0.7
            ? KxColors.amber500
            : KxColors.teal400;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0 - progress,
                strokeWidth: 3,
                backgroundColor: color.withOpacity(0.12),
                color: color,
                strokeCap: StrokeCap.round,
              ),
              Text(
                '${remaining}m',
                style: KxTypography.monoSm.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isOverdue ? 'Gecikme' : 'Kalan',
          style: KxTypography.caption.copyWith(
            color: KxColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// ── Response Tile ─────────────────────────────────────────────────────────

class _ResponseTile extends StatelessWidget {
  final ConsultationResponse response;
  final String consultationId;

  const _ResponseTile({
    required this.response,
    required this.consultationId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: KxSpacing.lg,
        bottom: KxSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(KxSpacing.md),
        decoration: BoxDecoration(
          color: KxColors.bgHover,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: KxColors.borderSubtle,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Small avatar circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KxColors.teal400.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      response.responderName.isNotEmpty
                          ? response.responderName[0].toUpperCase()
                          : '?',
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.teal400,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KxSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.responderName,
                        style: KxTypography.labelSm.copyWith(
                          color: KxColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        response.responderSpecialty,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // XP earned badge
                if (response.xpEarned > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: KxColors.amber500.withOpacity(0.1),
                      borderRadius:
                          KxSpacing.radiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 10, color: KxColors.amber500),
                        const SizedBox(width: 2),
                        Text(
                          '+${response.xpEarned} XP',
                          style: KxTypography.caption.copyWith(
                            color: KxColors.amber500,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: KxSpacing.sm),
            Text(
              response.content,
              style: KxTypography.bodySm.copyWith(
                color: KxColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (response.recommendedAction != null &&
                response.recommendedAction!.isNotEmpty) ...[
              const SizedBox(height: KxSpacing.xs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KxColors.blue400.withOpacity(0.08),
                  borderRadius: KxSpacing.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 12, color: KxColors.blue400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        response.recommendedAction!,
                        style: KxTypography.labelSm.copyWith(
                          color: KxColors.blue400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: KxSpacing.xs),
            Row(
              children: [
                Text(
                  _formatTime(response.createdAt),
                  style: KxTypography.caption.copyWith(
                    color: KxColors.textDisabled,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.read<EmergencyBloc>().add(
                          AcceptResponseEvent(
                            consultationId: consultationId,
                            responseId: response.id,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: KxColors.jade500.withOpacity(0.1),
                      borderRadius:
                          KxSpacing.radiusFull,
                    ),
                    child: Text(
                      'Kabul Et',
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.jade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Az once';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk once';
    return '${diff.inHours}sa once';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOS FAB — pulsing crimson circle with expanding ring animation
// ═══════════════════════════════════════════════════════════════════════════

class _SOSButton extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;

  const _SOSButton({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final scale = 1.0 + 0.06 * sin(controller.value * 2 * pi);
          return SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding rings
                for (int i = 0; i < 3; i++) _buildRing(i),
                // Core button
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEF4444),
                          Color(0xFFDC2626),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: KxColors.crimson400.withOpacity(
                            0.3 + 0.15 * sin(controller.value * 2 * pi),
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRing(int index) {
    final ringProgress = ((controller.value + index * 0.33) % 1.0);
    final ringScale = 1.0 + ringProgress * 0.6;
    final ringOpacity = (1.0 - ringProgress) * 0.3;

    return Transform.scale(
      scale: ringScale,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: KxColors.crimson400.withOpacity(ringOpacity),
            width: 2 * (1.0 - ringProgress),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CREATE CONSULTATION SHEET — 3-step wizard with PageView
// ═══════════════════════════════════════════════════════════════════════════

class _CreateConsultationSheet extends StatefulWidget {
  const _CreateConsultationSheet();

  @override
  State<_CreateConsultationSheet> createState() =>
      _CreateConsultationSheetState();
}

class _CreateConsultationSheetState extends State<_CreateConsultationSheet> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Priority + Specialty
  EmergencyPriority _priority = EmergencyPriority.urgent;
  final _specialtyController = TextEditingController();

  // Step 2: Patient Info
  final _ageController = TextEditingController();
  String _gender = 'Erkek';
  final _complaintController = TextEditingController();
  final _vitalsController = TextEditingController();

  // Step 3: Clinical Details
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _specialtyController.dispose();
    _ageController.dispose();
    _complaintController.dispose();
    _vitalsController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    HapticFeedback.heavyImpact();

    final consultation = EmergencyConsultation(
      id: '',
      requesterId: '',
      requesterName: '',
      requesterSpecialty: '',
      priority: _priority,
      targetSpecialty: _specialtyController.text.trim(),
      title: _titleController.text.trim(),
      clinicalSummary: _summaryController.text.trim(),
      patient: PatientBrief(
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _gender,
        chiefComplaint: _complaintController.text.trim(),
        vitals: _vitalsController.text.trim().isEmpty
            ? const {}
            : {'vitals': _vitalsController.text.trim()},
      ),
      responses: const [],
      createdAt: DateTime.now(),
    );

    context.read<EmergencyBloc>().add(CreateConsultationEvent(consultation));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      margin: const EdgeInsets.only(top: 40),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: KxShadows.lg,
      ),
      child: Column(
        children: [
          // Handle + Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KxSpacing.xl2, KxSpacing.md, KxSpacing.xl2, 0,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: KxColors.textDisabled,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: KxSpacing.xl),
                Row(
                  children: [
                    if (_currentStep > 0)
                      GestureDetector(
                        onTap: _prevStep,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20,
                          color: KxColors.textSecondary,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'Acil Konsultasyon',
                        style: KxTypography.headingLg.copyWith(
                          color: KxColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: _currentStep > 0
                            ? TextAlign.center
                            : TextAlign.left,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: KxColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KxSpacing.lg),
                _StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 3,
                ),
                const SizedBox(height: KxSpacing.sm),
                Text(
                  [
                    'Oncelik & Uzmanlik',
                    'Hasta Bilgileri',
                    'Klinik Detaylar',
                  ][_currentStep],
                  style: KxTypography.bodySm.copyWith(
                    color: KxColors.textMuted,
                  ),
                ),
                const SizedBox(height: KxSpacing.xl),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Next / Submit button
          Padding(
            padding: EdgeInsets.fromLTRB(
              KxSpacing.xl2,
              KxSpacing.md,
              KxSpacing.xl2,
              MediaQuery.of(context).padding.bottom + KxSpacing.lg,
            ),
            child: SizedBox(
              width: double.infinity,
              height: KxSpacing.touchTarget + 8,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 2
                      ? KxColors.crimson400
                      : KxColors.teal400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: KxSpacing.radiusMd,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2 ? 'SOS Gonder' : 'Devam',
                      style: KxTypography.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_currentStep < 2) ...[
                      const SizedBox(width: KxSpacing.sm),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 18, color: Colors.white),
                    ] else ...[
                      const SizedBox(width: KxSpacing.sm),
                      const Icon(Icons.send_rounded,
                          size: 16, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Priority + Specialty ──────────────────────────────────────

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: KxSpacing.xl2),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Oncelik Seviyesi',
          style: KxTypography.headingSm.copyWith(
            color: KxColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: KxSpacing.md),
        ...EmergencyPriority.values.map((p) => _PriorityOption(
              priority: p,
              isSelected: _priority == p,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _priority = p);
              },
            )),
        const SizedBox(height: KxSpacing.xl2),
        Text(
          'Hedef Uzmanlik Alani',
          style: KxTypography.headingSm.copyWith(
            color: KxColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: KxSpacing.md),
        _SheetTextField(
          controller: _specialtyController,
          hint: 'or: Kardiyoloji, Noroloji',
          icon: Icons.medical_services_outlined,
        ),
      ],
    );
  }

  // ── Step 2: Patient Info ──────────────────────────────────────────────

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: KxSpacing.xl2),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yas',
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: KxSpacing.sm),
                  _SheetTextField(
                    controller: _ageController,
                    hint: '45',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: KxSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cinsiyet',
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: KxSpacing.sm),
                  _GenderSelector(
                    selected: _gender,
                    onChanged: (g) => setState(() => _gender = g),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KxSpacing.xl),
        Text(
          'Bas Sikayet',
          style: KxTypography.labelMd.copyWith(
            color: KxColors.textSecondary,
          ),
        ),
        const SizedBox(height: KxSpacing.sm),
        _SheetTextField(
          controller: _complaintController,
          hint: 'Gogus agrisi, nefes darligi...',
          icon: Icons.report_problem_outlined,
        ),
        const SizedBox(height: KxSpacing.xl),
        Text(
          'Vital Bulgular',
          style: KxTypography.labelMd.copyWith(
            color: KxColors.textSecondary,
          ),
        ),
        const SizedBox(height: KxSpacing.sm),
        _SheetTextField(
          controller: _vitalsController,
          hint: 'TA: 130/85, Nb: 110, SpO2: 94%',
          icon: Icons.monitor_heart_outlined,
        ),
      ],
    );
  }

  // ── Step 3: Clinical Details ──────────────────────────────────────────

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: KxSpacing.xl2),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Konsultasyon Basligi',
          style: KxTypography.labelMd.copyWith(
            color: KxColors.textSecondary,
          ),
        ),
        const SizedBox(height: KxSpacing.sm),
        _SheetTextField(
          controller: _titleController,
          hint: 'Kisa ve aciklayici baslik',
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: KxSpacing.xl),
        Text(
          'Klinik Ozet',
          style: KxTypography.labelMd.copyWith(
            color: KxColors.textSecondary,
          ),
        ),
        const SizedBox(height: KxSpacing.sm),
        _SheetTextField(
          controller: _summaryController,
          hint:
              'Hastanin oykusu, muayene bulgulari, yapilan tetkikler ve mevcut tedaviyi ozetleyin...',
          maxLines: 6,
        ),
      ],
    );
  }
}

// ── Step Indicator Dots ───────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isPast = index < currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? KxColors.teal400
                : isPast
                    ? KxColors.teal400.withOpacity(0.4)
                    : KxColors.textDisabled.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Priority Option ───────────────────────────────────────────────────────

class _PriorityOption extends StatelessWidget {
  final EmergencyPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (priority) {
      case EmergencyPriority.urgent:
        return KxColors.amber500;
      case EmergencyPriority.critical:
        return KxColors.amber300;
      case EmergencyPriority.lifeThreatening:
        return KxColors.crimson400;
    }
  }

  IconData get _icon {
    switch (priority) {
      case EmergencyPriority.urgent:
        return Icons.warning_amber_rounded;
      case EmergencyPriority.critical:
        return Icons.error_outline_rounded;
      case EmergencyPriority.lifeThreatening:
        return Icons.local_fire_department_rounded;
    }
  }

  String get _subtitle {
    return '${priority.targetResponseMinutes} dk hedef yanit suresi';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: KxSpacing.sm),
        padding: const EdgeInsets.all(KxSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.08) : KxColors.bgHover,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color:
                isSelected ? _color.withOpacity(0.4) : KxColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon, color: _color, size: 22),
            const SizedBox(width: KxSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priority.label,
                    style: KxTypography.labelLg.copyWith(
                      color: isSelected ? _color : KxColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _subtitle,
                    style: KxTypography.caption.copyWith(
                      color: KxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _color : KxColors.textDisabled,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gender Selector ───────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Erkek', 'Kadin'].map((g) {
        final isSelected = selected == g;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(g);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: g == 'Erkek' ? 4 : 0,
                left: g == 'Kadin' ? 4 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: KxSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? KxColors.teal400.withOpacity(0.1)
                    : KxColors.bgHover,
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(
                  color: isSelected
                      ? KxColors.teal400.withOpacity(0.3)
                      : KxColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  g,
                  style: KxTypography.labelMd.copyWith(
                    color: isSelected
                        ? KxColors.teal400
                        : KxColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sheet Text Field ──────────────────────────────────────────────────────

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType keyboardType;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: KxTypography.bodyLg.copyWith(
        color: KxColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: KxTypography.bodyLg.copyWith(
          color: KxColors.textDisabled,
        ),
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(icon, size: 20, color: KxColors.textMuted),
              )
            : null,
        prefixIconConstraints: icon != null
            ? const BoxConstraints(minWidth: 40, minHeight: 40)
            : null,
        filled: true,
        fillColor: KxColors.bgHover,
        border: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: BorderSide(
            color: KxColors.teal400.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KxSpacing.lg,
          vertical: KxSpacing.md,
        ),
      ),
    );
  }
}
