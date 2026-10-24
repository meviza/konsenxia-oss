import 'package:flutter/material.dart';

/// TODO: GlassBottomNavigation — legacy stub.
class GlassBottomNavigation extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  const GlassBottomNavigation({super.key, this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
