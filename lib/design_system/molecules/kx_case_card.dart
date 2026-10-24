import 'package:flutter/material.dart';
import '../atoms/kx_badge.dart';
import '../atoms/kx_avatar.dart';
import '../atoms/kx_tag.dart';
import '../atoms/kx_vital_chip.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_shadows.dart';

/// KONSENXIA Molecule — KxCaseCard
///
/// Vaka kartı. Dashboard feed, Case Hub grid ve liste görünümlerinde kullanılır.
/// compact (feed satırı), standard (grid kartı), featured (öne çıkan büyük kart).
enum KxCaseCardMode { compact, standard, featured }

enum KxCaseUrgency { routine, urgent, critical, emergency }

extension KxCaseUrgencyExt on KxCaseUrgency {
  String get label => switch (this) {
        KxCaseUrgency.routine => 'Rutin',
        KxCaseUrgency.urgent => 'Acil',
        KxCaseUrgency.critical => 'Kritik',
        KxCaseUrgency.emergency => 'Acil Müdahale',
      };

  Color get color => switch (this) {
        KxCaseUrgency.routine => KxColors.teal400,
        KxCaseUrgency.urgent => KxColors.amber300,
        KxCaseUrgency.critical => KxColors.crimson400,
        KxCaseUrgency.emergency => const Color(0xFFFF3B5C),
      };
}

class KxCaseCard extends StatefulWidget {
  final String caseId;
  final String title;
  final String summary;
  final String authorName;
  final String? authorImageUrl;
  final String authorSpecialty;
  final String? authorCountry;
  final KxCaseUrgency urgency;
  final List<String> tags;
  final int viewCount;
  final int commentCount;
  final int likeCount;
  final bool isLiked;
  final bool isBookmarked;
  final bool isSolved;
  final DateTime postedAt;
  final List<KxVitalChip>? vitals;
  final KxCaseCardMode mode;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const KxCaseCard({
    super.key,
    required this.caseId,
    required this.title,
    required this.summary,
    required this.authorName,
    this.authorImageUrl,
    required this.authorSpecialty,
    this.authorCountry,
    this.urgency = KxCaseUrgency.routine,
    this.tags = const [],
    this.viewCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.isSolved = false,
    required this.postedAt,
    this.vitals,
    this.mode = KxCaseCardMode.standard,
    this.onTap,
    this.onLike,
    this.onBookmark,
    this.onShare,
  });

  // ── Named constructors ─────────────────────────────────────────

  const KxCaseCard.compact({
    Key? key,
    required String caseId,
    required String title,
    required String summary,
    required String authorName,
    String? authorImageUrl,
    required String authorSpecialty,
    KxCaseUrgency urgency = KxCaseUrgency.routine,
    List<String> tags = const [],
    int viewCount = 0,
    int commentCount = 0,
    int likeCount = 0,
    bool isLiked = false,
    bool isBookmarked = false,
    bool isSolved = false,
    required DateTime postedAt,
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onBookmark,
  }) : this(
          key: key,
          caseId: caseId,
          title: title,
          summary: summary,
          authorName: authorName,
          authorImageUrl: authorImageUrl,
          authorSpecialty: authorSpecialty,
          urgency: urgency,
          tags: tags,
          viewCount: viewCount,
          commentCount: commentCount,
          likeCount: likeCount,
          isLiked: isLiked,
          isBookmarked: isBookmarked,
          isSolved: isSolved,
          postedAt: postedAt,
          onTap: onTap,
          onLike: onLike,
          onBookmark: onBookmark,
          mode: KxCaseCardMode.compact,
        );

  const KxCaseCard.standard({
    Key? key,
    required String caseId,
    required String title,
    required String summary,
    required String authorName,
    String? authorImageUrl,
    required String authorSpecialty,
    String? authorCountry,
    KxCaseUrgency urgency = KxCaseUrgency.routine,
    List<String> tags = const [],
    int viewCount = 0,
    int commentCount = 0,
    int likeCount = 0,
    bool isLiked = false,
    bool isBookmarked = false,
    bool isSolved = false,
    required DateTime postedAt,
    List<KxVitalChip>? vitals,
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onBookmark,
    VoidCallback? onShare,
  }) : this(
          key: key,
          caseId: caseId,
          title: title,
          summary: summary,
          authorName: authorName,
          authorImageUrl: authorImageUrl,
          authorSpecialty: authorSpecialty,
          authorCountry: authorCountry,
          urgency: urgency,
          tags: tags,
          viewCount: viewCount,
          commentCount: commentCount,
          likeCount: likeCount,
          isLiked: isLiked,
          isBookmarked: isBookmarked,
          isSolved: isSolved,
          postedAt: postedAt,
          vitals: vitals,
          onTap: onTap,
          onLike: onLike,
          onBookmark: onBookmark,
          onShare: onShare,
          mode: KxCaseCardMode.standard,
        );

  const KxCaseCard.featured({
    Key? key,
    required String caseId,
    required String title,
    required String summary,
    required String authorName,
    String? authorImageUrl,
    required String authorSpecialty,
    String? authorCountry,
    KxCaseUrgency urgency = KxCaseUrgency.routine,
    List<String> tags = const [],
    int viewCount = 0,
    int commentCount = 0,
    int likeCount = 0,
    bool isLiked = false,
    bool isBookmarked = false,
    bool isSolved = false,
    required DateTime postedAt,
    List<KxVitalChip>? vitals,
    VoidCallback? onTap,
    VoidCallback? onLike,
    VoidCallback? onBookmark,
    VoidCallback? onShare,
  }) : this(
          key: key,
          caseId: caseId,
          title: title,
          summary: summary,
          authorName: authorName,
          authorImageUrl: authorImageUrl,
          authorSpecialty: authorSpecialty,
          authorCountry: authorCountry,
          urgency: urgency,
          tags: tags,
          viewCount: viewCount,
          commentCount: commentCount,
          likeCount: likeCount,
          isLiked: isLiked,
          isBookmarked: isBookmarked,
          isSolved: isSolved,
          postedAt: postedAt,
          vitals: vitals,
          onTap: onTap,
          onLike: onLike,
          onBookmark: onBookmark,
          onShare: onShare,
          mode: KxCaseCardMode.featured,
        );

  @override
  State<KxCaseCard> createState() => _KxCaseCardState();
}

class _KxCaseCardState extends State<KxCaseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      KxCaseCardMode.compact => _buildCompact(),
      KxCaseCardMode.standard => _buildStandard(),
      KxCaseCardMode.featured => _buildFeatured(),
    };
  }

  // ── Compact — feed satırı ──────────────────────────────────────

  Widget _buildCompact() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: KxSpacing.radiusMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol: urgency accent bar
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: widget.urgency.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Case ID + solved badge
                  Row(
                    children: [
                      Text(
                        widget.caseId,
                        style: KxTypography.caseId,
                      ),
                      const SizedBox(width: 8),
                      if (widget.isSolved)
                        KxBadge.jade('Çözüldü'),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.title,
                    style: KxTypography.labelMd.copyWith(
                      color: KxColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        widget.authorSpecialty,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.teal400,
                        ),
                      ),
                      const Spacer(),
                      _StatIcon(
                        icon: Icons.remove_red_eye_outlined,
                        value: _fmt(widget.viewCount),
                      ),
                      const SizedBox(width: 10),
                      _StatIcon(
                        icon: Icons.chat_bubble_outline,
                        value: widget.commentCount.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Standard — grid kartı ──────────────────────────────────────

  Widget _buildStandard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: KxSpacing.cardPadding,
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: KxSpacing.radiusLg,
            border: Border.all(
              color: _hovered ? KxColors.teal400.withOpacity(0.4) : KxColors.border,
            ),
            boxShadow: _hovered ? KxShadows.cardHover : KxShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır — Case ID + urgency + solved
              Row(
                children: [
                  Text(widget.caseId, style: KxTypography.caseId),
                  const Spacer(),
                  if (widget.isSolved) ...[
                    KxBadge.jade('✓ Çözüldü'),
                    const SizedBox(width: 6),
                  ],
                  KxBadge.urgency(_urgencyToKx(widget.urgency)),
                ],
              ),
              const SizedBox(height: 10),

              // Başlık
              Text(
                widget.title,
                style: KxTypography.headingSm.copyWith(
                  color: KxColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Özet
              Text(
                widget.summary,
                style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Vitals (varsa)
              if (widget.vitals != null && widget.vitals!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.vitals!
                      .map((v) => v.copyWithCompact(true))
                      .toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Etiketler
              if (widget.tags.isNotEmpty) ...[
                KxTagRow(
                  tags: widget.tags.take(3).toList(),
                  isSpecialty: true,
                ),
                const SizedBox(height: 12),
              ],

              // Alt satır — yazar + aksiyonlar
              Row(
                children: [
                  KxAvatar(
                    name: widget.authorName,
                    imageUrl: widget.authorImageUrl,
                    size: KxAvatarSize.xs,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorName,
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _timeAgo(widget.postedAt),
                          style: KxTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  _ActionButtons(
                    likeCount: widget.likeCount,
                    commentCount: widget.commentCount,
                    isLiked: widget.isLiked,
                    isBookmarked: widget.isBookmarked,
                    onLike: widget.onLike,
                    onBookmark: widget.onBookmark,
                    onShare: widget.onShare,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Featured — büyük öne çıkan kart ──────────────────────────

  Widget _buildFeatured() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KxColors.bgCard,
              KxColors.bgElevated,
            ],
          ),
          borderRadius: KxSpacing.radiusXl,
          border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
          boxShadow: KxShadows.tealGlow(opacity: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst — FEATURED badge + urgency
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ÖNE ÇIKAN',
                    style: KxTypography.overline.copyWith(
                      color: KxColors.bgVoid,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                KxBadge.urgency(_urgencyToKx(widget.urgency)),
                const Spacer(),
                Text(widget.caseId, style: KxTypography.caseId),
              ],
            ),
            const SizedBox(height: 14),

            // Başlık — büyük
            Text(
              widget.title,
              style: KxTypography.headingMd.copyWith(
                color: KxColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Özet — daha uzun
            Text(
              widget.summary,
              style: KxTypography.bodyMd.copyWith(
                color: KxColors.textSecondary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Vitals
            if (widget.vitals != null && widget.vitals!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: widget.vitals!
                    .take(4)
                    .map((v) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: v,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 14),

            // Etiketler
            if (widget.tags.isNotEmpty) ...[
              KxTagRow(
                tags: widget.tags.toList(),
                isSpecialty: true,
              ),
              const SizedBox(height: 14),
            ],

            // Ayırıcı
            Divider(color: KxColors.border, height: 1),
            const SizedBox(height: 12),

            // Alt — yazar + stats + aksiyonlar
            Row(
              children: [
                KxAvatar(
                  name: widget.authorName,
                  imageUrl: widget.authorImageUrl,
                  size: KxAvatarSize.sm,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: KxTypography.labelMd.copyWith(
                        color: KxColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.authorCountry != null
                          ? '${widget.authorSpecialty} · ${widget.authorCountry}'
                          : widget.authorSpecialty,
                      style: KxTypography.caption.copyWith(
                        color: KxColors.teal400,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _StatIcon(
                  icon: Icons.remove_red_eye_outlined,
                  value: _fmt(widget.viewCount),
                ),
                const SizedBox(width: 12),
                _ActionButtons(
                  likeCount: widget.likeCount,
                  commentCount: widget.commentCount,
                  isLiked: widget.isLiked,
                  isBookmarked: widget.isBookmarked,
                  onLike: widget.onLike,
                  onBookmark: widget.onBookmark,
                  onShare: widget.onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}sa önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}hf önce';
    return '${(diff.inDays / 30).round()}ay önce';
  }

  KxUrgency _urgencyToKx(KxCaseUrgency u) => switch (u) {
        KxCaseUrgency.routine   => KxUrgency.low,
        KxCaseUrgency.urgent    => KxUrgency.high,
        KxCaseUrgency.critical  => KxUrgency.critical,
        KxCaseUrgency.emergency => KxUrgency.critical,
      };
}

// ── Alt widget'lar ──────────────────────────────────────────────

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatIcon({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: KxColors.textDisabled),
        const SizedBox(width: 3),
        Text(value, style: KxTypography.caption),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const _ActionButtons({
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isBookmarked,
    this.onLike,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        _IconBtn(
          icon: isLiked ? Icons.favorite : Icons.favorite_outline,
          color: isLiked ? KxColors.crimson400 : KxColors.textDisabled,
          label: likeCount > 0 ? likeCount.toString() : null,
          onTap: onLike,
        ),
        const SizedBox(width: 4),
        // Comment count
        _IconBtn(
          icon: Icons.chat_bubble_outline,
          color: KxColors.textDisabled,
          label: commentCount > 0 ? commentCount.toString() : null,
          onTap: null,
        ),
        const SizedBox(width: 4),
        // Bookmark
        _IconBtn(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
          color: isBookmarked ? KxColors.amber300 : KxColors.textDisabled,
          onTap: onBookmark,
        ),
        if (onShare != null) ...[
          const SizedBox(width: 4),
          _IconBtn(
            icon: Icons.share_outlined,
            color: KxColors.textDisabled,
            onTap: onShare,
          ),
        ],
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (label != null) ...[
              const SizedBox(width: 3),
              Text(
                label!,
                style: KxTypography.caption.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
