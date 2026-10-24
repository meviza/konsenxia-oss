import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Atom — KxProgressBar
///
/// XP ilerleme çubuğu ve genel progress göstergesi.
/// Animasyonlu dolum, level bilgisi ve renk temaları.
///
/// Kullanım:
/// ```dart
/// KxProgressBar(value: 0.81)
/// KxProgressBar.xp(
///   current: 2847,
///   total: 3500,
///   level: 8,
///   levelName: 'Uzman Klinisyen',
/// )
/// KxProgressBar.thin(value: 0.6)
/// ```
enum KxProgressVariant { teal, amber, blue, crimson, jade }

class KxProgressBar extends StatefulWidget {
  final double value;       // 0.0 — 1.0
  final KxProgressVariant variant;
  final double height;
  final bool animate;
  final bool showLabel;
  final String? label;

  const KxProgressBar({
    super.key,
    required this.value,
    this.variant = KxProgressVariant.teal,
    this.height = 6.0,
    this.animate = true,
    this.showLabel = false,
    this.label,
  }) : assert(value >= 0.0 && value <= 1.0);

  /// XP ilerleme çubuğu — seviye bilgileriyle
  static Widget xp({
    required int current,
    required int total,
    required int level,
    required String levelName,
    Key? key,
  }) {
    final value = (current / total).clamp(0.0, 1.0).toDouble();
    return _XpProgressBar(
      key: key,
      current: current,
      total: total,
      level: level,
      levelName: levelName,
      value: value,
    );
  }

  /// İnce, minimal çubuk
  const KxProgressBar.thin({
    Key? key,
    required double value,
    KxProgressVariant variant = KxProgressVariant.teal,
  }) : this(key: key, value: value, height: 3.0, variant: variant, animate: true);

  // ── Style getters ────────────────────────────────────────────

  List<Color> get _gradientColors => switch (variant) {
    KxProgressVariant.teal   => [KxColors.teal500, KxColors.teal300],
    KxProgressVariant.amber  => [KxColors.amber500, KxColors.amber300],
    KxProgressVariant.blue   => [KxColors.blue500, KxColors.blue300],
    KxProgressVariant.crimson => [KxColors.crimson500, KxColors.crimson300],
    KxProgressVariant.jade   => [KxColors.jade500, KxColors.jade300],
  };

  @override
  State<KxProgressBar> createState() => _KxProgressBarState();
}

class _KxProgressBarState extends State<KxProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(KxProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.animate) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel || widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(widget.label!, style: KxTypography.caption),
              Text(
                '${(widget.value * 100).round()}%',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final fillWidth =
                    constraints.maxWidth * widget.value * _animation.value;
                return Container(
                  height: widget.height,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: KxColors.bgHover,
                    borderRadius: KxSpacing.radiusFull,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: fillWidth.clamp(0, constraints.maxWidth),
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: KxSpacing.radiusFull,
                        gradient: LinearGradient(
                          colors: widget._gradientColors,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget._gradientColors[0].withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// XP ilerleme — tam bileşen (seviye + isim + bar + rakamlar)
class _XpProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final int level;
  final String levelName;
  final double value;

  const _XpProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.level,
    required this.levelName,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - current;

    return Container(
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
              Text(
                'Seviye $level',
                style: KxTypography.labelSm.copyWith(
                  color: KxColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$levelName ⚕',
            style: KxTypography.displaySm.copyWith(
              fontSize: 18,
              color: KxColors.amber300,
            ),
          ),
          const SizedBox(height: 10),
          KxProgressBar(value: value, variant: KxProgressVariant.teal),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${_format(current)} XP',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${_format(remaining)} XP kaldı',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
