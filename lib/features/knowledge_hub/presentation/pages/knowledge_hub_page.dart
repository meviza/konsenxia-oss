import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/hub_cases_bloc.dart';
import '../bloc/hub_cases_event.dart';
import '../bloc/hub_cases_state.dart';
import '../../domain/entities/hub_case_entity.dart';

/// KONSENXIA Knowledge Hub
///
/// Eğitim amaçlı tıbbi vaka kütüphanesi. Klinik inci, nadir hastalıklar,
/// öğretici vakalar ve uzmanlık kılavuzları.
class KnowledgeHubPage extends StatefulWidget {
  const KnowledgeHubPage({super.key});

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<HubCasesBloc>().add(const LoadHubCasesEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      context.read<HubCasesBloc>().add(const LoadMoreHubCasesEvent());
      // Reset the flag after a short delay to allow the next load-more
      Future.delayed(const Duration(milliseconds: 500), () {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/knowledge-hub/new'),
        backgroundColor: KxColors.teal400,
        foregroundColor: KxColors.bgVoid,
        icon: const Icon(Icons.add_rounded),
        label: Text('Vaka Ekle', style: KxTypography.labelMd),
      ),
      body: isWide ? _wide() : _narrow(),
    );
  }

  Widget _wide() => _content();

  Widget _narrow() => _content();

  Widget _content() {
    return BlocBuilder<HubCasesBloc, HubCasesState>(
      builder: (context, state) {
        final isLoaded = state is HubCasesLoaded;
        final count = isLoaded ? state.cases.length : 0;
        final activeCategory =
            isLoaded ? state.activeCategory : HubCaseCategory.all;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverAppBar(
              backgroundColor: KxColors.bgBase,
              floating: true,
              snap: true,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Knowledge Hub', style: KxTypography.headingMd),
                  Text(
                    state is HubCasesLoaded
                        ? '$count eğitim vakası'
                        : 'Yükleniyor...',
                    style: KxTypography.caption
                        .copyWith(color: KxColors.teal400),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded,
                      color: KxColors.textSecondary),
                  onPressed: () => context.go('/search'),
                ),
              ],
            ),

            // ── Kategori filtresi ─────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: HubCaseCategory.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = HubCaseCategory.values[i];
                    final isSelected = cat == activeCategory;
                    return GestureDetector(
                      onTap: () => context
                          .read<HubCasesBloc>()
                          .add(FilterHubCasesEvent(cat)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KxColors.teal400.withOpacity(0.12)
                              : KxColors.bgCard,
                          borderRadius: KxSpacing.radiusPill,
                          border: Border.all(
                            color: isSelected
                                ? KxColors.teal400.withOpacity(0.5)
                                : KxColors.border,
                          ),
                        ),
                        child: Text(
                          cat.label,
                          style: KxTypography.labelSm.copyWith(
                            color: isSelected
                                ? KxColors.teal400
                                : KxColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Loading skeleton ──────────────────────────────────
            if (state is HubCasesLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: _HubCardSkeleton(),
                    ),
                    childCount: 5,
                  ),
                ),
              ),

            // ── Error state ───────────────────────────────────────
            if (state is HubCasesError)
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
                            .read<HubCasesBloc>()
                            .add(const RefreshHubCasesEvent()),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Empty state ─────────────────────────────────────────
            if (state is HubCasesLoaded && state.cases.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_information_outlined, size: 64, color: KxColors.teal400.withOpacity(0.4)),
                        const SizedBox(height: 20),
                        Text('Bilgi Merkezi', style: KxTypography.displaySm.copyWith(color: KxColors.textPrimary)),
                        const SizedBox(height: 12),
                        Text(
                          'Doktorlar arasi klinik vaka paylasim platformu.\n\nBurada uzmanlar ilginc vakalari paylasiyor,\ntartisiyor ve birbirinden ogreniyor.',
                          textAlign: TextAlign.center,
                          style: KxTypography.bodyLg.copyWith(color: KxColors.textSecondary, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: KxColors.teal400.withOpacity(0.08),
                            borderRadius: KxSpacing.radiusLg,
                            border: Border.all(color: KxColors.teal400.withOpacity(0.2)),
                          ),
                          child: const Column(
                            children: [
                              _FeatureRow(icon: Icons.cases_rounded, text: 'Gercek klinik vakalar'),
                              SizedBox(height: 8),
                              _FeatureRow(icon: Icons.forum_rounded, text: 'Uzman tartismalari'),
                              SizedBox(height: 8),
                              _FeatureRow(icon: Icons.emoji_events_rounded, text: 'XP ve skor sistemi'),
                              SizedBox(height: 8),
                              _FeatureRow(icon: Icons.search_rounded, text: 'ICD ve uzmanlik bazli arama'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Yakin zamanda icerikler eklenecek',
                          style: KxTypography.caption.copyWith(color: KxColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Loaded: Pinned section ────────────────────────────
            if (state is HubCasesLoaded && state.cases.isNotEmpty) ...[
              // Pre-compute pinned/unpinned lists ONCE to avoid
              // re-filtering on every builder callback invocation.
              ...() {
                final showPinnedSection = !state.isSearchResult &&
                    activeCategory == HubCaseCategory.all;
                final pinnedCases = showPinnedSection
                    ? state.cases.where((c) => c.isPinned).toList()
                    : <HubCaseEntity>[];
                final unpinnedCases = showPinnedSection
                    ? state.cases.where((c) => !c.isPinned).toList()
                    : state.cases;
                return <Widget>[
              if (pinnedCases.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin_rounded,
                            size: 14, color: KxColors.amber300),
                        const SizedBox(width: 6),
                        Text('Öne Çıkanlar',
                            style: KxTypography.labelSm
                                .copyWith(color: KxColors.amber300)),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RepaintBoundary(
                            child: _HubCard(
                              caseEntity: pinnedCases[i],
                              onTap: () => context
                                  .go('/knowledge-hub/${pinnedCases[i].id}'),
                              onLike: () =>
                                  context.read<HubCasesBloc>().add(
                                        LikeHubCaseEvent(
                                          caseId: pinnedCases[i].id,
                                          isCurrentlyLiked:
                                              pinnedCases[i].isLikedByCurrentUser,
                                        ),
                                      ),
                            ),
                          ),
                        );
                      },
                      childCount: pinnedCases.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.library_books_rounded,
                            size: 14, color: KxColors.textMuted),
                        const SizedBox(width: 6),
                        Text('Tüm Vakalar',
                            style: KxTypography.labelSm
                                .copyWith(color: KxColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],

              // ── Main list ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RepaintBoundary(
                          child: _HubCard(
                            caseEntity: unpinnedCases[i],
                            onTap: () =>
                                context.go('/knowledge-hub/${unpinnedCases[i].id}'),
                            onLike: () =>
                                context.read<HubCasesBloc>().add(
                                      LikeHubCaseEvent(
                                        caseId: unpinnedCases[i].id,
                                        isCurrentlyLiked:
                                            unpinnedCases[i].isLikedByCurrentUser,
                                      ),
                                    ),
                          ),
                        ),
                      );
                    },
                    childCount: unpinnedCases.length,
                  ),
                ),
              ),

              // ── Load more indicator ─────────────────────────────
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: KxColors.teal400,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── End of list notice ──────────────────────────────
              if (!state.hasMore && state.cases.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Tüm vakalar görüntülendi.',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted),
                      ),
                    ),
                  ),
                ),

              // ── Inline error (load more failed) ────────────────
              if (state.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      state.errorMessage!,
                      style: KxTypography.caption
                          .copyWith(color: KxColors.crimson300),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ]; // end of IIFE return list
              }(), // end of IIFE
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

}

// ── Hub Card ─────────────────────────────────────────────────────

class _HubCard extends StatelessWidget {
  final HubCaseEntity caseEntity;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _HubCard({
    required this.caseEntity,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: caseEntity.isPinned
                ? KxColors.amber300.withOpacity(0.3)
                : KxColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _CategoryBadge(category: caseEntity.category),
                const SizedBox(width: 8),
                _DifficultyBadge(difficulty: caseEntity.difficulty),
                const Spacer(),
                if (caseEntity.isPinned)
                  const Icon(Icons.push_pin_rounded,
                      size: 14, color: KxColors.amber300),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(caseEntity.title, style: KxTypography.headingSm),
            const SizedBox(height: 6),

            // Abstract
            Text(
              caseEntity.abstract_,
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Tags
            if (caseEntity.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    caseEntity.tags.take(4).map((t) => KxTag(t)).toList(),
              ),
            if (caseEntity.tags.isNotEmpty) const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                KxAvatar(
                  name: caseEntity.authorName,
                  imageUrl: caseEntity.authorPhotoUrl,
                  size: KxAvatarSize.xs,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(caseEntity.authorName,
                          style: KxTypography.labelSm),
                      Text(caseEntity.authorSpecialty,
                          style: KxTypography.caption
                              .copyWith(color: KxColors.textMuted)),
                    ],
                  ),
                ),
                Icon(Icons.remove_red_eye_outlined,
                    size: 14, color: KxColors.textMuted),
                const SizedBox(width: 4),
                Text(_fmt(caseEntity.viewCount),
                    style: KxTypography.monoSm
                        .copyWith(color: KxColors.textMuted)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onLike,
                  child: Icon(
                    caseEntity.isLikedByCurrentUser
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 14,
                    color: KxColors.crimson300,
                  ),
                ),
                const SizedBox(width: 4),
                Text(caseEntity.likeCount.toString(),
                    style: KxTypography.monoSm
                        .copyWith(color: KxColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

// ── Skeleton ─────────────────────────────────────────────────────

class _HubCardSkeleton extends StatelessWidget {
  const _HubCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KxColors.bgCard,
      highlightColor: KxColors.bgSurface,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SkeletonBox(width: 80, height: 20),
                const SizedBox(width: 8),
                _SkeletonBox(width: 50, height: 20),
              ],
            ),
            const SizedBox(height: 10),
            _SkeletonBox(width: double.infinity, height: 18),
            const SizedBox(height: 6),
            _SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            _SkeletonBox(width: 240, height: 14),
            const SizedBox(height: 12),
            Row(
              children: [
                const _SkeletonBox(width: 32, height: 32, isCircle: true),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 100, height: 12),
                    const SizedBox(height: 4),
                    _SkeletonBox(width: 70, height: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: isCircle
              ? BorderRadius.circular(height / 2)
              : KxSpacing.radiusSm,
        ),
      );
}

// ── Category Badge ────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final HubCaseCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      HubCaseCategory.clinicalPearl     => KxColors.amber300,
      HubCaseCategory.rareDisease       => KxColors.crimson300,
      HubCaseCategory.diagnosticPitfall => KxColors.blue400,
      HubCaseCategory.caseSeries        => KxColors.jade300,
      HubCaseCategory.guidelines        => KxColors.teal400,
      HubCaseCategory.all               => KxColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: KxSpacing.radiusPill,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        category.label,
        style: KxTypography.caption.copyWith(color: color),
      ),
    );
  }
}

// ── Feature Row (empty state) ─────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: KxColors.teal400),
        const SizedBox(width: 10),
        Text(text, style: KxTypography.labelMd.copyWith(color: KxColors.textPrimary)),
      ],
    );
  }
}

// ── Difficulty Badge ──────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final HubDifficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      HubDifficulty.beginner     => KxColors.jade300,
      HubDifficulty.intermediate => KxColors.amber300,
      HubDifficulty.advanced     => KxColors.crimson300,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: KxSpacing.radiusPill,
      ),
      child: Text(
        difficulty.label,
        style:
            KxTypography.caption.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}
