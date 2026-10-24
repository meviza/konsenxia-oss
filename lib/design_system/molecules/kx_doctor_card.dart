import 'package:flutter/material.dart';
import '../atoms/kx_avatar.dart';
import '../atoms/kx_badge.dart';
import '../atoms/kx_progress_bar.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Molecule — KxDoctorCard
///
/// Doktor profil kartı. Sidebar, leaderboard ve profil ekranlarında kullanılır.
/// Compact (liste satırı) ve full (profil kartı) olmak üzere iki mod.
enum KxDoctorCardMode { compact, full }

class KxDoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String? location;
  final String? imageUrl;
  final int? level;
  final String? levelTitle;
  final int? caseCount;
  final int? contributionCount;
  final int? countryCount;
  final bool isOnline;
  final int? rank;
  final int? xpCurrent;
  final int? xpTotal;
  final VoidCallback? onTap;
  final KxDoctorCardMode mode;

  const KxDoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    this.location,
    this.imageUrl,
    this.level,
    this.levelTitle,
    this.caseCount,
    this.contributionCount,
    this.countryCount,
    this.isOnline = false,
    this.rank,
    this.xpCurrent,
    this.xpTotal,
    this.onTap,
    this.mode = KxDoctorCardMode.compact,
  });

  const KxDoctorCard.compact({
    Key? key,
    required String name,
    required String specialty,
    String? location,
    String? imageUrl,
    int? level,
    bool isOnline = false,
    int? rank,
    int? contributionCount,
    VoidCallback? onTap,
  }) : this(
          key: key,
          name: name,
          specialty: specialty,
          location: location,
          imageUrl: imageUrl,
          level: level,
          isOnline: isOnline,
          rank: rank,
          contributionCount: contributionCount,
          onTap: onTap,
          mode: KxDoctorCardMode.compact,
        );

  const KxDoctorCard.full({
    Key? key,
    required String name,
    required String specialty,
    String? location,
    String? imageUrl,
    int? level,
    String? levelTitle,
    int? caseCount,
    int? contributionCount,
    int? countryCount,
    int? xpCurrent,
    int? xpTotal,
    VoidCallback? onTap,
  }) : this(
          key: key,
          name: name,
          specialty: specialty,
          location: location,
          imageUrl: imageUrl,
          level: level,
          levelTitle: levelTitle,
          caseCount: caseCount,
          contributionCount: contributionCount,
          countryCount: countryCount,
          xpCurrent: xpCurrent,
          xpTotal: xpTotal,
          onTap: onTap,
          mode: KxDoctorCardMode.full,
        );

  @override
  Widget build(BuildContext context) {
    return mode == KxDoctorCardMode.compact
        ? _buildCompact(context)
        : _buildFull(context);
  }

  // ── Compact — liste satırı (sidebar, leaderboard) ─────────────

  Widget _buildCompact(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: KxSpacing.radiusMd,
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Sıralama numarası
            if (rank != null) ...[
              SizedBox(
                width: 22,
                child: Text(
                  rank.toString().padLeft(2, '0'),
                  style: KxTypography.monoSm.copyWith(
                    color: _rankColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Avatar
            KxAvatar(
              name: name,
              imageUrl: imageUrl,
              size: KxAvatarSize.sm,
              isOnline: isOnline,
              showLevelRing: level != null && level! >= 7,
              level: level,
            ),

            const SizedBox(width: 10),

            // İsim + uzmanlık
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    location != null
                        ? '$specialty · $location'
                        : specialty,
                    style: KxTypography.caption.copyWith(
                      color: KxColors.teal400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Katkı puanı
            if (contributionCount != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatNumber(contributionCount!),
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Full — profil kartı ──────────────────────────────────────

  Widget _buildFull(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: KxSpacing.cardPadding,
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusLg,
          border: Border.all(color: KxColors.border),
        ),
        child: Column(
          children: [
            // Üst satır — avatar + isim + level
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KxAvatar(
                  name: name,
                  imageUrl: imageUrl,
                  size: KxAvatarSize.lg,
                  isOnline: isOnline,
                  showLevelRing: level != null,
                  level: level,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: KxTypography.headingMd,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialty,
                        style: KxTypography.labelSm.copyWith(
                          color: KxColors.teal400,
                          fontFamily: 'IBM Plex Mono',
                        ),
                      ),
                      if (location != null) ...[
                        const SizedBox(height: 2),
                        Text(location!, style: KxTypography.caption),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (level != null)
                            KxBadge.amber('Lvl $level'),
                          if (levelTitle != null) ...[
                            const SizedBox(width: 6),
                            KxBadge.teal(levelTitle!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İstatistik üçlüsü
            if (caseCount != null ||
                contributionCount != null ||
                countryCount != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: KxColors.bgElevated,
                  borderRadius: KxSpacing.radiusMd,
                ),
                child: Row(
                  children: [
                    if (caseCount != null)
                      Expanded(
                        child: _StatCell(
                          value: _formatNumber(caseCount!),
                          label: 'Vakalar',
                        ),
                      ),
                    if (contributionCount != null)
                      Expanded(
                        child: _StatCell(
                          value: _formatNumber(contributionCount!),
                          label: 'Katkılar',
                        ),
                      ),
                    if (countryCount != null)
                      Expanded(
                        child: _StatCell(
                          value: countryCount.toString(),
                          label: 'Ülkeler',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // XP Bar
            if (xpCurrent != null && xpTotal != null && level != null) ...[
              KxProgressBar.xp(
                current: xpCurrent!,
                total: xpTotal!,
                level: level!,
                levelName: levelTitle ?? 'Hekim',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _rankColor => switch (rank) {
        1 => KxColors.amber300,
        2 => const Color(0xFF94A3B8),
        3 => const Color(0xFFB45309),
        _ => KxColors.textDisabled,
      };

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: KxTypography.monoMd.copyWith(
            color: KxColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: KxTypography.caption),
      ],
    );
  }
}
