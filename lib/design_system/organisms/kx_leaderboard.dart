import 'package:flutter/material.dart';
import '../molecules/kx_doctor_card.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Organism — KxLeaderboard
///
/// Sıralama listesi. Doktorları XP veya katkıya göre sıralar.
/// Podium (ilk 3) + liste görünümü.
///
/// Kullanım:
/// ```dart
/// KxLeaderboard(
///   entries: doctors.asEntries(),
///   title: 'Bu Haftanın Önderleri',
///   showPodium: true,
///   onEntryTap: (entry) {},
/// )
/// KxLeaderboard.compact(entries: entries)
/// ```

class KxLeaderboardEntry {
  final String id;
  final String name;
  final String specialty;
  final String? location;
  final String? imageUrl;
  final int level;
  final String? levelTitle;
  final int score;
  final String scoreLabel;
  final bool isOnline;

  const KxLeaderboardEntry({
    required this.id,
    required this.name,
    required this.specialty,
    this.location,
    this.imageUrl,
    required this.level,
    this.levelTitle,
    required this.score,
    this.scoreLabel = 'XP',
    this.isOnline = false,
  });
}

class KxLeaderboard extends StatelessWidget {
  final List<KxLeaderboardEntry> entries;
  final String? title;
  final bool showPodium;
  final bool compact;
  final ValueChanged<KxLeaderboardEntry>? onEntryTap;
  final int maxVisible;

  const KxLeaderboard({
    super.key,
    required this.entries,
    this.title,
    this.showPodium = true,
    this.compact = false,
    this.onEntryTap,
    this.maxVisible = 10,
  });

  const KxLeaderboard.compact({
    Key? key,
    required List<KxLeaderboardEntry> entries,
    String? title,
    ValueChanged<KxLeaderboardEntry>? onEntryTap,
    int maxVisible = 5,
  }) : this(
          key: key,
          entries: entries,
          title: title,
          showPodium: false,
          compact: true,
          onEntryTap: onEntryTap,
          maxVisible: maxVisible,
        );

  @override
  Widget build(BuildContext context) {
    final visible = entries.take(maxVisible).toList();

    return Container(
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 16,
                    color: KxColors.amber300,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title!,
                    style: KxTypography.headingSm,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Podium (ilk 3)
          if (showPodium && visible.length >= 3) ...[
            _buildPodium(visible.take(3).toList()),
            const SizedBox(height: 4),
            Divider(color: KxColors.border, height: 1),
          ],

          // Liste
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: showPodium && visible.length >= 3
                ? visible.length - 3
                : visible.length,
            separatorBuilder: (_, __) =>
                Divider(color: KxColors.border, height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              final offset = showPodium && visible.length >= 3 ? 3 : 0;
              final entry = visible[i + offset];
              final rank = i + offset + 1;

              return InkWell(
                onTap: () => onEntryTap?.call(entry),
                borderRadius: KxSpacing.radiusMd,
                child: KxDoctorCard.compact(
                  name: entry.name,
                  specialty: entry.specialty,
                  location: entry.location,
                  imageUrl: entry.imageUrl,
                  level: entry.level,
                  isOnline: entry.isOnline,
                  rank: rank,
                  contributionCount: entry.score,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<KxLeaderboardEntry> top3) {
    // Podium sırası: 2., 1., 3.
    final order = [top3[1], top3[0], top3[2]];
    final heights = [56.0, 72.0, 44.0];
    final ranks = [2, 1, 3];
    final medals = ['🥈', '🥇', '🥉'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final e = order[i];
          return GestureDetector(
            onTap: () => onEntryTap?.call(e),
            child: Column(
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 6),
                _PodiumAvatar(
                  name: e.name,
                  rank: ranks[i],
                  isOnline: e.isOnline,
                ),
                const SizedBox(height: 6),
                Text(
                  e.name.split(' ').first,
                  style: KxTypography.labelSm.copyWith(
                    color: KxColors.textPrimary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_fmt(e.score)} ${e.scoreLabel}',
                  style: KxTypography.monoSm.copyWith(
                    color: KxColors.teal400,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: _podiumColor(ranks[i]),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${ranks[i]}',
                    style: KxTypography.monoSm.copyWith(
                      color: _rankTextColor(ranks[i]),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _podiumColor(int rank) => switch (rank) {
        1 => KxColors.amber500.withOpacity(0.15),
        2 => const Color(0xFF94A3B8).withOpacity(0.1),
        _ => const Color(0xFFB45309).withOpacity(0.08),
      };

  Color _rankTextColor(int rank) => switch (rank) {
        1 => KxColors.amber300,
        2 => const Color(0xFF94A3B8),
        _ => const Color(0xFFB45309),
      };

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _PodiumAvatar extends StatelessWidget {
  final String name;
  final int rank;
  final bool isOnline;
  const _PodiumAvatar({required this.name, required this.rank, required this.isOnline});

  Color get _ringColor => switch (rank) {
        1 => KxColors.amber300,
        2 => const Color(0xFF94A3B8),
        _ => const Color(0xFFB45309),
      };

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: KxColors.bgElevated,
            border: Border.all(color: _ringColor, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: KxTypography.labelMd.copyWith(
              color: KxColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: KxColors.jade300,
                shape: BoxShape.circle,
                border: Border.all(color: KxColors.bgCard, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
