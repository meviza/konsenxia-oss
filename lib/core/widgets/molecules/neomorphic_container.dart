import 'package:flutter/material.dart';

class NeoContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? distance;
  final double? blur;
  final bool isPressed;

  const NeoContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.distance,
    this.blur,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: isPressed
            ? [
                // Inset shadow when pressed
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                  offset: Offset(distance ?? 3, distance ?? 3),
                  blurRadius: blur ?? 10,
                ),
              ]
            : [
                // Light source (top-left)
                BoxShadow(
                  color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.7),
                  offset: Offset(-(distance ?? 5), -(distance ?? 5)),
                  blurRadius: blur ?? 15,
                ),
                // Dark shadow (bottom-right)
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
                  offset: Offset(distance ?? 5, distance ?? 5),
                  blurRadius: blur ?? 15,
                ),
              ],
      ),
      child: child,
    );
  }
}

class NeoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? distance;
  final double? blur;

  const NeoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.distance,
    this.blur,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shadowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: NeoContainer(
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            backgroundColor: widget.backgroundColor,
            distance: (widget.distance ?? 5) * _shadowAnimation.value,
            blur: (widget.blur ?? 15) * _shadowAnimation.value,
            isPressed: _isPressed,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeoContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}
