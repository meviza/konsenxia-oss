import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Atom — KxVitalChip
///
/// Vital bulgu göstergesi. Değer + birim + etiket.
/// Normal/Anormal/Kritik durumlara göre renk değişir.
///
/// Kullanım:
/// ```dart
/// KxVitalChip(
///   label: 'KB',
///   value: '135/88',
///   unit: 'mmHg',
///   status: KxVitalStatus.warning,
/// )
/// KxVitalChip.bloodPressure(systolic: 135, diastolic: 88)
/// KxVitalChip.heartRate(bpm: 94)
/// KxVitalChip.spo2(percent: 97)
/// KxVitalChip.temperature(celsius: 37.2)
/// ```
enum KxVitalStatus { normal, warning, critical, unknown }

class KxVitalChip extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final KxVitalStatus status;
  final bool compact;

  const KxVitalChip({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.status = KxVitalStatus.normal,
    this.compact = false,
  });

  // ── Named constructors (otomatik normal aralık kontrolü) ─────

  factory KxVitalChip.bloodPressure({
    required int systolic,
    required int diastolic,
    bool compact = false,
  }) {
    final status = switch (systolic) {
      <= 90  => KxVitalStatus.critical,
      <= 119 => KxVitalStatus.normal,
      <= 139 => KxVitalStatus.warning,
      _      => KxVitalStatus.critical,
    };
    return KxVitalChip(
      label: 'KB',
      value: '$systolic/$diastolic',
      unit: 'mmHg',
      status: status,
      compact: compact,
    );
  }

  factory KxVitalChip.heartRate({
    required int bpm,
    bool compact = false,
  }) {
    final status = switch (bpm) {
      < 50   => KxVitalStatus.critical,
      <= 60  => KxVitalStatus.warning,
      <= 100 => KxVitalStatus.normal,
      <= 120 => KxVitalStatus.warning,
      _      => KxVitalStatus.critical,
    };
    return KxVitalChip(
      label: 'Nabız',
      value: '$bpm',
      unit: 'bpm',
      status: status,
      compact: compact,
    );
  }

  factory KxVitalChip.spo2({
    required int percent,
    bool compact = false,
  }) {
    final status = switch (percent) {
      >= 95  => KxVitalStatus.normal,
      >= 90  => KxVitalStatus.warning,
      _      => KxVitalStatus.critical,
    };
    return KxVitalChip(
      label: 'SpO₂',
      value: '$percent',
      unit: '%',
      status: status,
      compact: compact,
    );
  }

  factory KxVitalChip.temperature({
    required double celsius,
    bool compact = false,
  }) {
    final status = switch (celsius) {
      < 36.0  => KxVitalStatus.warning,
      <= 37.5 => KxVitalStatus.normal,
      <= 38.5 => KxVitalStatus.warning,
      _       => KxVitalStatus.critical,
    };
    return KxVitalChip(
      label: 'Ateş',
      value: celsius.toStringAsFixed(1),
      unit: '°C',
      status: status,
      compact: compact,
    );
  }

  factory KxVitalChip.glucose({
    required int mgdl,
    bool compact = false,
  }) {
    final status = switch (mgdl) {
      < 70   => KxVitalStatus.critical,
      <= 99  => KxVitalStatus.normal,
      <= 125 => KxVitalStatus.warning,
      _      => KxVitalStatus.critical,
    };
    return KxVitalChip(
      label: 'Glukoz',
      value: '$mgdl',
      unit: 'mg/dL',
      status: status,
      compact: compact,
    );
  }

  /// Compact modunda yeni bir kopya döndürür (KxCaseCard gibi yerler için)
  KxVitalChip copyWithCompact(bool compact) {
    return KxVitalChip(
      key: key,
      label: label,
      value: value,
      unit: unit,
      status: status,
      compact: compact,
    );
  }

  // ── Style getters ────────────────────────────────────────────

  Color get _valueColor => switch (status) {
    KxVitalStatus.normal   => KxColors.jade300,
    KxVitalStatus.warning  => KxColors.amber300,
    KxVitalStatus.critical => KxColors.crimson300,
    KxVitalStatus.unknown  => KxColors.textSecondary,
  };

  Color get _bgColor => switch (status) {
    KxVitalStatus.normal   => KxColors.jade500.withOpacity(0.06),
    KxVitalStatus.warning  => KxColors.amber500.withOpacity(0.06),
    KxVitalStatus.critical => KxColors.crimson500.withOpacity(0.08),
    KxVitalStatus.unknown  => KxColors.bgCard,
  };

  Color get _borderColor => switch (status) {
    KxVitalStatus.normal   => KxColors.jade500.withOpacity(0.15),
    KxVitalStatus.warning  => KxColors.amber500.withOpacity(0.15),
    KxVitalStatus.critical => KxColors.crimson500.withOpacity(0.2),
    KxVitalStatus.unknown  => KxColors.border,
  };

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: KxTypography.monoLg.copyWith(color: _valueColor),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit!,
                  style: KxTypography.monoSm.copyWith(
                    color: _valueColor.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: KxTypography.overline.copyWith(
              fontSize: 9,
              letterSpacing: 0.8,
              color: KxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: KxSpacing.radiusSm,
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: KxTypography.monoSm.copyWith(color: KxColors.textMuted),
          ),
          const SizedBox(width: 6),
          Text(
            unit != null ? '$value $unit' : value,
            style: KxTypography.monoSm.copyWith(
              color: _valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
