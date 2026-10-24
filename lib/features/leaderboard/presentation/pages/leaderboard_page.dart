import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';

/// KONSENXIA — Liderboard Sayfası
///
/// Haftalık / Aylık / Tüm zamanlar filtreli sıralama tablosu.
/// Geniş ekranda sidebar + podium + liste.

enum _LeaderPeriod { weekly, monthly, allTime }

extension _LPLabel on _LeaderPeriod {
  String get label => switch (this) {
        _LeaderPeriod.weekly   => 'Bu Hafta',
        _LeaderPeriod.monthly  => 'Bu Ay',
        _LeaderPeriod.allTime  => 'Tüm Zamanlar',
      };
}

enum _LeaderCategory { xp, cases, contributions }

extension _LCLabel on _LeaderCategory {
  String get label => switch (this) {
        _LeaderCategory.xp            => 'XP',
        _LeaderCategory.cases         => 'Vakalar',
        _LeaderCategory.contributions => 'Katkılar',
      };

  IconData get icon => switch (this) {
        _LeaderCategory.xp            => Icons.bolt_rounded,
        _LeaderCategory.cases         => Icons.folder_open_rounded,
        _LeaderCategory.contributions => Icons.chat_bubble_outline_rounded,
      };
}

// ── Mock data model ───────────────────────────────────────────

class _LeaderEntry {
  final int rank;
  final String name;
  final String specialty;
  final String? country;
  final int level;
  final String levelTitle;
  final int xp;
  final int cases;
  final int contributions;
  final bool isOnline;
  final bool isCurrentUser;

  const _LeaderEntry({
    required this.rank,
    required this.name,
    required this.specialty,
    this.country,
    required this.level,
    required this.levelTitle,
    required this.xp,
    required this.cases,
    required this.contributions,
    this.isOnline = false,
    this.isCurrentUser = false,
  });
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  _LeaderPeriod    _period   = _LeaderPeriod.weekly;
  _LeaderCategory  _category = _LeaderCategory.xp;
  late final TabController _tabCtrl;

  // ── Cached sorted data (recalculated only when _category changes) ──
  late List<_LeaderEntry> _sortedEntries;
  late List<_LeaderEntry> _top3;
  late List<_LeaderEntry> _rest;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _LeaderCategory.values.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final newCategory = _LeaderCategory.values[_tabCtrl.index];
        if (newCategory != _category) {
          _category = newCategory;
          _recalculateSortedEntries();
          setState(() {});
        }
      }
    });
    // Initial calculation
    _recalculateSortedEntries();
  }

  void _recalculateSortedEntries() {
    _sortedEntries = List<_LeaderEntry>.of(_entries)
      ..sort((a, b) => _scoreOf(b).compareTo(_scoreOf(a)));
    _top3 = _sortedEntries.sublist(0, 3);
    _rest = _sortedEntries.sublist(3);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Mock data (constant, allocated once) ──────────────────────

  static const _entries = <_LeaderEntry>[
        _LeaderEntry(
          rank: 1, name: 'Dr. Ayşe Kaya', specialty: 'Kardiyoloji',
          country: 'TR', level: 12, levelTitle: 'Uzman Hekim',
          xp: 8420, cases: 47, contributions: 312, isOnline: true,
        ),
        _LeaderEntry(
          rank: 2, name: 'Dr. Emre Şahin', specialty: 'Nöroloji',
          country: 'TR', level: 11, levelTitle: 'Uzman Hekim',
          xp: 7890, cases: 38, contributions: 287,
        ),
        _LeaderEntry(
          rank: 3, name: 'Dr. Layla Hassan', specialty: 'Acil Tıp',
          country: 'AE', level: 10, levelTitle: 'Kıdemli Hekim',
          xp: 7200, cases: 55, contributions: 201, isOnline: true,
        ),
        _LeaderEntry(
          rank: 4, name: 'Dr. Kerem Çelik', specialty: 'Kardiyoloji',
          country: 'TR', level: 9, levelTitle: 'Kıdemli Hekim',
          xp: 6450, cases: 31, contributions: 178, isCurrentUser: true,
        ),
        _LeaderEntry(
          rank: 5, name: 'Dr. Fatma Yıldız', specialty: 'Dahiliye',
          country: 'TR', level: 9, levelTitle: 'Kıdemli Hekim',
          xp: 6100, cases: 28, contributions: 165,
        ),
        _LeaderEntry(
          rank: 6, name: 'Dr. Omar Al-Rashid', specialty: 'Göğüs Hastalıkları',
          country: 'SA', level: 8, levelTitle: 'Asistan Hekim',
          xp: 5870, cases: 22, contributions: 143, isOnline: true,
        ),
        _LeaderEntry(
          rank: 7, name: 'Dr. Zeynep Arslan', specialty: 'Nefroloji',
          country: 'TR', level: 8, levelTitle: 'Asistan Hekim',
          xp: 5540, cases: 19, contributions: 134,
        ),
        _LeaderEntry(
          rank: 8, name: 'Dr. Mehmet Demir', specialty: 'Gastroenteroloji',
          country: 'TR', level: 7, levelTitle: 'Asistan Hekim',
          xp: 4920, cases: 24, contributions: 98,
        ),
        _LeaderEntry(
          rank: 9, name: 'Dr. Priya Sharma', specialty: 'Endokrinoloji',
          country: 'IN', level: 7, levelTitle: 'Asistan Hekim',
          xp: 4680, cases: 18, contributions: 92, isOnline: true,
        ),
        _LeaderEntry(
          rank: 10, name: 'Dr. Ibrahim Öztürk', specialty: 'Romatoloji',
          country: 'TR', level: 6, levelTitle: 'Resident',
          xp: 4210, cases: 15, contributions: 87,
        ),
      ];

  int _scoreOf(_LeaderEntry e) => switch (_category) {
        _LeaderCategory.xp            => e.xp,
        _LeaderCategory.cases         => e.cases,
        _LeaderCategory.contributions => e.contributions,
      };

  String _scoreLabel(int score) => switch (_category) {
        _LeaderCategory.xp            => '${_formatNum(score)} XP',
        _LeaderCategory.cases         => '$score vaka',
        _LeaderCategory.contributions => '$score katkı',
      };

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        KxSidebar(
          activeItem: KxNavItem.leaderboard,
          initiallyExpanded: false,
          userName: 'Dr. Kerem',
          userSpecialty: 'Kardiyoloji',
          userLevel: 9,
          xpCurrent: 6450,
          xpTotal: 8000,
          onItemSelected: _onNav,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildNarrow() => _buildContent();

  void _onNav(KxNavItem item) {
    switch (item) {
      case KxNavItem.dashboard:   context.go('/dashboard');
      case KxNavItem.cases:       context.go('/cases');
      case KxNavItem.aiChat:      context.go('/ai-chat');
      case KxNavItem.messages:    context.go('/messages');
      case KxNavItem.leaderboard: break;
      case KxNavItem.analytics:   context.go('/analytics');
      case KxNavItem.profile:     context.go('/profile');
    }
  }

  // ── Main content ───────────────────────────────────────────────

  Widget _buildContent() {
    final top3 = _top3;
    final rest = _rest;

    return CustomScrollView(
      slivers: [
        // ── App bar ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: KxColors.bgSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: KxColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Liderboard',
                          style: KxTypography.headingMd
                              .copyWith(color: KxColors.textPrimary)),
                      Text('Topluluk sıralaması',
                          style: KxTypography.caption
                              .copyWith(color: KxColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  // Period selector
                  Container(
                    decoration: BoxDecoration(
                      color: KxColors.bgCard,
                      borderRadius: KxSpacing.radiusMd,
                      border: Border.all(color: KxColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _LeaderPeriod.values.map((p) {
                        final active = p == _period;
                        return GestureDetector(
                          onTap: () => setState(() => _period = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: active
                                  ? KxColors.teal400.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: KxSpacing.radiusMd,
                              border: Border.all(
                                color: active
                                    ? KxColors.teal400.withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              p.label,
                              style: KxTypography.labelSm.copyWith(
                                color: active
                                    ? KxColors.teal400
                                    : KxColors.textMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          expandedHeight: 60,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              color: KxColors.bgSurface,
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: false,
                indicatorColor: KxColors.teal400,
                indicatorWeight: 2,
                labelColor: KxColors.teal400,
                unselectedLabelColor: KxColors.textMuted,
                labelStyle: KxTypography.labelSm,
                tabs: _LeaderCategory.values.map((c) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 14),
                      const SizedBox(width: 5),
                      Text(c.label),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ),

        // ── Podium (top 3) ────────────────────────────────────
        SliverToBoxAdapter(
          child: _buildPodium(top3)
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.05, end: 0),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── Divider label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Container(width: 3, height: 14,
                    color: KxColors.teal400.withOpacity(0.5)),
                const SizedBox(width: 8),
                Text('Sıralama',
                    style: KxTypography.labelSm
                        .copyWith(color: KxColors.textMuted)),
              ],
            ),
          ),
        ),

        // ── List (4+) ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final entry = rest[i];
                return _buildListRow(entry, i)
                    .animate(delay: (80 * i).ms)
                    .fadeIn(duration: 260.ms)
                    .slideX(begin: 0.03, end: 0);
              },
              childCount: rest.length,
            ),
          ),
        ),

        // ── Current user sticky card ───────────────────────────
        SliverToBoxAdapter(
          child: _buildMyRankCard(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  // ── Podium ──────────────────────────────────────────────────────

  Widget _buildPodium(List<_LeaderEntry> top3) {
    if (top3.length < 3) return const SizedBox.shrink();

    // Podium order: 2nd, 1st, 3rd
    final podiumOrder = [top3[1], top3[0], top3[2]];
    final heights     = [88.0, 112.0, 72.0];
    final labelRanks  = [2, 1, 3];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            KxColors.teal400.withOpacity(0.04),
            KxColors.bgSurface,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatars row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final entry = podiumOrder[i];
              final rank  = labelRanks[i];
              return _PodiumEntry(
                entry: entry,
                rank: rank,
                isFirst: rank == 1,
                score: _scoreLabel(_scoreOf(entry)),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Podium blocks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final rank  = labelRanks[i];
              final h     = heights[i];
              final color = _podiumColor(rank);
              return Expanded(
                child: Container(
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: KxTypography.headingMd.copyWith(
                        color: color.withOpacity(0.6),
                        fontFamily: 'IBM Plex Mono',
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _podiumColor(int rank) => switch (rank) {
        1 => KxColors.amber300,
        2 => const Color(0xFF94A3B8),
        3 => const Color(0xFFB45309),
        _ => KxColors.border,
      };

  // ── List row (rank 4+) ─────────────────────────────────────────

  Widget _buildListRow(_LeaderEntry entry, int index) {
    final isMe = entry.isCurrentUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? KxColors.teal400.withOpacity(0.06)
            : KxColors.bgSurface,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: isMe
              ? KxColors.teal400.withOpacity(0.3)
              : KxColors.border,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: KxTypography.monoSm.copyWith(
                color: KxColors.textDisabled,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          KxAvatar(
            name: entry.name,
            size: KxAvatarSize.sm,
            isOnline: entry.isOnline,
            showLevelRing: entry.level >= 10,
            level: entry.level,
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: KxTypography.labelMd.copyWith(
                          color: isMe
                              ? KxColors.teal400
                              : KxColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: KxColors.teal400.withOpacity(0.12),
                          borderRadius: KxSpacing.radiusPill,
                        ),
                        child: Text('Sen',
                            style: KxTypography.caption
                                .copyWith(color: KxColors.teal400)),
                      ),
                    ],
                  ],
                ),
                Text(
                  entry.country != null
                      ? '${entry.specialty} · ${entry.country}'
                      : entry.specialty,
                  style: KxTypography.caption
                      .copyWith(color: KxColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _scoreLabel(_scoreOf(entry)),
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              KxBadge.amber('Lvl ${entry.level}'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Current user rank card ──────────────────────────────────────

  Widget _buildMyRankCard() {
    final me = _entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => _entries.last,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        borderRadius: KxSpacing.radiusLg,
        border: Border.all(color: KxColors.teal400.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            KxColors.teal400.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.12),
              borderRadius: KxSpacing.radiusMd,
            ),
            child: Icon(Icons.person_pin_rounded,
                size: 20, color: KxColors.teal400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Senin Sıralaman',
                    style: KxTypography.labelSm
                        .copyWith(color: KxColors.textMuted)),
                Text(
                  '#${me.rank} — ${me.name}',
                  style: KxTypography.labelMd
                      .copyWith(color: KxColors.teal400),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _scoreLabel(_scoreOf(me)),
                style: KxTypography.monoSm.copyWith(
                  color: KxColors.teal400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${me.levelTitle} · Lvl ${me.level}',
                style: KxTypography.caption
                    .copyWith(color: KxColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Podium entry widget ────────────────────────────────────────

class _PodiumEntry extends StatelessWidget {
  final _LeaderEntry entry;
  final int rank;
  final bool isFirst;
  final String score;

  const _PodiumEntry({
    required this.entry,
    required this.rank,
    required this.isFirst,
    required this.score,
  });

  Color get _rankColor => switch (rank) {
        1 => KxColors.amber300,
        2 => const Color(0xFF94A3B8),
        3 => const Color(0xFFB45309),
        _ => KxColors.border,
      };

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown for rank 1
          if (isFirst)
            Icon(Icons.emoji_events_rounded,
                size: 20, color: KxColors.amber300)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2400.ms, color: KxColors.amber300),

          const SizedBox(height: 4),

          // Avatar with rank ring
          Stack(
            clipBehavior: Clip.none,
            children: [
              KxAvatar(
                name: entry.name,
                size: isFirst ? KxAvatarSize.xl : KxAvatarSize.lg,
                isOnline: entry.isOnline,
                showLevelRing: true,
                level: entry.level,
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _rankColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: KxColors.bgSurface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            entry.name.split(' ').last, // Surname only
            style: KxTypography.labelSm.copyWith(
              color: KxColors.textPrimary,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            score,
            style: KxTypography.caption.copyWith(
              color: _rankColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
