import 'package:flutter/material.dart';

/// KONSENXIA — Staggered List Animation
///
/// Liste elemanlarını ardışık gecikmeyle animate eder.
/// Apple Design Award kalitesinde giriş animasyonu.
///
/// ```dart
/// KxStaggeredList(
///   children: items.map((item) => ItemCard(item: item)).toList(),
/// )
/// ```
class KxStaggeredList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final double slideOffset;
  final Axis slideAxis;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const KxStaggeredList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 30.0,
    this.slideAxis = Axis.vertical,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  State<KxStaggeredList> createState() => _KxStaggeredListState();
}

class _KxStaggeredListState extends State<KxStaggeredList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.itemDuration +
        widget.staggerDelay * widget.children.length;
    _ctrl = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _ctrl.duration!.inMilliseconds;

    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        final startMs = widget.staggerDelay.inMilliseconds * index;
        final endMs = startMs + widget.itemDuration.inMilliseconds;
        final start = (startMs / totalMs).clamp(0.0, 1.0);
        final end = (endMs / totalMs).clamp(0.0, 1.0);

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: widget.curve),
          ),
        );

        final slide = Tween<Offset>(
          begin: widget.slideAxis == Axis.vertical
              ? Offset(0, widget.slideOffset)
              : Offset(widget.slideOffset, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: widget.curve),
          ),
        );

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Transform.translate(
            offset: slide.value,
            child: Opacity(
              opacity: fade.value,
              child: child,
            ),
          ),
          child: widget.children[index],
        );
      },
    );
  }
}

/// Single staggered item — use inside your own list
class KxStaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const KxStaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<KxStaggeredItem> createState() => _KxStaggeredItemState();
}

class _KxStaggeredItemState extends State<KxStaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
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
      builder: (context, child) => Transform.translate(
        offset: _slide.value,
        child: Opacity(
          opacity: _fade.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
