import 'package:flutter/material.dart';
import '../atoms/kx_badge.dart';
import '../atoms/kx_tag.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import 'kx_case_card.dart' show KxCaseUrgency, KxCaseUrgencyExt;

/// KONSENXIA Molecule — KxCaseFooter
///
/// Vaka kartının alt bölümü: istatistikler + aciliyet + etiketler.
/// KxCaseCard içinde veya bağımsız olarak kullanılabilir.
///
/// Kullanım:
/// ```dart
/// KxCaseFooter(
///   viewCount: 1240,
///   commentCount: 18,
///   likeCount: 34,
///   urgency: KxCaseUrgency.urgent,
///   tags: ['kardiyoloji', 'akut_mi'],
///   isLiked: true,
///   isBookmarked: false,
///   onLike: () {},
///   onBookmark: () {},
/// )
/// ```
class KxCaseFooter extends StatelessWidget {
  final int viewCount;
  final int commentCount;
  final int likeCount;
  final KxCaseUrgency urgency;
  final List<String> tags;
  final bool isLiked;
  final bool isBookmarked;
  final bool isSolved;
  final bool showTags;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const KxCaseFooter({
    super.key,
    required this.viewCount,
    required this.commentCount,
    required this.likeCount,
    this.urgency = KxCaseUrgency.routine,
    this.tags = const [],
    this.isLiked = false,
    this.isBookmarked = false,
    this.isSolved = false,
    this.showTags = true,
    this.onLike,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiketler
        if (showTags && tags.isNotEmpty) ...[
          KxTagRow(tags: tags.take(4).toList(), isSpecialty: true),
          const SizedBox(height: 10),
        ],

        // Alt satır: aciliyet + istatistikler + aksiyonlar
        Row(
          children: [
            // Aciliyet
            _UrgencyDot(urgency: urgency),
            const SizedBox(width: 8),

            // Çözüldü
            if (isSolved) ...[
              KxBadge.jade('✓'),
              const SizedBox(width: 8),
            ],

            const Spacer(),

            // Görüntülenme
            _Stat(
              icon: Icons.remove_red_eye_outlined,
              value: _fmt(viewCount),
            ),
            const SizedBox(width: 12),

            // Yorum
            _Stat(
              icon: Icons.chat_bubble_outline,
              value: commentCount.toString(),
            ),
            const SizedBox(width: 8),

            // Beğeni
            GestureDetector(
              onTap: onLike,
              child: _Stat(
                icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                value: likeCount > 0 ? likeCount.toString() : '',
                color: isLiked ? KxColors.crimson400 : KxColors.textDisabled,
              ),
            ),
            const SizedBox(width: 4),

            // Yer imi
            GestureDetector(
              onTap: onBookmark,
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                size: 16,
                color:
                    isBookmarked ? KxColors.amber300 : KxColors.textDisabled,
              ),
            ),

            if (onShare != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onShare,
                child: Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: KxColors.textDisabled,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _UrgencyDot extends StatelessWidget {
  final KxCaseUrgency urgency;
  const _UrgencyDot({required this.urgency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: urgency.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: urgency.color.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          urgency.label.toUpperCase(),
          style: KxTypography.overline.copyWith(
            color: urgency.color,
            fontSize: 9,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? color;
  const _Stat({required this.icon, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? KxColors.textDisabled;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 3),
          Text(value, style: KxTypography.caption.copyWith(color: c)),
        ],
      ],
    );
  }
}
