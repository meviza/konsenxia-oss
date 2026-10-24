import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// KONSENXIA — Premium Pressable Wrapper
///
/// Apple Design Award kalitesinde basma efekti.
/// Scale-down (0.96) + spring-back + optional haptic.
/// Tüm interaktif elementlerde kullanılır.
///
/// ```dart
/// KxPressable(
///   onTap: () => doSomething(),
///   child: MyCard(),
/// )
/// ```
class KxPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final bool enableHaptic;
  final HapticType hapticType;
  final Duration duration;

  const KxPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
    this.enableHaptic = true,
    this.hapticType = HapticType.light,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<KxPressable> createState() => _KxPressableState();
}

class _KxPressableState extends State<KxPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
      reverseCurve: _SpringCurve(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    if (widget.enableHaptic) _triggerHaptic();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _ctrl.reverse();
  }

  void _onLongPress() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  void _triggerHaptic() {
    switch (widget.hapticType) {
      case HapticType.light:
        HapticFeedback.lightImpact();
      case HapticType.medium:
        HapticFeedback.mediumImpact();
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
      case HapticType.selection:
        HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onLongPress: widget.onLongPress != null ? _onLongPress : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

enum HapticType { light, medium, heavy, selection }

/// Custom spring curve for natural bounce-back feel
class _SpringCurve extends Curve {
  @override
  double transformInternal(double t) {
    // Slightly underdamped spring — subtle overshoot
    final d = 0.85; // damping ratio
    final w = 12.0; // angular frequency
    return 1.0 -
        (1.0 - t) *
            (1.0 + (1 - d) * _sin(w * t * 3.14159) * _exp(-d * w * t * 0.5));
  }

  double _sin(double x) {
    // Fast sine approximation
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    return x - (x * x * x / 6.0) + (x * x * x * x * x / 120.0);
  }

  double _exp(double x) {
    if (x > 0) return 1.0;
    // Fast exp approximation for negative values
    final abs = -x;
    if (abs > 5) return 0.0;
    return 1.0 / (1.0 + abs + abs * abs * 0.5);
  }
}
