import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';

/// KONSENXIA — Haftanin Vakasi Widget'i
///
/// Dashboard'da one cikan vaka karti.
/// Altin/amber gradient kenarligi ile vurgulanir.
class CaseOfTheWeek extends StatelessWidget {
  final String caseId;
  final String title;
  final String specialty;
  final int xpReward;
  final int commentCount;
  final int likeCount;

  const CaseOfTheWeek({
    super.key,
    this.caseId = 'KNX-1042',
    this.title = 'Akut ST-Elevasyonlu Miyokard Infarktüsü — Atipik Prezentasyon',
    this.specialty = 'Kardiyoloji',
    this.xpReward = 150,
    this.commentCount = 34,
    this.likeCount = 89,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/cases/$caseId'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: KxSpacing.radiusLg,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF59E0B), // amber500
              Color(0xFFFCD34D), // amber300
              Color(0xFFF59E0B), // amber500
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: KxColors.amber300.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(1.5),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: KxColors.bgCard,
            borderRadius: BorderRadius.circular(14.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Üst: rozet + XP ────────────────────────────
              Row(
                children: [
                  // Haftanin Vakasi rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                      ),
                      borderRadius: KxSpacing.radiusPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            size: 13, color: Color(0xFF78350F)),
                        const SizedBox(width: 4),
                        Text(
                          'Haftanin Vakasi',
                          style: KxTypography.labelSm.copyWith(
                            color: const Color(0xFF78350F),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // XP ödülü
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: KxColors.amber300.withOpacity(0.1),
                      borderRadius: KxSpacing.radiusPill,
                      border: Border.all(
                          color: KxColors.amber300.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded,
                            size: 12, color: KxColors.amber300),
                        const SizedBox(width: 3),
                        Text(
                          '+$xpReward XP',
                          style: KxTypography.caption.copyWith(
                            color: KxColors.amber300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Vaka ID ────────────────────────────────────
              Text(caseId, style: KxTypography.caseId),
              const SizedBox(height: 6),

              // ── Başlık ─────────────────────────────────────
              Text(
                title,
                style: KxTypography.headingSm,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // ── Uzmanlık + istatistikler ───────────────────
              Row(
                children: [
                  KxBadge.teal(specialty),
                  const SizedBox(width: 12),
                  Icon(Icons.favorite_rounded,
                      size: 13, color: KxColors.crimson400),
                  const SizedBox(width: 3),
                  Text('$likeCount',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textSecondary)),
                  const SizedBox(width: 10),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 12, color: KxColors.textMuted),
                  const SizedBox(width: 3),
                  Text('$commentCount',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textSecondary)),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vakaya Git',
                        style: KxTypography.labelSm
                            .copyWith(color: KxColors.amber300),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: KxColors.amber300),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
