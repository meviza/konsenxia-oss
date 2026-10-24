import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_shadows.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KONSENXIA — Premium Interactive Body Map
// Apple Design Award calibre anatomical selector widget.
// ─────────────────────────────────────────────────────────────────────────────

/// Anatomical body regions that can be selected.
enum BodyRegion {
  head,
  neck,
  chest,
  abdomen,
  leftArm,
  rightArm,
  leftLeg,
  rightLeg,
  back,
  pelvis,
}

/// Turkish labels for each region.
extension BodyRegionLabel on BodyRegion {
  String get label {
    switch (this) {
      case BodyRegion.head:
        return 'Baş';
      case BodyRegion.neck:
        return 'Boyun';
      case BodyRegion.chest:
        return 'Göğüs';
      case BodyRegion.abdomen:
        return 'Karın';
      case BodyRegion.leftArm:
        return 'Sol Kol';
      case BodyRegion.rightArm:
        return 'Sağ Kol';
      case BodyRegion.leftLeg:
        return 'Sol Bacak';
      case BodyRegion.rightLeg:
        return 'Sağ Bacak';
      case BodyRegion.back:
        return 'Sırt';
      case BodyRegion.pelvis:
        return 'Pelvis';
    }
  }

  /// Common symptoms mapped to this region (Turkish).
  List<String> get symptoms {
    switch (this) {
      case BodyRegion.head:
        return ['Baş ağrısı', 'Baş dönmesi', 'Görme bozukluğu', 'Kulak ağrısı'];
      case BodyRegion.neck:
        return ['Boyun ağrısı', 'Boyun sertliği', 'Yutma güçlüğü'];
      case BodyRegion.chest:
        return ['Göğüs ağrısı', 'Nefes darlığı', 'Çarpıntı', 'Öksürük'];
      case BodyRegion.abdomen:
        return ['Karın ağrısı', 'Bulantı', 'Kusma', 'İshal', 'Kabızlık'];
      case BodyRegion.leftArm:
      case BodyRegion.rightArm:
        return ['Kol ağrısı', 'Uyuşma', 'Güçsüzlük', 'Eklem ağrısı'];
      case BodyRegion.leftLeg:
      case BodyRegion.rightLeg:
        return ['Bacak ağrısı', 'Şişlik', 'Yürüme güçlüğü', 'Kramp'];
      case BodyRegion.back:
        return ['Sırt ağrısı', 'Bel ağrısı', 'Hareket kısıtlılığı'];
      case BodyRegion.pelvis:
        return ['Kasık ağrısı', 'İdrar problemi', 'Pelvik ağrı'];
    }
  }

  /// Label offset relative to the body center (for floating labels).
  Offset get labelOffset {
    switch (this) {
      case BodyRegion.head:
        return const Offset(0, -0.02);
      case BodyRegion.neck:
        return const Offset(0.22, 0.15);
      case BodyRegion.chest:
        return const Offset(-0.30, 0.24);
      case BodyRegion.abdomen:
        return const Offset(0.28, 0.37);
      case BodyRegion.leftArm:
        return const Offset(-0.46, 0.30);
      case BodyRegion.rightArm:
        return const Offset(0.46, 0.30);
      case BodyRegion.leftLeg:
        return const Offset(-0.22, 0.72);
      case BodyRegion.rightLeg:
        return const Offset(0.22, 0.72);
      case BodyRegion.back:
        return const Offset(-0.30, 0.32);
      case BodyRegion.pelvis:
        return const Offset(0, 0.48);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public Widget
// ─────────────────────────────────────────────────────────────────────────────

/// Premium interactive human body map for symptom region selection.
///
/// Usage:
/// ```dart
/// KxBodyMap(
///   selectedRegions: {BodyRegion.chest, BodyRegion.abdomen},
///   onRegionTapped: (region) {},
///   onSymptomSelected: (symptom) {},
///   height: 400,
/// )
/// ```
class KxBodyMap extends StatefulWidget {
  const KxBodyMap({
    super.key,
    this.selectedRegions = const {},
    this.onRegionTapped,
    this.onSymptomSelected,
    this.height = 400,
  });

  /// Currently selected body regions.
  final Set<BodyRegion> selectedRegions;

  /// Called when a region is tapped.
  final ValueChanged<BodyRegion>? onRegionTapped;

  /// Called when a symptom chip is tapped from the bottom sheet.
  final ValueChanged<String>? onSymptomSelected;

  /// Total height of the body map widget.
  final double height;

  @override
  State<KxBodyMap> createState() => _KxBodyMapState();
}

class _KxBodyMapState extends State<KxBodyMap> with TickerProviderStateMixin {
  // ── Pulse animation for the most recently tapped region ──
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  BodyRegion? _pulsatingRegion;

  // ── Breathing glow for all selected regions ──
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.12, end: 0.30).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTap(BodyRegion region, BuildContext context) {
    HapticFeedback.mediumImpact();
    setState(() => _pulsatingRegion = region);
    _pulseController.forward(from: 0);

    widget.onRegionTapped?.call(region);

    // Show symptom bottom sheet
    _showSymptomSheet(context, region);
  }

  void _showSymptomSheet(BuildContext context, BodyRegion region) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SymptomBottomSheet(
        region: region,
        onSymptomSelected: widget.onSymptomSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.height * 0.5; // 200 for 400 height

    return SizedBox(
      height: widget.height,
      width: width + 160, // extra for labels
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Ambient glow behind the body ──
              if (widget.selectedRegions.isNotEmpty)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: width * 0.6,
                      height: widget.height * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: KxColors.teal400.withOpacity(
                              _glowAnimation.value * 0.15,
                            ),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Body painter + hit detection ──
              Center(
                child: GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final center = Offset(
                      box.size.width / 2,
                      box.size.height / 2,
                    );
                    // Transform tap to body-local coords
                    final bodyOrigin = Offset(
                      center.dx - width / 2,
                      center.dy - widget.height / 2,
                    );
                    final local = details.localPosition - bodyOrigin;

                    final regionPaths = _BodyPathBuilder.buildAll(
                      width,
                      widget.height,
                    );

                    for (final entry in regionPaths.entries) {
                      if (entry.value.contains(local)) {
                        _handleTap(entry.key, context);
                        return;
                      }
                    }
                  },
                  child: CustomPaint(
                    size: Size(width, widget.height),
                    painter: _BodyMapPainter(
                      selectedRegions: widget.selectedRegions,
                      pulseRegion: _pulsatingRegion,
                      pulseScale: _pulseAnimation.value,
                      glowOpacity: _glowAnimation.value,
                    ),
                  ),
                ),
              ),

              // ── Floating labels for selected regions ──
              ...widget.selectedRegions.map((region) {
                final offset = region.labelOffset;
                return Positioned(
                  left: (width + 160) / 2 + offset.dx * (width + 80) - 30,
                  top: widget.height * offset.dy,
                  child: _FloatingLabel(label: region.label),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Label Widget
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingLabel extends StatelessWidget {
  const _FloatingLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: KxColors.teal900.withOpacity(0.85),
        borderRadius: KxSpacing.radiusSm,
        border: Border.all(color: KxColors.teal400.withOpacity(0.5), width: 0.5),
        boxShadow: KxShadows.tealGlow(opacity: 0.12),
      ),
      child: Text(
        label,
        style: KxTypography.labelSm.copyWith(
          color: KxColors.teal300,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Symptom Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomBottomSheet extends StatelessWidget {
  const _SymptomBottomSheet({
    required this.region,
    this.onSymptomSelected,
  });

  final BodyRegion region;
  final ValueChanged<String>? onSymptomSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: KxSpacing.cardPaddingLg,
      decoration: BoxDecoration(
        color: KxColors.bgElevated,
        borderRadius: KxSpacing.radiusXl,
        border: Border.all(color: KxColors.border, width: 0.5),
        boxShadow: KxShadows.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: KxColors.textMuted.withOpacity(0.4),
                borderRadius: KxSpacing.radiusFull,
              ),
            ),
          ),
          const SizedBox(height: KxSpacing.lg),

          // ── Title row ──
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: KxColors.teal400,
                  shape: BoxShape.circle,
                  boxShadow: KxShadows.tealGlow(opacity: 0.35),
                ),
              ),
              const SizedBox(width: KxSpacing.sm),
              Text(
                region.label,
                style: KxTypography.headingMd.copyWith(
                  color: KxColors.teal300,
                ),
              ),
              const Spacer(),
              Text(
                'Semptom Sec',
                style: KxTypography.caption.copyWith(
                  color: KxColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: KxSpacing.lg),

          // ── Symptom chips ──
          Wrap(
            spacing: KxSpacing.sm,
            runSpacing: KxSpacing.sm,
            children: region.symptoms.map((symptom) {
              return _SymptomChip(
                symptom: symptom,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSymptomSelected?.call(symptom);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + KxSpacing.sm),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatefulWidget {
  const _SymptomChip({required this.symptom, required this.onTap});
  final String symptom;
  final VoidCallback onTap;

  @override
  State<_SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<_SymptomChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: KxSpacing.chipPadding,
        decoration: BoxDecoration(
          color: _pressed
              ? KxColors.teal400.withOpacity(0.15)
              : KxColors.bgCard,
          borderRadius: KxSpacing.radiusFull,
          border: Border.all(
            color: _pressed
                ? KxColors.teal400.withOpacity(0.6)
                : KxColors.border,
            width: 0.5,
          ),
        ),
        child: Text(
          widget.symptom,
          style: KxTypography.labelSm.copyWith(
            color: _pressed ? KxColors.teal300 : KxColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body Path Builder — Generates anatomical Path objects for each region
// ─────────────────────────────────────────────────────────────────────────────

class _BodyPathBuilder {
  /// Returns all region paths scaled to the given [width] x [height].
  /// Canonical design: 200 x 400. Paths are proportional.
  static Map<BodyRegion, Path> buildAll(double width, double height) {
    final sx = width / 200.0;
    final sy = height / 400.0;
    return {
      BodyRegion.head: _head(sx, sy),
      BodyRegion.neck: _neck(sx, sy),
      BodyRegion.chest: _chest(sx, sy),
      BodyRegion.abdomen: _abdomen(sx, sy),
      BodyRegion.leftArm: _leftArm(sx, sy),
      BodyRegion.rightArm: _rightArm(sx, sy),
      BodyRegion.pelvis: _pelvis(sx, sy),
      BodyRegion.leftLeg: _leftLeg(sx, sy),
      BodyRegion.rightLeg: _rightLeg(sx, sy),
      BodyRegion.back: _back(sx, sy),
    };
  }

  // ── Head: elliptical shape ──
  static Path _head(double sx, double sy) {
    return Path()
      ..addOval(Rect.fromCenter(
        center: Offset(100 * sx, 30 * sy),
        width: 44 * sx,
        height: 52 * sy,
      ));
  }

  // ── Neck: short trapezoid ──
  static Path _neck(double sx, double sy) {
    return Path()
      ..moveTo(90 * sx, 55 * sy)
      ..lineTo(110 * sx, 55 * sy)
      ..lineTo(112 * sx, 72 * sy)
      ..lineTo(88 * sx, 72 * sy)
      ..close();
  }

  // ── Chest: broad trapezoid with rounded shoulders ──
  static Path _chest(double sx, double sy) {
    return Path()
      ..moveTo(88 * sx, 72 * sy)
      ..lineTo(112 * sx, 72 * sy)
      // right shoulder
      ..quadraticBezierTo(135 * sx, 74 * sy, 140 * sx, 85 * sy)
      ..lineTo(140 * sx, 135 * sy)
      ..lineTo(60 * sx, 135 * sy)
      // left shoulder
      ..lineTo(60 * sx, 85 * sy)
      ..quadraticBezierTo(65 * sx, 74 * sy, 88 * sx, 72 * sy)
      ..close();
  }

  // ── Abdomen: rectangle with slight taper ──
  static Path _abdomen(double sx, double sy) {
    return Path()
      ..moveTo(60 * sx, 135 * sy)
      ..lineTo(140 * sx, 135 * sy)
      ..lineTo(136 * sx, 190 * sy)
      ..lineTo(64 * sx, 190 * sy)
      ..close();
  }

  // ── Left arm (viewer's left = body's right arm visually) ──
  static Path _leftArm(double sx, double sy) {
    return Path()
      ..moveTo(60 * sx, 85 * sy)
      ..lineTo(48 * sx, 88 * sy)
      ..quadraticBezierTo(30 * sx, 95 * sy, 25 * sx, 130 * sy)
      ..lineTo(20 * sx, 170 * sy)
      ..quadraticBezierTo(17 * sx, 185 * sy, 18 * sx, 200 * sy)
      ..lineTo(14 * sx, 220 * sy)
      // hand
      ..quadraticBezierTo(12 * sx, 232 * sy, 16 * sx, 238 * sy)
      ..lineTo(28 * sx, 235 * sy)
      ..quadraticBezierTo(32 * sx, 228 * sy, 30 * sx, 218 * sy)
      ..lineTo(34 * sx, 195 * sy)
      ..quadraticBezierTo(36 * sx, 175 * sy, 40 * sx, 155 * sy)
      ..lineTo(48 * sx, 130 * sy)
      ..lineTo(60 * sx, 135 * sy)
      ..lineTo(60 * sx, 85 * sy)
      ..close();
  }

  // ── Right arm (viewer's right) ──
  static Path _rightArm(double sx, double sy) {
    return Path()
      ..moveTo(140 * sx, 85 * sy)
      ..lineTo(152 * sx, 88 * sy)
      ..quadraticBezierTo(170 * sx, 95 * sy, 175 * sx, 130 * sy)
      ..lineTo(180 * sx, 170 * sy)
      ..quadraticBezierTo(183 * sx, 185 * sy, 182 * sx, 200 * sy)
      ..lineTo(186 * sx, 220 * sy)
      // hand
      ..quadraticBezierTo(188 * sx, 232 * sy, 184 * sx, 238 * sy)
      ..lineTo(172 * sx, 235 * sy)
      ..quadraticBezierTo(168 * sx, 228 * sy, 170 * sx, 218 * sy)
      ..lineTo(166 * sx, 195 * sy)
      ..quadraticBezierTo(164 * sx, 175 * sy, 160 * sx, 155 * sy)
      ..lineTo(152 * sx, 130 * sy)
      ..lineTo(140 * sx, 135 * sy)
      ..lineTo(140 * sx, 85 * sy)
      ..close();
  }

  // ── Pelvis: wide band below abdomen ──
  static Path _pelvis(double sx, double sy) {
    return Path()
      ..moveTo(64 * sx, 190 * sy)
      ..lineTo(136 * sx, 190 * sy)
      ..lineTo(132 * sx, 218 * sy)
      ..quadraticBezierTo(100 * sx, 225 * sy, 68 * sx, 218 * sy)
      ..close();
  }

  // ── Left leg ──
  static Path _leftLeg(double sx, double sy) {
    return Path()
      ..moveTo(68 * sx, 218 * sy)
      ..quadraticBezierTo(74 * sx, 222 * sy, 80 * sx, 222 * sy)
      ..lineTo(98 * sx, 222 * sy)
      // inner thigh
      ..lineTo(96 * sx, 260 * sy)
      ..lineTo(94 * sx, 310 * sy)
      // knee
      ..quadraticBezierTo(93 * sx, 325 * sy, 92 * sx, 340 * sy)
      // shin
      ..lineTo(90 * sx, 370 * sy)
      // foot
      ..quadraticBezierTo(88 * sx, 385 * sy, 82 * sx, 392 * sy)
      ..lineTo(70 * sx, 395 * sy)
      ..quadraticBezierTo(65 * sx, 396 * sy, 64 * sx, 392 * sy)
      ..lineTo(66 * sx, 384 * sy)
      ..quadraticBezierTo(68 * sx, 375 * sy, 68 * sx, 365 * sy)
      // outer shin
      ..lineTo(66 * sx, 340 * sy)
      ..quadraticBezierTo(64 * sx, 320 * sy, 62 * sx, 300 * sy)
      ..lineTo(58 * sx, 260 * sy)
      ..lineTo(56 * sx, 235 * sy)
      ..close();
  }

  // ── Right leg ──
  static Path _rightLeg(double sx, double sy) {
    return Path()
      ..moveTo(132 * sx, 218 * sy)
      ..quadraticBezierTo(126 * sx, 222 * sy, 120 * sx, 222 * sy)
      ..lineTo(102 * sx, 222 * sy)
      // inner thigh
      ..lineTo(104 * sx, 260 * sy)
      ..lineTo(106 * sx, 310 * sy)
      // knee
      ..quadraticBezierTo(107 * sx, 325 * sy, 108 * sx, 340 * sy)
      // shin
      ..lineTo(110 * sx, 370 * sy)
      // foot
      ..quadraticBezierTo(112 * sx, 385 * sy, 118 * sx, 392 * sy)
      ..lineTo(130 * sx, 395 * sy)
      ..quadraticBezierTo(135 * sx, 396 * sy, 136 * sx, 392 * sy)
      ..lineTo(134 * sx, 384 * sy)
      ..quadraticBezierTo(132 * sx, 375 * sy, 132 * sx, 365 * sy)
      // outer shin
      ..lineTo(134 * sx, 340 * sy)
      ..quadraticBezierTo(136 * sx, 320 * sy, 138 * sx, 300 * sy)
      ..lineTo(142 * sx, 260 * sy)
      ..lineTo(144 * sx, 235 * sy)
      ..close();
  }

  // ── Back: overlay strip on upper torso (visible as subtle inner region) ──
  static Path _back(double sx, double sy) {
    return Path()
      ..moveTo(80 * sx, 90 * sy)
      ..lineTo(120 * sx, 90 * sy)
      ..lineTo(120 * sx, 135 * sy)
      ..lineTo(80 * sx, 135 * sy)
      ..close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — Renders the anatomical silhouette
// ─────────────────────────────────────────────────────────────────────────────

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.selectedRegions,
    required this.pulseRegion,
    required this.pulseScale,
    required this.glowOpacity,
  });

  final Set<BodyRegion> selectedRegions;
  final BodyRegion? pulseRegion;
  final double pulseScale;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _BodyPathBuilder.buildAll(size.width, size.height);

    // Draw order: back first (behind chest), then the rest
    final drawOrder = [
      BodyRegion.back,
      BodyRegion.leftLeg,
      BodyRegion.rightLeg,
      BodyRegion.pelvis,
      BodyRegion.abdomen,
      BodyRegion.chest,
      BodyRegion.leftArm,
      BodyRegion.rightArm,
      BodyRegion.neck,
      BodyRegion.head,
    ];

    for (final region in drawOrder) {
      final path = paths[region]!;
      final isSelected = selectedRegions.contains(region);
      final isPulsing = pulseRegion == region && pulseScale != 1.0;

      canvas.save();

      // ── Pulse scale transform ──
      if (isPulsing) {
        final bounds = path.getBounds();
        final center = bounds.center;
        canvas.translate(center.dx, center.dy);
        canvas.scale(pulseScale);
        canvas.translate(-center.dx, -center.dy);
      }

      // ── Glow shadow for selected regions ──
      if (isSelected) {
        final glowPaint = Paint()
          ..color = KxColors.teal400.withOpacity(glowOpacity * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, glowPaint);
      }

      // ── Fill ──
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = isSelected
            ? KxColors.teal400.withOpacity(0.25)
            : KxColors.bgCard.withOpacity(0.7);
      canvas.drawPath(path, fillPaint);

      // ── Border ──
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.5 : 0.8
        ..color = isSelected
            ? KxColors.teal400.withOpacity(0.8)
            : KxColors.border.withOpacity(0.6);
      canvas.drawPath(path, borderPaint);

      // ── Inner highlight for selected (subtle gradient line at top) ──
      if (isSelected) {
        final highlightPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = KxColors.teal300.withOpacity(0.35);
        canvas.drawPath(path, highlightPaint);
      }

      canvas.restore();
    }

    // ── Subtle center line (anatomical midline) ──
    final midlinePaint = Paint()
      ..color = KxColors.border.withOpacity(0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final midX = size.width / 2;
    canvas.drawLine(
      Offset(midX, size.height * 0.18),
      Offset(midX, size.height * 0.55),
      midlinePaint,
    );
  }

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) =>
      oldDelegate.selectedRegions != selectedRegions ||
      oldDelegate.pulseRegion != pulseRegion ||
      oldDelegate.pulseScale != pulseScale ||
      oldDelegate.glowOpacity != glowOpacity;
}
