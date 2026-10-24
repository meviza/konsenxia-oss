import 'package:flutter/material.dart';
import '../atoms/kx_badge.dart';
import '../atoms/kx_progress_bar.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Molecule — KxXpBar
///
/// XP ilerleme çubuğu molekülü.
/// Seviye, isim, progress bar ve XP rakamlarını birleştirir.
/// Horizontal (profil sayfası) ve vertical (sidebar) layout desteği.
///
/// Kullanım:
/// ```dart
/// KxXpBar(
///   level: 8,
///   levelTitle: 'Uzman Klinisyen',
///   xpCurrent: 2847,
///   xpTotal: 3500,
/// )
/// KxXpBar.minimal(level: 8, xpCurrent: 2847, xpTotal: 3500)
/// KxXpBar.sidebar(level: 8, levelTitle: 'Uzman', xpCurrent: 2847, xpTotal: 3500)
/// ```

/// XP seviye unvanları
class KxLevelSystem {
  static const List<String> _titles = [
    'İntern',           // 1
    'Asistan',          // 2
    'Pratisyen',        // 3
    'Uzman Adayı',      // 4
    'Uzman',            // 5
    'Baş Uzman',        // 6
    'Kıdemli Uzman',    // 7
    'Klinisyen',        // 8
    'Baş Klinisyen',    // 9
    'Konsültan',        // 10
  ];

  static String titleForLevel(int level) {
    final idx = (level - 1).clamp(0, _titles.length - 1);
    return _titles[idx];
  }

  /// Sonraki seviyeye kaç XP kaldığını döndürür
  static int xpForLevel(int level) => level * 500 + (level - 1) * 200;
}

class KxXpBar extends StatelessWidget {
  final int level;
  final String? levelTitle;
  final int xpCurrent;
  final int xpTotal;
  final bool showNextLevel;
  final _KxXpBarVariant _variant;

  const KxXpBar({
    super.key,
    required this.level,
    this.levelTitle,
    required this.xpCurrent,
    required this.xpTotal,
    this.showNextLevel = true,
  }) : _variant = _KxXpBarVariant.full;

  const KxXpBar.minimal({
    Key? key,
    required int level,
    required int xpCurrent,
    required int xpTotal,
  }) : this(
          key: key,
          level: level,
          xpCurrent: xpCurrent,
          xpTotal: xpTotal,
          showNextLevel: false,
        );

  const KxXpBar.sidebar({
    Key? key,
    required int level,
    String? levelTitle,
    required int xpCurrent,
    required int xpTotal,
  }) : level = level,
       levelTitle = levelTitle,
       xpCurrent = xpCurrent,
       xpTotal = xpTotal,
       showNextLevel = false,
       _variant = _KxXpBarVariant.sidebar;

  String get _title => levelTitle ?? KxLevelSystem.titleForLevel(level);
  double get _progress => (xpCurrent / xpTotal).clamp(0.0, 1.0);
  int get _remaining => xpTotal - xpCurrent;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _KxXpBarVariant.full => _buildFull(),
      _KxXpBarVariant.sidebar => _buildSidebar(),
    };
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır — seviye + yüzde
          Row(
            children: [
              KxBadge.amber('Lvl $level'),
              const SizedBox(width: 8),
              Text(
                _title,
                style: KxTypography.labelMd.copyWith(
                  color: KxColors.amber300,
                ),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).round()}%',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          KxProgressBar(
            value: _progress,
            variant: KxProgressVariant.teal,
            height: 6,
          ),
          const SizedBox(height: 6),

          // Alt satır — XP değerleri
          Row(
            children: [
              Text(
                '${_fmtXp(xpCurrent)} XP',
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (showNextLevel)
                Text(
                  '${_fmtXp(_remaining)} XP kaldı → Lvl ${level + 1}',
                  style: KxTypography.monoSm.copyWith(
                    color: KxColors.textMuted,
                  ),
                )
              else
                Text(
                  '/ ${_fmtXp(xpTotal)} XP',
                  style: KxTypography.monoSm.copyWith(
                    color: KxColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Lvl $level · $_title',
              style: KxTypography.caption.copyWith(
                color: KxColors.amber300,
              ),
            ),
            const Spacer(),
            Text(
              '${(_progress * 100).round()}%',
              style: KxTypography.monoSm.copyWith(
                color: KxColors.teal400,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        KxProgressBar(
          value: _progress,
          variant: KxProgressVariant.amber,
          height: 3,
        ),
      ],
    );
  }

  String _fmtXp(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

enum _KxXpBarVariant { full, sidebar }
