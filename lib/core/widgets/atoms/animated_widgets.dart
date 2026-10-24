import 'package:flutter/material.dart';

/// Legacy stub — FadeInAnimation artık flutter_animate ile yapılıyor
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const FadeInAnimation({super.key, required this.child, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => child;
}
