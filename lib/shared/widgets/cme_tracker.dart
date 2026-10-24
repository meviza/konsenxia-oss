import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// KONSENXIA — CME Kredi Takip Widget'i
///
/// Surekli Tip Egitimi (Continuing Medical Education) ilerleme gostergesi.
/// Dairesel progress bar ile kazanilan / gereken kredileri gosterir.
class CmeTracker extends StatelessWidget {
  final int earnedCredits;
  final int requiredCredits;
  final double size;

  const CmeTracker({
    super.key,
    this.earnedCredits = 32,
    this.requiredCredits = 50,
    this.size = 140,
  });

  double get _progress =>
      (earnedCredits / requiredCredits).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Baslik ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KxColors.jade300.withOpacity(0.12),
                  borderRadius: KxSpacing.radiusSm,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 16, color: KxColors.jade300),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CME Kredi Takibi',
                        style: KxTypography.labelMd),
                    Text(
                      'Surekli Tip Egitimi',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Dairesel ilerleme ────────────────────────────
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CmeProgressPainter(
                progress: _progress,
                trackColor: KxColors.bgHover,
                progressColor: KxColors.jade300,
                strokeWidth: 8,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$earnedCredits',
                      style: KxTypography.headingLg.copyWith(
                        color: KxColors.jade300,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '/ $requiredCredits',
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CME Kredisi',
                      style: KxTypography.caption.copyWith(
                        color: KxColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Yüzde ve durum ──────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _progress >= 1.0
                  ? KxColors.jade300.withOpacity(0.08)
                  : KxColors.bgSurface,
              borderRadius: KxSpacing.radiusMd,
              border: Border.all(
                color: _progress >= 1.0
                    ? KxColors.jade300.withOpacity(0.2)
                    : KxColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _progress >= 1.0
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  size: 14,
                  color: _progress >= 1.0
                      ? KxColors.jade300
                      : KxColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _progress >= 1.0
                      ? 'Yillik hedef tamamlandi!'
                      : '${(requiredCredits - earnedCredits)} kredi kaldi',
                  style: KxTypography.labelSm.copyWith(
                    color: _progress >= 1.0
                        ? KxColors.jade300
                        : KxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Alt detaylar ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                label: 'Bu Ay',
                value: '${(earnedCredits * 0.2).round()}',
                color: KxColors.teal400,
              ),
              _MiniStat(
                label: 'Tamamlama',
                value: '${(_progress * 100).round()}%',
                color: KxColors.jade300,
              ),
              _MiniStat(
                label: 'Kalan Gun',
                value: '${_daysRemaining()}',
                color: KxColors.amber300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _daysRemaining() {
    final now = DateTime.now();
    final endOfYear = DateTime(now.year, 12, 31);
    return endOfYear.difference(now).inDays;
  }
}

// ── Mini istatistik ─────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: KxTypography.labelMd.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: KxTypography.caption.copyWith(
            color: KxColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ── Dairesel Progress Painter ───────────────────────────────────────

class _CmeProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CmeProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arka plan halkasi
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // İlerleme arki
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          progressColor.withOpacity(0.6),
          progressColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CmeProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
