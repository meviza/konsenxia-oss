import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_shadows.dart';

/// KONSENXIA Atom — KxButton
///
/// Kullanım örnekleri:
/// ```dart
/// KxButton.primary(label: 'Vakayı Paylaş', onPressed: () {})
/// KxButton.secondary(label: 'İptal', onPressed: () {})
/// KxButton.ghost(label: 'Detay', onPressed: () {})
/// KxButton.danger(label: '⚠ Acil Bildir', onPressed: () {})
/// KxButton.icon(icon: Icons.add, onPressed: () {})
/// ```
enum KxButtonVariant { primary, secondary, ghost, danger }
enum KxButtonSize    { sm, md, lg }

class KxButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final KxButtonVariant variant;
  final KxButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const KxButton({
    super.key,
    this.label,
    this.child,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = KxButtonVariant.primary,
    this.size = KxButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : assert(label != null || child != null || icon != null,
            'KxButton: label, child veya icon gereklidir');

  // ── Named constructors ────────────────────────────────────────

  const KxButton.primary({
    super.key,
    required String this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = KxButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  })  : variant = KxButtonVariant.primary,
        child = null;

  const KxButton.secondary({
    super.key,
    required String this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = KxButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  })  : variant = KxButtonVariant.secondary,
        child = null;

  const KxButton.ghost({
    super.key,
    required String this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = KxButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  })  : variant = KxButtonVariant.ghost,
        child = null;

  const KxButton.danger({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.size = KxButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
  })  : variant = KxButtonVariant.danger,
        trailingIcon = null,
        child = null;

  /// Sadece ikon, label yok
  const KxButton.icon({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.variant = KxButtonVariant.secondary,
    this.size = KxButtonSize.md,
    this.isLoading = false,
  })  : label = null,
        child = null,
        trailingIcon = null,
        isFullWidth = false;

  @override
  State<KxButton> createState() => _KxButtonState();
}

class _KxButtonState extends State<KxButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.animateTo(0.96);
    }
  }

  void _onTapUp(TapUpDetails _) => _controller.animateTo(1.0);
  void _onTapCancel()           => _controller.animateTo(1.0);

  // ── Style getters ────────────────────────────────────────────

  Color get _bgColor => switch (widget.variant) {
    KxButtonVariant.primary   => KxColors.teal400,
    KxButtonVariant.secondary => KxColors.bgCard,
    KxButtonVariant.ghost     => Colors.transparent,
    KxButtonVariant.danger    =>
        KxColors.crimson500.withOpacity(0.15),
  };

  Color get _textColor => switch (widget.variant) {
    KxButtonVariant.primary   => KxColors.bgVoid,
    KxButtonVariant.secondary => KxColors.textPrimary,
    KxButtonVariant.ghost     => KxColors.textSecondary,
    KxButtonVariant.danger    => KxColors.crimson300,
  };

  BorderSide get _border => switch (widget.variant) {
    KxButtonVariant.primary   => BorderSide.none,
    KxButtonVariant.secondary => const BorderSide(color: KxColors.border),
    KxButtonVariant.ghost     => BorderSide.none,
    KxButtonVariant.danger    =>
        BorderSide(color: KxColors.crimson500.withOpacity(0.3)),
  };

  List<BoxShadow>? get _shadow => switch (widget.variant) {
    KxButtonVariant.primary => KxShadows.tealGlow(),
    _                       => null,
  };

  EdgeInsets get _padding => switch (widget.size) {
    KxButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    KxButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    KxButtonSize.lg => const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
  };

  double get _iconSize => switch (widget.size) {
    KxButtonSize.sm => KxSpacing.iconSm,
    KxButtonSize.md => KxSpacing.iconMd,
    KxButtonSize.lg => KxSpacing.iconLg,
  };

  TextStyle get _textStyle => switch (widget.size) {
    KxButtonSize.sm => KxTypography.labelSm.copyWith(color: _textColor),
    KxButtonSize.md => KxTypography.labelMd.copyWith(color: _textColor),
    KxButtonSize.lg => KxTypography.labelLg.copyWith(color: _textColor),
  };

  bool get _isIconOnly => widget.label == null && widget.child == null;

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget content = _buildContent();

    if (widget.isFullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: _isIconOnly
                ? EdgeInsets.all(
                    widget.size == KxButtonSize.sm ? 6.0 : 8.0,
                  )
                : _padding,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: _isIconOnly
                  ? KxSpacing.radiusMd
                  : KxSpacing.radiusMd,
              border: Border.fromBorderSide(_border),
              boxShadow: _shadow,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation(_textColor),
        ),
      );
    }

    if (_isIconOnly && widget.icon != null) {
      return Icon(widget.icon, size: _iconSize, color: _textColor);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _iconSize, color: _textColor),
          const SizedBox(width: 6),
        ],
        if (widget.label != null)
          Text(widget.label!, style: _textStyle)
        else if (widget.child != null)
          widget.child!,
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 6),
          Icon(widget.trailingIcon, size: _iconSize - 2, color: _textColor),
        ],
      ],
    );
  }
}
