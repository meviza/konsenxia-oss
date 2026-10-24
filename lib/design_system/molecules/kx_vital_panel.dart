import 'package:flutter/material.dart';
import '../atoms/kx_vital_chip.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// KONSENXIA Molecule — KxVitalPanel
///
/// 4 vital bulguyu 2×2 grid'de gösterir.
/// Başlık, grid layout, ve opsiyonel "Vitaller normalin dışında" uyarısı.
///
/// Kullanım:
/// ```dart
/// KxVitalPanel(
///   title: 'Başvuru Vitalleri',
///   vitals: [
///     KxVitalChip.bloodPressure(systolic: 135, diastolic: 88),
///     KxVitalChip.heartRate(bpm: 94),
///     KxVitalChip.spo2(percent: 97),
///     KxVitalChip.temperature(celsius: 37.2),
///   ],
/// )
/// KxVitalPanel.compact(vitals: [...])
/// ```
class KxVitalPanel extends StatelessWidget {
  final List<KxVitalChip> vitals;
  final String? title;
  final bool compact;
  final int crossAxisCount;

  const KxVitalPanel({
    super.key,
    required this.vitals,
    this.title,
    this.compact = false,
    this.crossAxisCount = 2,
  });

  const KxVitalPanel.compact({
    Key? key,
    required List<KxVitalChip> vitals,
    String? title,
  }) : this(key: key, vitals: vitals, title: title, compact: true, crossAxisCount: 4);

  bool get _hasAbnormal => vitals.any(
        (v) =>
            v.status == KxVitalStatus.warning ||
            v.status == KxVitalStatus.critical,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: _hasAbnormal
              ? KxColors.amber500.withOpacity(0.3)
              : KxColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık satırı
          if (title != null) ...[
            Row(
              children: [
                Text(
                  title!.toUpperCase(),
                  style: KxTypography.overline.copyWith(
                    color: KxColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (_hasAbnormal)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: KxColors.amber300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Anormal Değer',
                        style: KxTypography.caption.copyWith(
                          color: KxColors.amber300,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Compact: yatay sıra
          if (compact)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: vitals.map((v) => v.copyWithCompact(true)).toList(),
            )
          // Full: 2×N grid
          else
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: vitals,
            ),
        ],
      ),
    );
  }
}
