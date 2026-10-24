import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Organism — KxActivityFeed
///
/// Zaman akışı / aktivite geçmişi.
/// Vaka paylaşımı, katkı, XP kazanımı, mesaj gibi olayları gösterir.
///
/// Kullanım:
/// ```dart
/// KxActivityFeed(
///   activities: activities,
///   title: 'Son Aktiviteler',
/// )
/// ```

enum KxActivityType {
  casePosted,
  caseContributed,
  caseSolved,
  xpEarned,
  levelUp,
  message,
  mention,
  bookmarked,
}

extension KxActivityTypeExt on KxActivityType {
  IconData get icon => switch (this) {
        KxActivityType.casePosted => Icons.add_circle_outline_rounded,
        KxActivityType.caseContributed => Icons.rate_review_outlined,
        KxActivityType.caseSolved => Icons.check_circle_outline_rounded,
        KxActivityType.xpEarned => Icons.star_outline_rounded,
        KxActivityType.levelUp => Icons.military_tech_outlined,
        KxActivityType.message => Icons.chat_bubble_outline_rounded,
        KxActivityType.mention => Icons.alternate_email_rounded,
        KxActivityType.bookmarked => Icons.bookmark_outline_rounded,
      };

  Color get color => switch (this) {
        KxActivityType.casePosted => KxColors.teal400,
        KxActivityType.caseContributed => KxColors.blue400,
        KxActivityType.caseSolved => KxColors.jade300,
        KxActivityType.xpEarned => KxColors.amber300,
        KxActivityType.levelUp => KxColors.amber500,
        KxActivityType.message => KxColors.teal300,
        KxActivityType.mention => KxColors.blue300,
        KxActivityType.bookmarked => KxColors.amber300,
      };
}

class KxActivity {
  final String id;
  final KxActivityType type;
  final String actorName;
  final String? actorImageUrl;
  final String description;
  final String? targetTitle;
  final String? targetId;
  final DateTime time;
  final int? xpGained;
  final bool isRead;
  final VoidCallback? onTap;

  const KxActivity({
    required this.id,
    required this.type,
    required this.actorName,
    this.actorImageUrl,
    required this.description,
    this.targetTitle,
    this.targetId,
    required this.time,
    this.xpGained,
    this.isRead = true,
    this.onTap,
  });
}

class KxActivityFeed extends StatelessWidget {
  final List<KxActivity> activities;
  final String? title;
  final bool compact;
  final int maxVisible;
  final VoidCallback? onSeeAll;

  const KxActivityFeed({
    super.key,
    required this.activities,
    this.title,
    this.compact = false,
    this.maxVisible = 20,
    this.onSeeAll,
  });

  const KxActivityFeed.compact({
    Key? key,
    required List<KxActivity> activities,
    String? title,
    int maxVisible = 5,
    VoidCallback? onSeeAll,
  }) : this(
          key: key,
          activities: activities,
          title: title,
          compact: true,
          maxVisible: maxVisible,
          onSeeAll: onSeeAll,
        );

  @override
  Widget build(BuildContext context) {
    final visible = activities.take(maxVisible).toList();

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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Text(title!, style: KxTypography.headingSm),
                  const Spacer(),
                  if (onSeeAll != null)
                    GestureDetector(
                      onTap: onSeeAll,
                      child: Text(
                        'Tümünü Gör',
                        style: KxTypography.labelSm.copyWith(
                          color: KxColors.teal400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: KxColors.border, height: 1),
          ],

          // Aktiviteler
          if (visible.isEmpty)
            _EmptyState()
          else
            Column(
              children: visible
                  .asMap()
                  .entries
                  .map((e) => _ActivityItem(
                        activity: e.value,
                        isLast: e.key == visible.length - 1,
                        compact: compact,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final KxActivity activity;
  final bool isLast;
  final bool compact;

  const _ActivityItem({
    required this.activity,
    required this.isLast,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: activity.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: activity.isRead
              ? Colors.transparent
              : KxColors.teal400.withOpacity(0.04),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zaman çizgisi
              SizedBox(
                width: 52,
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    // İkon
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: activity.type.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activity.type.color.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        activity.type.icon,
                        size: 14,
                        color: activity.type.color,
                      ),
                    ),
                    // Bağlantı çizgisi
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1,
                          margin: const EdgeInsets.only(left: 31, top: 4),
                          color: KxColors.border,
                        ),
                      ),
                  ],
                ),
              ),

              // İçerik
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      8, 12, 16, compact ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aktör + aksiyon
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: activity.actorName,
                              style: KxTypography.labelSm.copyWith(
                                color: KxColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: ' ${activity.description}',
                              style: KxTypography.bodyMd.copyWith(
                                color: KxColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hedef başlık
                      if (activity.targetTitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          activity.targetTitle!,
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.teal400,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // XP kazanımı + zaman
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _timeAgo(activity.time),
                            style: KxTypography.caption,
                          ),
                          if (activity.xpGained != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: KxColors.amber500.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${activity.xpGained} XP',
                                style: KxTypography.monoSm.copyWith(
                                  color: KxColors.amber300,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Okunmadı göstergesi
              if (!activity.isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 14),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: KxColors.teal400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours < 24) return '${diff.inHours}sa';
    if (diff.inDays < 7) return '${diff.inDays}g';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}hf';
    return '${(diff.inDays / 30).round()}ay';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 32,
              color: KxColors.textDisabled,
            ),
            const SizedBox(height: 8),
            Text(
              'Henüz aktivite yok',
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
