import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/analytics_data.dart';
import '../bloc/analytics_bloc.dart';

/// KONSENXIA Analytics Dashboard
///
/// Kişisel istatistikler (XP, vakalar, seriler) ve topluluk verileri.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  KxNavItem _activeNav = KxNavItem.analytics;

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent());
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
          activeItem: _activeNav,
          onItemSelected: _onNavChanged,
          userName: 'Dr. Kerem',
          userSpecialty: 'Dahiliye',
          userLevel: 8,
          userLevelTitle: 'Uzman',
          xpCurrent: 420,
          xpTotal: 1000,
          isOnline: true,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildNarrow() => _buildContent();

  Widget _buildContent() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: KxColors.bgBase,
              floating: true,
              snap: true,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analitik', style: KxTypography.headingMd),
                  Text(
                    'Performans ve topluluk verileri',
                    style: KxTypography.caption.copyWith(
                      color: KxColors.teal400,
                    ),
                  ),
                ],
              ),
              actions: [
                if (state is! AnalyticsLoading)
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: KxColors.textSecondary,
                    ),
                    onPressed: () => context
                        .read<AnalyticsBloc>()
                        .add(const RefreshAnalyticsEvent()),
                  ),
              ],
            ),

            // Content
            if (state is AnalyticsLoading)
              const SliverFillRemaining(child: _LoadingView())
            else if (state is AnalyticsError)
              SliverFillRemaining(child: _ErrorView(message: state.message))
            else if (state is AnalyticsLoaded) ...[
              SliverToBoxAdapter(
                child: _AnalyticsBody(data: state.data),
              ),
            ] else
              const SliverFillRemaining(child: _LoadingView()),
          ],
        );
      },
    );
  }

  void _onNavChanged(KxNavItem item) {
    setState(() => _activeNav = item);
    switch (item) {
      case KxNavItem.dashboard:   context.go('/dashboard');
      case KxNavItem.cases:       context.go('/cases');
      case KxNavItem.aiChat:      context.go('/ai-chat');
      case KxNavItem.messages:    context.go('/messages');
      case KxNavItem.leaderboard: context.go('/leaderboard');
      case KxNavItem.profile:     context.go('/profile');
      case KxNavItem.analytics:   break;
    }
  }
}

// ── Loading ─────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: KxColors.teal400,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text('Veriler yükleniyor...', style: KxTypography.bodyMd),
        ],
      ),
    );
  }
}

// ── Error ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: KxColors.crimson400, size: 48),
          const SizedBox(height: 12),
          Text('Hata', style: KxTypography.headingMd),
          const SizedBox(height: 6),
          Text(
            message,
            style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          KxButton(
            label: 'Tekrar dene',
            onPressed: () =>
                context.read<AnalyticsBloc>().add(const LoadAnalyticsEvent()),
          ),
        ],
      ),
    );
  }
}

// ── Main body ───────────────────────────────────────────────────

class _AnalyticsBody extends StatelessWidget {
  final AnalyticsData data;
  const _AnalyticsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Kişisel İstatistikler ──────────────────────────────
          _SectionHeader(title: 'Kişisel İstatistikler', icon: Icons.person_rounded),
          const SizedBox(height: 12),

          // XP kartları — üst satır
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Toplam XP',
                  value: _fmt(data.personal.totalXp),
                  icon: Icons.star_rounded,
                  iconColor: KxColors.amber300,
                  subtitle: '+${_fmt(data.personal.xpThisMonth)} bu ay',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Bu Hafta XP',
                  value: _fmt(data.personal.xpThisWeek),
                  icon: Icons.trending_up_rounded,
                  iconColor: KxColors.teal400,
                  subtitle: 'Bu hafta kazanılan',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Vaka / yorum / seri satırı
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Toplam Vaka',
                  value: data.personal.totalCases.toString(),
                  icon: Icons.folder_rounded,
                  iconColor: KxColors.blue400,
                  subtitle: '+${data.personal.casesThisMonth} bu ay',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Yorumlar',
                  value: _fmt(data.personal.totalComments),
                  icon: Icons.chat_bubble_rounded,
                  iconColor: KxColors.jade300,
                  subtitle: '${data.personal.acceptedAnswers} kabul edildi',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Seri',
                  value: '${data.personal.currentStreak}g',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: KxColors.crimson400,
                  subtitle: 'En uzun: ${data.personal.longestStreak}g',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Beğeniler / kabul
          _StatCard(
            label: 'Toplam Beğeni',
            value: _fmt(data.personal.totalLikesReceived),
            icon: Icons.thumb_up_rounded,
            iconColor: KxColors.teal300,
            subtitle: 'Paylaşımlarınıza gelen beğeniler',
            wide: true,
          ),

          const SizedBox(height: 24),

          // ── Haftalık Aktivite ──────────────────────────────────
          _SectionHeader(
            title: 'Haftalık Aktivite',
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 12),
          _WeeklyActivityChart(activity: data.personal.weeklyActivity),

          const SizedBox(height: 24),

          // ── Aylık XP Trendi ───────────────────────────────────
          _SectionHeader(
            title: 'Aylık XP Trendi',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 12),
          _MonthlyXPChart(months: data.personal.monthlyXP),

          const SizedBox(height: 24),

          // ── Topluluk İstatistikleri ────────────────────────────
          _SectionHeader(
            title: 'Topluluk Verileri',
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Aktif Doktor',
                  value: _fmt(data.community.totalDoctors),
                  icon: Icons.medical_services_rounded,
                  iconColor: KxColors.teal400,
                  subtitle: 'Platformda kayıtlı',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Bu Hafta Vaka',
                  value: data.community.casesThisWeek.toString(),
                  icon: Icons.folder_open_rounded,
                  iconColor: KxColors.blue400,
                  subtitle: 'Toplam: ${_fmt(data.community.totalCasesAllTime)}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Çözüm oranı
          _SolvedRateCard(percent: data.community.solvedCasesPercent),

          const SizedBox(height: 16),

          // Uzmanlık dağılımı
          if (data.community.topSpecialties.isNotEmpty) ...[
            _SectionHeader(
              title: 'Öne Çıkan Uzmanlıklar',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 12),
            _SpecialtyBreakdown(specialties: data.community.topSpecialties),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Section Header ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: KxColors.teal400),
        const SizedBox(width: 8),
        Text(title, style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [KxColors.border, KxColors.bgBase],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final bool wide;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: wide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: KxSpacing.radiusSm,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: KxTypography.caption.copyWith(
                              color: KxColors.textMuted)),
                      Text(value,
                          style: KxTypography.displaySm.copyWith(fontSize: 22)),
                      Text(subtitle,
                          style: KxTypography.caption.copyWith(
                              color: KxColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: KxSpacing.radiusSm,
                      ),
                      child: Icon(icon, color: iconColor, size: 16),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(value,
                    style: KxTypography.displaySm.copyWith(fontSize: 20)),
                const SizedBox(height: 2),
                Text(label,
                    style: KxTypography.caption.copyWith(
                        color: KxColors.textSecondary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: KxTypography.caption.copyWith(
                        color: KxColors.textMuted,
                        fontSize: 10)),
              ],
            ),
    );
  }
}

// ── Weekly Activity Chart ───────────────────────────────────────

class _WeeklyActivityChart extends StatelessWidget {
  final List<WeeklyActivity> activity;
  const _WeeklyActivityChart({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) return _emptyState('Haftalık veri yok');

    final maxXp = activity.map((a) => a.xp).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activity.map((day) {
                final ratio = maxXp > 0 ? day.xp / maxXp : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.xp > 0)
                          Text(
                            day.xp.toString(),
                            style: KxTypography.caption.copyWith(
                              color: KxColors.teal400,
                              fontSize: 9,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: (80 * ratio).clamp(4, 80),
                          decoration: BoxDecoration(
                            borderRadius: KxSpacing.radiusSm,
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: day.xp > 0
                                  ? [KxColors.teal700, KxColors.teal400]
                                  : [KxColors.bgHover, KxColors.bgHover],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: activity
                .map((day) => Expanded(
                      child: Text(
                        day.day,
                        textAlign: TextAlign.center,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Center(
          child: Text(msg,
              style: KxTypography.bodyMd.copyWith(
                  color: KxColors.textMuted)),
        ),
      );
}

// ── Monthly XP Chart ────────────────────────────────────────────

class _MonthlyXPChart extends StatelessWidget {
  final List<MonthlyXP> months;
  const _MonthlyXPChart({required this.months});

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: KxColors.border),
        ),
        child: Center(
          child: Text('Aylık veri yok',
              style: KxTypography.bodyMd.copyWith(color: KxColors.textMuted)),
        ),
      );
    }

    final maxXp = months.map((m) => m.xp).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.map((m) {
                final ratio = maxXp > 0 ? m.xp / maxXp : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      height: (70 * ratio).clamp(4, 70),
                      decoration: BoxDecoration(
                        borderRadius: KxSpacing.radiusSm,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: m.xp > 0
                              ? [KxColors.amber500, KxColors.amber300]
                              : [KxColors.bgHover, KxColors.bgHover],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: months
                .map((m) => Expanded(
                      child: Text(
                        m.month,
                        textAlign: TextAlign.center,
                        style: KxTypography.caption.copyWith(
                          color: KxColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Solved Rate Card ────────────────────────────────────────────

class _SolvedRateCard extends StatelessWidget {
  final int percent;
  const _SolvedRateCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    final value = (percent / 100).clamp(0.0, 1.0);
    return Container(
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
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: KxColors.jade300),
              const SizedBox(width: 8),
              Text('Vaka Çözüm Oranı',
                  style: KxTypography.labelMd.copyWith(
                      color: KxColors.textSecondary)),
              const Spacer(),
              Text(
                '%$percent',
                style: KxTypography.displaySm.copyWith(
                  fontSize: 20,
                  color: KxColors.jade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          KxProgressBar(
            value: value,
            variant: KxProgressVariant.jade,
            height: 8,
          ),
          const SizedBox(height: 6),
          Text(
            'Topluluk genelinde çözüme ulaşan vakaların oranı',
            style: KxTypography.caption.copyWith(color: KxColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Specialty Breakdown ─────────────────────────────────────────

class _SpecialtyBreakdown extends StatelessWidget {
  final List<SpecialtyActivity> specialties;
  const _SpecialtyBreakdown({required this.specialties});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        children: specialties.asMap().entries.map((entry) {
          final spec = entry.value;
          final colors = [
            KxColors.teal400,
            KxColors.blue400,
            KxColors.amber300,
            KxColors.jade300,
            KxColors.crimson300,
          ];
          final color = colors[entry.key % colors.length];
          final barValue = (spec.percentage / 100).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        spec.specialty,
                        style: KxTypography.labelSm.copyWith(
                            color: KxColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${spec.caseCount} vaka',
                      style: KxTypography.monoSm.copyWith(
                          color: KxColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '%${spec.percentage.toStringAsFixed(1)}',
                      style: KxTypography.monoSm.copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                KxProgressBar(
                  value: barValue,
                  variant: _variantFor(entry.key),
                  height: 5,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  KxProgressVariant _variantFor(int index) {
    const variants = [
      KxProgressVariant.teal,
      KxProgressVariant.blue,
      KxProgressVariant.amber,
      KxProgressVariant.jade,
      KxProgressVariant.crimson,
    ];
    return variants[index % variants.length];
  }
}
