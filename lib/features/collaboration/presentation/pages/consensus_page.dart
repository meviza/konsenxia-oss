import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../design_system/design_system.dart';
import '../bloc/consensus_bloc.dart';
import '../bloc/consensus_event.dart';
import '../bloc/consensus_state.dart';
import '../../domain/entities/poll_entity.dart';

/// KONSENXIA Consensus — Doktor Konsensüs Platformu
class ConsensusPage extends StatefulWidget {
  const ConsensusPage({super.key});

  @override
  State<ConsensusPage> createState() => _ConsensusPageState();
}

class _ConsensusPageState extends State<ConsensusPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConsensusBloc>().add(const LoadPollsEvent());
  }

  static const _filterLabels = [
    ('Tümü',    null),
    ('Açık',    PollStatus.open),
    ('Oylamada', PollStatus.voting),
    ('Çözüldü', PollStatus.solved),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _wide() : _narrow(),
    );
  }

  Widget _wide() => Row(
        children: [
          KxSidebar(
            activeItem: KxNavItem.cases,
            onItemSelected: _onNav,
            userName: 'Dr. Kerem',
            userSpecialty: 'Dahiliye',
            userLevel: 8,
            userLevelTitle: 'Uzman',
            xpCurrent: 420,
            xpTotal: 1000,
            isOnline: true,
          ),
          Expanded(child: _content()),
        ],
      );

  Widget _narrow() => _content();

  Widget _content() {
    return BlocBuilder<ConsensusBloc, ConsensusState>(
      builder: (context, state) {
        final activeFilter =
            state is ConsensusLoaded ? state.activeFilter : null;

        return CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────
            SliverAppBar(
              backgroundColor: KxColors.bgBase,
              floating: true,
              snap: true,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Konsensüs', style: KxTypography.headingMd),
                  Text(
                    'Topluluk oylama platformu',
                    style: KxTypography.caption
                        .copyWith(color: KxColors.teal400),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: KxColors.textSecondary),
                  onPressed: () => context
                      .read<ConsensusBloc>()
                      .add(const RefreshPollsEvent()),
                ),
              ],
            ),

            // ── Filtre ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filterLabels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final (label, filterStatus) = _filterLabels[i];
                    final isSelected = activeFilter == filterStatus;
                    return GestureDetector(
                      onTap: () => context
                          .read<ConsensusBloc>()
                          .add(FilterPollsEvent(filterStatus)),
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
                          label,
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

            // ── Loading ─────────────────────────────────────────
            if (state is ConsensusLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: _PollCardSkeleton(),
                    ),
                    childCount: 3,
                  ),
                ),
              ),

            // ── Error ───────────────────────────────────────────
            if (state is ConsensusError)
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
                            .read<ConsensusBloc>()
                            .add(const RefreshPollsEvent()),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Loaded ──────────────────────────────────────────
            if (state is ConsensusLoaded) ...[
              if (state.polls.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Bu kategoride oylama yok.',
                      style: KxTypography.bodyMd
                          .copyWith(color: KxColors.textMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        if (i >= state.polls.length) return null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RepaintBoundary(
                            child: _PollCard(
                              poll: state.polls[i],
                              onVote: (idx) => context
                                  .read<ConsensusBloc>()
                                  .add(VoteOnPollEvent(
                                    pollId: state.polls[i].id,
                                    optionIndex: idx,
                                    isCurrentlyVoted:
                                        state.polls[i].myVoteIndex == idx,
                                  )),
                            ),
                          ),
                        );
                      },
                      childCount: state.polls.length,
                    ),
                  ),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  void _onNav(KxNavItem item) {
    switch (item) {
      case KxNavItem.dashboard:
        context.go('/dashboard');
      case KxNavItem.cases:
        context.go('/cases');
      case KxNavItem.aiChat:
        context.go('/ai-chat');
      case KxNavItem.messages:
        context.go('/messages');
      case KxNavItem.leaderboard:
        context.go('/leaderboard');
      case KxNavItem.analytics:
        context.go('/analytics');
      case KxNavItem.profile:
        context.go('/profile');
    }
  }
}

// ── Poll Card ─────────────────────────────────────────────────────

class _PollCard extends StatelessWidget {
  final PollEntity poll;
  final ValueChanged<int> onVote;

  const _PollCard({required this.poll, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final isSolved = poll.status == PollStatus.solved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: isSolved
              ? KxColors.jade300.withOpacity(0.3)
              : KxColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Row(
            children: [
              _StatusBadge(status: poll.status),
              const SizedBox(width: 8),
              Text(
                poll.caseRef,
                style: KxTypography.monoSm
                    .copyWith(color: KxColors.teal400),
              ),
              const Spacer(),
              Text(
                poll.specialty,
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Question ────────────────────────────────────────
          Text(poll.question, style: KxTypography.headingSm),
          const SizedBox(height: 4),
          Text(
            '${poll.totalVotes} doktor oy kullandı',
            style: KxTypography.caption
                .copyWith(color: KxColors.textMuted),
          ),
          const SizedBox(height: 14),

          // ── Options ─────────────────────────────────────────
          ...poll.options.asMap().entries.map((e) {
            final idx = e.key;
            final opt = e.value;
            final pct = poll.totalVotes > 0
                ? (opt.voteCount / poll.totalVotes)
                : 0.0;
            final isMyVote = poll.myVoteIndex == idx;
            final maxVotes = poll.options
                .map((o) => o.voteCount)
                .fold(0, (a, b) => a > b ? a : b);
            final isLeading = opt.voteCount == maxVotes && maxVotes > 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: isSolved ? null : () => onVote(idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMyVote
                        ? KxColors.teal400.withOpacity(0.08)
                        : KxColors.bgSurface,
                    borderRadius: KxSpacing.radiusMd,
                    border: Border.all(
                      color: isMyVote
                          ? KxColors.teal400.withOpacity(0.5)
                          : isLeading && isSolved
                              ? KxColors.jade300.withOpacity(0.4)
                              : KxColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMyVote
                                  ? KxColors.teal400
                                  : Colors.transparent,
                              border: Border.all(
                                color: isMyVote
                                    ? KxColors.teal400
                                    : KxColors.textMuted,
                                width: 1.5,
                              ),
                            ),
                            child: isMyVote
                                ? const Icon(Icons.check,
                                    size: 12, color: KxColors.bgVoid)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opt.label,
                              style: KxTypography.labelSm.copyWith(
                                color: isLeading && isSolved
                                    ? KxColors.jade300
                                    : KxColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: KxTypography.monoSm.copyWith(
                              color: isMyVote
                                  ? KxColors.teal400
                                  : KxColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      KxProgressBar(
                        value: pct.clamp(0.0, 1.0),
                        variant: isLeading && isSolved
                            ? KxProgressVariant.jade
                            : KxProgressVariant.teal,
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Expert comment ──────────────────────────────────
          if (poll.expertComment != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KxColors.jade300.withOpacity(0.06),
                borderRadius: KxSpacing.radiusMd,
                border: Border.all(
                    color: KxColors.jade300.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 14, color: KxColors.jade300),
                      const SizedBox(width: 6),
                      Text('Uzman Görüşü',
                          style: KxTypography.labelSm
                              .copyWith(color: KxColors.jade300)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(poll.expertComment!,
                      style: KxTypography.bodyMd.copyWith(
                          color: KxColors.textSecondary,
                          fontStyle: FontStyle.italic)),
                  if (poll.expertName != null) ...[
                    const SizedBox(height: 4),
                    Text('— ${poll.expertName}',
                        style: KxTypography.caption
                            .copyWith(color: KxColors.textMuted)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Poll Card Skeleton ────────────────────────────────────────────

class _PollCardSkeleton extends StatelessWidget {
  const _PollCardSkeleton();

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
            _Skel(80, 18),
            const SizedBox(height: 12),
            _Skel(double.infinity, 16),
            const SizedBox(height: 6),
            _Skel(200, 12),
            const SizedBox(height: 14),
            _Skel(double.infinity, 52),
            const SizedBox(height: 10),
            _Skel(double.infinity, 52),
            const SizedBox(height: 10),
            _Skel(double.infinity, 52),
          ],
        ),
      ),
    );
  }
}

class _Skel extends StatelessWidget {
  final double w, h;
  const _Skel(this.w, this.h);

  @override
  Widget build(BuildContext context) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: KxColors.bgSurface,
          borderRadius: KxSpacing.radiusMd,
        ),
      );
}

// ── Status Badge ─────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final PollStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PollStatus.open   => KxColors.teal400,
      PollStatus.voting => KxColors.amber300,
      PollStatus.solved => KxColors.jade300,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: KxSpacing.radiusPill,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(status.label,
              style: KxTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
