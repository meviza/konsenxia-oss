import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_shadows.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────

enum NodeType { primary, secondary, excluded }

class DiagnosisNode {
  final String id;
  final String name;
  final double probability; // 0.0 – 1.0
  final NodeType type;
  final List<String> connectedTo;
  final String? reasoning;

  const DiagnosisNode({
    required this.id,
    required this.name,
    required this.probability,
    required this.type,
    required this.connectedTo,
    this.reasoning,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Computed layout node (internal)
// ─────────────────────────────────────────────────────────────────────────────

class _LayoutNode {
  final DiagnosisNode data;
  Offset position;
  final double radius;
  final Color color;

  _LayoutNode({
    required this.data,
    required this.position,
    required this.radius,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// KxDiagnosisGraph — public API
// ─────────────────────────────────────────────────────────────────────────────

class KxDiagnosisGraph extends StatefulWidget {
  final String chiefComplaint;
  final List<DiagnosisNode> nodes;
  final ValueChanged<DiagnosisNode>? onNodeTapped;
  final double height;

  const KxDiagnosisGraph({
    super.key,
    required this.chiefComplaint,
    required this.nodes,
    this.onNodeTapped,
    this.height = 350,
  });

  @override
  State<KxDiagnosisGraph> createState() => _KxDiagnosisGraphState();
}

class _KxDiagnosisGraphState extends State<KxDiagnosisGraph>
    with TickerProviderStateMixin {
  // Layout
  late List<_LayoutNode> _layoutNodes;
  late Offset _centerPosition;

  // Transform
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  Offset? _lastFocalPoint;

  // Animation controllers
  late AnimationController _mountController;
  late AnimationController _breatheController;
  late AnimationController _lineController;
  late AnimationController _selectionController;

  // Selection
  String? _selectedNodeId;

  @override
  void initState() {
    super.initState();

    _mountController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + widget.nodes.length * 50),
    );

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _mountController.forward().then((_) {
      _lineController.forward();
    });
  }

  @override
  void dispose() {
    _mountController.dispose();
    _breatheController.dispose();
    _lineController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  // ── Radial layout ──────────────────────────────────────────────────────────

  void _computeLayout(Size size) {
    _centerPosition = Offset(size.width / 2, size.height / 2);
    _layoutNodes = [];

    if (widget.nodes.isEmpty) return;

    // Sort by probability descending — higher probability nodes closer
    final sorted = List<DiagnosisNode>.from(widget.nodes)
      ..sort((a, b) => b.probability.compareTo(a.probability));

    final total = sorted.length;
    final maxOrbitRadius = min(size.width, size.height) * 0.36;
    final minOrbitRadius = maxOrbitRadius * 0.45;

    for (var i = 0; i < total; i++) {
      final node = sorted[i];
      final angle = (2 * pi * i / total) - pi / 2; // start from top

      // Higher probability → closer to center
      final distanceFactor = 1.0 - node.probability;
      final orbitRadius =
          minOrbitRadius + (maxOrbitRadius - minOrbitRadius) * distanceFactor;

      final position = Offset(
        _centerPosition.dx + cos(angle) * orbitRadius,
        _centerPosition.dy + sin(angle) * orbitRadius,
      );

      // Node radius: 20–40 based on probability
      final nodeRadius = 20.0 + node.probability * 20.0;

      final color = _colorForNode(node);

      _layoutNodes.add(_LayoutNode(
        data: node,
        position: position,
        radius: nodeRadius,
        color: color,
      ));
    }
  }

  Color _colorForNode(DiagnosisNode node) {
    switch (node.type) {
      case NodeType.primary:
        return KxColors.teal400;
      case NodeType.secondary:
        return KxColors.blue400;
      case NodeType.excluded:
        return KxColors.textMuted;
    }
  }

  // ── Hit test ───────────────────────────────────────────────────────────────

  _LayoutNode? _hitTest(Offset localPosition) {
    // Convert to graph space
    final graphPos = (localPosition - _panOffset) / _scale;

    for (final node in _layoutNodes.reversed) {
      if ((graphPos - node.position).distance <= node.radius + 4) {
        return node;
      }
    }

    // Check center node
    if ((_centerPosition - graphPos).distance <= 50) {
      return null; // center node tapped, no action
    }

    return null;
  }

  void _handleTap(Offset localPosition) {
    final node = _hitTest(localPosition);
    if (node != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedNodeId =
            _selectedNodeId == node.data.id ? null : node.data.id;
      });

      if (_selectedNodeId != null) {
        _selectionController.forward(from: 0);
      }

      widget.onNodeTapped?.call(node.data);
    } else {
      setState(() => _selectedNodeId = null);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border, width: 1),
        boxShadow: KxShadows.md,
      ),
      child: ClipRRect(
        borderRadius: KxSpacing.radiusLg,
        child: Stack(
          children: [
            // Background grid pattern
            CustomPaint(
              size: Size.infinite,
              painter: _GridBackgroundPainter(),
            ),

            // Main graph
            GestureDetector(
              onTapUp: (d) => _handleTap(d.localPosition),
              onScaleStart: (d) {
                _lastFocalPoint = d.focalPoint;
              },
              onScaleUpdate: (d) {
                setState(() {
                  // Pan
                  if (_lastFocalPoint != null) {
                    _panOffset += d.focalPoint - _lastFocalPoint!;
                  }
                  _lastFocalPoint = d.focalPoint;

                  // Zoom
                  if (d.scale != 1.0) {
                    _scale = (_scale * d.scale).clamp(0.5, 2.5);
                  }
                });
              },
              onScaleEnd: (_) {
                _lastFocalPoint = null;
              },
              child: _MultiAnimatedBuilder(
                listenable: Listenable.merge([
                  _mountController,
                  _breatheController,
                  _lineController,
                  _selectionController,
                ]),
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      _computeLayout(size);

                      return CustomPaint(
                        size: size,
                        painter: _DiagnosisGraphPainter(
                          layoutNodes: _layoutNodes,
                          centerPosition: _centerPosition,
                          chiefComplaint: widget.chiefComplaint,
                          mountProgress: _mountController.value,
                          breathePhase: _breatheController.value,
                          lineProgress: _lineController.value,
                          selectionProgress: _selectionController.value,
                          selectedNodeId: _selectedNodeId,
                          panOffset: _panOffset,
                          scale: _scale,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Selected node detail popup
            if (_selectedNodeId != null) _buildDetailPopup(),

            // Legend
            Positioned(
              left: KxSpacing.md,
              bottom: KxSpacing.md,
              child: _buildLegend(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPopup() {
    final node = _layoutNodes
        .cast<_LayoutNode?>()
        .firstWhere(
          (n) => n!.data.id == _selectedNodeId,
          orElse: () => null,
        );
    if (node == null) return const SizedBox.shrink();

    final probability = (node.data.probability * 100).toStringAsFixed(1);

    return Positioned(
      top: KxSpacing.md,
      right: KxSpacing.md,
      child: AnimatedOpacity(
        opacity: _selectedNodeId != null ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 180,
          padding: KxSpacing.cardPadding,
          decoration: BoxDecoration(
            color: KxColors.bgElevated,
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(
              color: node.color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: KxShadows.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: node.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: KxSpacing.sm),
                  Expanded(
                    child: Text(
                      node.data.name,
                      style: KxTypography.headingSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KxSpacing.sm),
              Text(
                '%$probability olasılık',
                style: KxTypography.monoSm.copyWith(color: node.color),
              ),
              const SizedBox(height: KxSpacing.xs),
              Text(
                _nodeTypeLabel(node.data.type),
                style: KxTypography.caption,
              ),
              if (node.data.reasoning != null) ...[
                const SizedBox(height: KxSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KxSpacing.sm),
                  decoration: const BoxDecoration(
                    color: KxColors.bgBase,
                    borderRadius: KxSpacing.radiusSm,
                  ),
                  child: Text(
                    node.data.reasoning!,
                    style: KxTypography.bodySm.copyWith(
                      color: KxColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _nodeTypeLabel(NodeType type) {
    switch (type) {
      case NodeType.primary:
        return 'Birincil tanı';
      case NodeType.secondary:
        return 'İkincil tanı';
      case NodeType.excluded:
        return 'Dışlanan tanı';
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KxSpacing.md,
        vertical: KxSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: KxColors.bgBase.withOpacity(0.85),
        borderRadius: KxSpacing.radiusSm,
        border: Border.all(color: KxColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendDot(KxColors.teal400, 'Birincil'),
          const SizedBox(width: KxSpacing.md),
          _legendDot(KxColors.blue400, 'İkincil'),
          const SizedBox(width: KxSpacing.md),
          _legendDot(KxColors.textMuted, 'Dışlanan'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: KxTypography.caption),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid Background Painter
// ─────────────────────────────────────────────────────────────────────────────

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KxColors.border.withOpacity(0.15)
      ..strokeWidth = 0.5;

    const spacing = 24.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Graph Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DiagnosisGraphPainter extends CustomPainter {
  final List<_LayoutNode> layoutNodes;
  final Offset centerPosition;
  final String chiefComplaint;
  final double mountProgress;
  final double breathePhase;
  final double lineProgress;
  final double selectionProgress;
  final String? selectedNodeId;
  final Offset panOffset;
  final double scale;

  _DiagnosisGraphPainter({
    required this.layoutNodes,
    required this.centerPosition,
    required this.chiefComplaint,
    required this.mountProgress,
    required this.breathePhase,
    required this.lineProgress,
    required this.selectionProgress,
    required this.selectedNodeId,
    required this.panOffset,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(scale);

    _drawConnections(canvas, size);
    _drawCenterNode(canvas, size);
    _drawDiagnosisNodes(canvas, size);

    canvas.restore();
  }

  // ── Connections ────────────────────────────────────────────────────────────

  void _drawConnections(Canvas canvas, Size size) {
    if (lineProgress <= 0) return;

    final nodeMap = <String, _LayoutNode>{};
    for (final n in layoutNodes) {
      nodeMap[n.data.id] = n;
    }

    final drawnPairs = <String>{};

    for (final node in layoutNodes) {
      for (final targetId in node.data.connectedTo) {
        final pairKey = [node.data.id, targetId]..sort();
        final key = pairKey.join('-');
        if (drawnPairs.contains(key)) continue;
        drawnPairs.add(key);

        final target = nodeMap[targetId];
        if (target == null) continue;

        final breatheOffset1 = _breatheOffsetFor(node);
        final breatheOffset2 = _breatheOffsetFor(target);
        final from = node.position + breatheOffset1;
        final to = target.position + breatheOffset2;

        _drawCurvedConnection(canvas, from, to, node.color, target.color);
      }

      // Draw connection to center for all nodes
      final breatheOff = _breatheOffsetFor(node);
      final from = node.position + breatheOff;
      _drawCurvedConnection(
        canvas,
        centerPosition,
        from,
        KxColors.teal400,
        node.color,
        isCenterConnection: true,
      );
    }
  }

  void _drawCurvedConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    Color fromColor,
    Color toColor, {
    bool isCenterConnection = false,
  }) {
    final opacity = isCenterConnection ? 0.12 : 0.25;
    final width = isCenterConnection ? 0.8 : 1.0;

    // Bezier control point — offset perpendicular to the line
    final mid = (from + to) / 2;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final perpendicular = Offset(-dy, dx) * 0.15;
    final controlPoint = mid + perpendicular;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, to.dx, to.dy);

    // Animate path drawing
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractedPath =
          metric.extractPath(0, metric.length * lineProgress);

      // Gradient along connection
      final gradient = Paint()
        ..shader = LinearGradient(
          colors: [
            fromColor.withOpacity(opacity),
            toColor.withOpacity(opacity),
          ],
        ).createShader(Rect.fromPoints(from, to))
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(extractedPath, gradient);
    }

    // Particle dots along the connection
    if (lineProgress >= 1.0 && !isCenterConnection) {
      _drawParticles(canvas, path, fromColor, toColor);
    }
  }

  void _drawParticles(
      Canvas canvas, Path path, Color fromColor, Color toColor) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      // Two particles traveling along the line
      for (var i = 0; i < 2; i++) {
        final t = (breathePhase + i * 0.5) % 1.0;
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent == null) continue;

        final particleColor =
            Color.lerp(fromColor, toColor, t)!.withOpacity(0.5);
        final particlePaint = Paint()
          ..color = particleColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawCircle(tangent.position, 1.5, particlePaint);
      }
    }
  }

  // ── Center Node ────────────────────────────────────────────────────────────

  void _drawCenterNode(Canvas canvas, Size size) {
    // Entrance animation: scale up with spring-like overshoot
    final nodeProgress = _springCurve(mountProgress.clamp(0.0, 0.3) / 0.3);
    if (nodeProgress <= 0) return;

    final baseRadius = 50.0 * nodeProgress;

    // Subtle breathe
    final breathe = sin(breathePhase * 2 * pi) * 1.5;
    final radius = baseRadius + breathe;

    // Outer glow
    final glowPaint = Paint()
      ..color = KxColors.teal400.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(centerPosition, radius + 20, glowPaint);

    // Mid glow ring
    final midGlowPaint = Paint()
      ..color = KxColors.teal400.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(centerPosition, radius + 8, midGlowPaint);

    // Fill gradient
    final gradient = RadialGradient(
      colors: [
        KxColors.teal400.withOpacity(0.25),
        KxColors.teal900.withOpacity(0.6),
        KxColors.bgSurface.withOpacity(0.9),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    final fillPaint = Paint()
      ..shader = gradient
          .createShader(Rect.fromCircle(center: centerPosition, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerPosition, radius, fillPaint);

    // Border ring
    final borderPaint = Paint()
      ..color = KxColors.teal400.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(centerPosition, radius, borderPaint);

    // Inner bright ring
    final innerRingPaint = Paint()
      ..color = KxColors.teal300.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(centerPosition, radius * 0.7, innerRingPaint);

    // Chief complaint text
    final textPainter = TextPainter(
      text: TextSpan(
        text: chiefComplaint,
        style: KxTypography.labelSm.copyWith(
          color: KxColors.teal300,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: radius * 1.6);
    textPainter.paint(
      canvas,
      centerPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // ── Diagnosis Nodes ────────────────────────────────────────────────────────

  void _drawDiagnosisNodes(Canvas canvas, Size size) {
    for (var i = 0; i < layoutNodes.length; i++) {
      final node = layoutNodes[i];

      // Staggered entrance: each node delayed by 50ms
      final nodeDelay = 0.2 + (i * 0.05);
      final nodeEnd = nodeDelay + 0.3;
      final rawProgress =
          ((mountProgress - nodeDelay) / (nodeEnd - nodeDelay)).clamp(0.0, 1.0);
      final nodeProgress = _springCurve(rawProgress);
      if (nodeProgress <= 0) continue;

      final breatheOff = _breatheOffsetFor(node);
      final pos = node.position + breatheOff;
      final radius = node.radius * nodeProgress;

      final isSelected = selectedNodeId == node.data.id;

      // Selection ring animation
      if (isSelected && selectionProgress > 0) {
        final ringRadius = radius + 8 + selectionProgress * 12;
        final ringPaint = Paint()
          ..color = node.color.withOpacity(0.3 * (1.0 - selectionProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - selectionProgress * 0.5);
        canvas.drawCircle(pos, ringRadius, ringPaint);

        // Second expanding ring (delayed)
        final ring2Progress = (selectionProgress - 0.15).clamp(0.0, 1.0);
        if (ring2Progress > 0) {
          final ring2Radius = radius + 4 + ring2Progress * 16;
          final ring2Paint = Paint()
            ..color = node.color.withOpacity(0.15 * (1.0 - ring2Progress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 * (1.0 - ring2Progress * 0.5);
          canvas.drawCircle(pos, ring2Radius, ring2Paint);
        }
      }

      // Node glow
      final glowPaint = Paint()
        ..color = node.color.withOpacity(isSelected ? 0.2 : 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(pos, radius + 6, glowPaint);

      // Node fill
      final nodeGradient = RadialGradient(
        colors: [
          node.color.withOpacity(isSelected ? 0.4 : 0.2),
          node.color.withOpacity(isSelected ? 0.15 : 0.06),
          KxColors.bgSurface.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      final fillPaint = Paint()
        ..shader = nodeGradient
            .createShader(Rect.fromCircle(center: pos, radius: radius))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius, fillPaint);

      // Node border
      final borderPaint = Paint()
        ..color = node.color.withOpacity(isSelected ? 0.7 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.5 : 1.0;
      canvas.drawCircle(pos, radius, borderPaint);

      // Excluded node: strikethrough line
      if (node.data.type == NodeType.excluded) {
        final strikePaint = Paint()
          ..color = KxColors.crimson400.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          pos - Offset(radius * 0.6, 0),
          pos + Offset(radius * 0.6, 0),
          strikePaint,
        );
      }

      // Node name text
      final nameStyle = node.data.type == NodeType.excluded
          ? KxTypography.labelSm.copyWith(
              color: KxColors.textMuted,
              decoration: TextDecoration.lineThrough,
              decorationColor: KxColors.crimson400.withOpacity(0.5),
              fontSize: 9,
            )
          : KxTypography.labelSm.copyWith(
              color: KxColors.textPrimary,
              fontSize: radius > 30 ? 10 : 9,
            );

      final nameTP = TextPainter(
        text: TextSpan(text: node.data.name, style: nameStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      nameTP.layout(maxWidth: radius * 2.2);

      // Place text inside node if it fits, otherwise below
      if (nameTP.width < radius * 1.8 && radius >= 28) {
        nameTP.paint(
          canvas,
          pos - Offset(nameTP.width / 2, nameTP.height / 2 + 4),
        );
      } else {
        nameTP.paint(
          canvas,
          Offset(pos.dx - nameTP.width / 2, pos.dy + radius + 4),
        );
      }

      // Probability percentage (mono font, below name or inside)
      final probText = '${(node.data.probability * 100).toStringAsFixed(0)}%';
      final probStyle = KxTypography.monoSm.copyWith(
        color: node.color.withOpacity(0.9),
        fontSize: radius > 30 ? 10 : 8,
      );
      final probTP = TextPainter(
        text: TextSpan(text: probText, style: probStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      probTP.layout();

      if (radius >= 28) {
        // Inside node, below name
        probTP.paint(
          canvas,
          pos - Offset(probTP.width / 2, -4),
        );
      } else {
        // Below the node, after name
        probTP.paint(
          canvas,
          Offset(
            pos.dx - probTP.width / 2,
            pos.dy + radius + 4 + nameTP.height + 2,
          ),
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Offset _breatheOffsetFor(_LayoutNode node) {
    final hash = node.data.id.hashCode;
    final phase = breathePhase * 2 * pi;
    final dx = sin(phase + hash * 0.7) * 2.0;
    final dy = cos(phase + hash * 1.3) * 2.0;
    return Offset(dx, dy);
  }

  /// Spring-like ease-out curve with slight overshoot
  double _springCurve(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    // Attempt an overshoot: f(t) = 1 - e^(-6t) * cos(2t)
    return 1.0 - exp(-6.0 * t) * cos(2.0 * t);
  }

  @override
  bool shouldRepaint(covariant _DiagnosisGraphPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// AnimatedBuilder — convenience wrapper for multi-listenable
// ─────────────────────────────────────────────────────────────────────────────

class _MultiAnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;

  const _MultiAnimatedBuilder({
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
