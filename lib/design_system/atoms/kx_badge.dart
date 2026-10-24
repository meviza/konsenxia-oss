import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Atom — KxBadge
///
/// Status, uzmanlık, aciliyet ve seviye badge'leri.
///
/// Kullanım:
/// ```dart
/// KxBadge.teal('Aktif Vaka')
/// KxBadge.urgency(KxUrgency.high)
/// KxBadge.specialty('Kardiyoloji')
/// KxBadge.level(8, 'Uzman Klinisyen')
/// ```
enum KxBadgeVariant { teal, blue, amber, crimson, jade, neutral }
enum KxUrgency      { low, medium, high, critical }

class KxBadge extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final KxBadgeVariant variant;
  final bool hasDot;

  const KxBadge(
    this.label, {
    super.key,
    this.leadingIcon,
    this.variant = KxBadgeVariant.teal,
    this.hasDot = false,
  });

  // ── Named constructors ────────────────────────────────────────

  const KxBadge.teal(String label, {Key? key, bool hasDot = false})
      : this(label, key: key, variant: KxBadgeVariant.teal, hasDot: hasDot);

  const KxBadge.blue(String label, {Key? key})
      : this(label, key: key, variant: KxBadgeVariant.blue);

  const KxBadge.amber(String label, {Key? key})
      : this(label, key: key, variant: KxBadgeVariant.amber);

  const KxBadge.crimson(String label, {Key? key})
      : this(label, key: key, variant: KxBadgeVariant.crimson);

  const KxBadge.jade(String label, {Key? key})
      : this(label, key: key, variant: KxBadgeVariant.jade);

  const KxBadge.neutral(String label, {Key? key})
      : this(label, key: key, variant: KxBadgeVariant.neutral);

  /// Aciliyet badge'i — KxUrgency enum'dan
  factory KxBadge.urgency(KxUrgency urgency) {
    return switch (urgency) {
      KxUrgency.low      => const KxBadge.jade('Düşük'),
      KxUrgency.medium   => const KxBadge.amber('Orta'),
      KxUrgency.high     => const KxBadge.crimson('Acil'),
      KxUrgency.critical => KxBadge(
          '⚡ Kritik',
          variant: KxBadgeVariant.crimson,
          leadingIcon: null,
          hasDot: true,
        ),
    };
  }

  /// Uzmanlık alanı badge'i
  factory KxBadge.specialty(String name) {
    final color = KxColors.specialtyColors[name.toLowerCase()];
    if (color == null) return KxBadge.teal(name);
    return KxBadge(name, variant: KxBadgeVariant.teal);
  }

  /// Seviye badge'i (amber — premium his)
  factory KxBadge.level(int level, String title) {
    return KxBadge(
      '★ Lvl $level · $title',
      variant: KxBadgeVariant.amber,
    );
  }

  // ── Style getters ────────────────────────────────────────────

  Color get _bg => switch (variant) {
    KxBadgeVariant.teal    => KxColors.teal400.withOpacity(0.15),
    KxBadgeVariant.blue    => KxColors.blue400.withOpacity(0.15),
    KxBadgeVariant.amber   => KxColors.amber500.withOpacity(0.15),
    KxBadgeVariant.crimson => KxColors.crimson500.withOpacity(0.15),
    KxBadgeVariant.jade    => KxColors.jade500.withOpacity(0.15),
    KxBadgeVariant.neutral => KxColors.bgCard,
  };

  Color get _text => switch (variant) {
    KxBadgeVariant.teal    => KxColors.teal300,
    KxBadgeVariant.blue    => KxColors.blue300,
    KxBadgeVariant.amber   => KxColors.amber300,
    KxBadgeVariant.crimson => KxColors.crimson300,
    KxBadgeVariant.jade    => KxColors.jade300,
    KxBadgeVariant.neutral => KxColors.textSecondary,
  };

  Color get _border => switch (variant) {
    KxBadgeVariant.teal    => KxColors.teal400.withOpacity(0.2),
    KxBadgeVariant.blue    => KxColors.blue400.withOpacity(0.2),
    KxBadgeVariant.amber   => KxColors.amber500.withOpacity(0.2),
    KxBadgeVariant.crimson => KxColors.crimson500.withOpacity(0.2),
    KxBadgeVariant.jade    => KxColors.jade500.withOpacity(0.2),
    KxBadgeVariant.neutral => KxColors.border,
  };

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: KxSpacing.chipPadding,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: KxSpacing.radiusFull,
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            _PulseDot(color: _text),
            const SizedBox(width: 4),
          ],
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: KxTypography.labelSm.copyWith(color: _text),
          ),
        ],
      ),
    );
  }
}

/// Canlı nokta animasyonu (aktif vaka, online göstergesi)
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
