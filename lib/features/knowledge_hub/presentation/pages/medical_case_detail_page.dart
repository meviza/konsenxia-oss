import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/hub_case_detail_bloc.dart';
import '../bloc/hub_case_detail_event.dart';
import '../bloc/hub_case_detail_state.dart';
import '../../domain/entities/hub_case_entity.dart';

/// KONSENXIA Knowledge Hub — Eğitim Vaka Detayı
class MedicalCaseDetailPage extends StatefulWidget {
  final String caseId;
  const MedicalCaseDetailPage({super.key, required this.caseId});

  @override
  State<MedicalCaseDetailPage> createState() => _MedicalCaseDetailPageState();
}

class _MedicalCaseDetailPageState extends State<MedicalCaseDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<HubCaseDetailBloc>()
        .add(LoadHubCaseDetailEvent(widget.caseId));
  }

  void _shareCase(BuildContext context, HubCaseEntity hubCase) {
    final text = '${hubCase.title} — Konsenxia Knowledge Hub\n'
        'https://konsenxia.app/knowledge-hub/${hubCase.id}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link kopyalandı'),
        backgroundColor: KxColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HubCaseDetailBloc, HubCaseDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: KxColors.bgBase,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ─────────────────────────────────────────
              SliverAppBar(
                backgroundColor: KxColors.bgSurface,
                floating: false,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: KxColors.textPrimary, size: 18),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/knowledge-hub'),
                ),
                title: Text('Knowledge Hub',
                    style: KxTypography.labelMd
                        .copyWith(color: KxColors.textSecondary)),
                actions: [
                  if (state is HubCaseDetailLoaded) ...[
                    IconButton(
                      icon: Icon(
                        state.hubCase.isBookmarkedByCurrentUser
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: state.hubCase.isBookmarkedByCurrentUser
                            ? KxColors.teal400
                            : KxColors.textSecondary,
                      ),
                      onPressed: () => context
                          .read<HubCaseDetailBloc>()
                          .add(const BookmarkHubCaseDetailEvent()),
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.bookmark_border_rounded,
                          color: KxColors.textSecondary),
                      onPressed: null,
                    ),
                  ],
                  if (state is HubCaseDetailLoaded)
                    IconButton(
                      icon: const Icon(Icons.share_rounded,
                          color: KxColors.textSecondary),
                      onPressed: () => _shareCase(
                        context,
                        (state as HubCaseDetailLoaded).hubCase,
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.share_rounded,
                          color: KxColors.textSecondary),
                      onPressed: null,
                    ),
                ],
              ),

              // ── Loading ──────────────────────────────────────────
              if (state is HubCaseDetailLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: KxColors.teal400),
                  ),
                ),

              // ── Error ────────────────────────────────────────────
              if (state is HubCaseDetailError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 40, color: KxColors.crimson300),
                        const SizedBox(height: 12),
                        Text(state.message, style: KxTypography.bodyMd),
                        const SizedBox(height: 16),
                        KxButton.secondary(
                          label: 'Tekrar Dene',
                          onPressed: () => context
                              .read<HubCaseDetailBloc>()
                              .add(LoadHubCaseDetailEvent(widget.caseId)),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Content ──────────────────────────────────────────
              if (state is HubCaseDetailLoaded)
                SliverToBoxAdapter(
                  child: _DetailContent(
                    hubCase: state.hubCase,
                    onLike: () => context
                        .read<HubCaseDetailBloc>()
                        .add(const LikeHubCaseDetailEvent()),
                    onBookmark: () => context
                        .read<HubCaseDetailBloc>()
                        .add(const BookmarkHubCaseDetailEvent()),
                    onShare: () => _shareCase(context, state.hubCase),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Detail Content ────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  final HubCaseEntity hubCase;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const _DetailContent({
    required this.hubCase,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category + difficulty ──────────────────────────────
          Row(
            children: [
              _Chip(
                  label: hubCase.category.label,
                  color: _categoryColor(hubCase.category)),
              const SizedBox(width: 8),
              _Chip(
                  label: hubCase.difficulty.label,
                  color: _difficultyColor(hubCase.difficulty)),
            ],
          ),
          const SizedBox(height: 14),

          // ── Title ──────────────────────────────────────────────
          Text(hubCase.title, style: KxTypography.headingLg),
          const SizedBox(height: 12),

          // ── Author info ────────────────────────────────────────
          Row(
            children: [
              KxAvatar(
                name: hubCase.authorName,
                imageUrl: hubCase.authorPhotoUrl,
                size: KxAvatarSize.sm,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hubCase.authorName, style: KxTypography.labelMd),
                    Text(hubCase.authorSpecialty,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined,
                      size: 14, color: KxColors.textMuted),
                  const SizedBox(width: 4),
                  Text(_fmt(hubCase.viewCount),
                      style: KxTypography.monoSm
                          .copyWith(color: KxColors.textMuted)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      hubCase.isLikedByCurrentUser
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 14,
                      color: KxColors.crimson300,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(hubCase.likeCount.toString(),
                      style: KxTypography.monoSm
                          .copyWith(color: KxColors.textMuted)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),

          // ── Abstract ───────────────────────────────────────────
          _SectionTitle('Özet',
              icon: Icons.summarize_rounded, color: KxColors.teal400),
          const SizedBox(height: 10),
          _ContentBlock(content: hubCase.abstract_),

          const SizedBox(height: 20),

          // ── Content ────────────────────────────────────────────
          _SectionTitle('Vaka İçeriği',
              icon: Icons.article_rounded, color: KxColors.blue400),
          const SizedBox(height: 10),
          _ContentBlock(content: hubCase.content),

          const SizedBox(height: 20),

          // ── Tags ───────────────────────────────────────────────
          if (hubCase.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: hubCase.tags.map((t) => KxTag(t)).toList(),
            ),
            const SizedBox(height: 24),
          ],

          _Divider(),
          const SizedBox(height: 16),

          // ── Actions ────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _ActionButton(
                icon: hubCase.isLikedByCurrentUser
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${hubCase.likeCount} Beğeni',
                color: KxColors.crimson300,
                onTap: onLike,
              ),
              _ActionButton(
                icon: hubCase.isBookmarkedByCurrentUser
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: hubCase.isBookmarkedByCurrentUser
                    ? 'Kaydedildi'
                    : 'Kaydet',
                color: KxColors.teal400,
                onTap: onBookmark,
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Paylaş',
                color: KxColors.blue400,
                onTap: onShare,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _categoryColor(HubCaseCategory cat) => switch (cat) {
        HubCaseCategory.clinicalPearl     => KxColors.amber300,
        HubCaseCategory.rareDisease       => KxColors.crimson300,
        HubCaseCategory.diagnosticPitfall => KxColors.blue400,
        HubCaseCategory.caseSeries        => KxColors.jade300,
        HubCaseCategory.guidelines        => KxColors.teal400,
        HubCaseCategory.all               => KxColors.textSecondary,
      };

  Color _difficultyColor(HubDifficulty diff) => switch (diff) {
        HubDifficulty.beginner     => KxColors.jade300,
        HubDifficulty.intermediate => KxColors.amber300,
        HubDifficulty.advanced     => KxColors.crimson300,
      };

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

// ── Helpers ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: KxSpacing.radiusPill,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: KxTypography.caption.copyWith(color: color)),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: KxColors.border);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionTitle(this.title, {required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(title,
            style: KxTypography.headingSm.copyWith(color: color)),
      ],
    );
  }
}

class _ContentBlock extends StatelessWidget {
  final String content;
  const _ContentBlock({required this.content});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Text(content,
            style: KxTypography.bodyMd.copyWith(
                color: KxColors.textSecondary, height: 1.7)),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: KxSpacing.radiusMd,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: KxTypography.labelSm.copyWith(color: color)),
            ],
          ),
        ),
      );
}
