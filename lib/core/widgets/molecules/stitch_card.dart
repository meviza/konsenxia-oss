import 'package:flutter/material.dart';

/// TODO: StitchCard — legacy stub.
class StitchCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  const StitchCard({super.key, this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
