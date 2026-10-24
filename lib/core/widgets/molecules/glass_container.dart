import 'package:flutter/material.dart';

/// TODO: GlassContainer — legacy stub.
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  const GlassContainer({super.key, this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
