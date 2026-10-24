import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../design_system/design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';

/// KONSENXIA Dashboard
///
/// Geniş ekran (≥860px): KxSidebar sol, içerik sağ.
/// Dar ekran (<860px): Bottom navigation veya drawer.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Eger data zaten yukluyse tekrar Firestore'a gitme
    final currentState = context.read<DashboardBloc>().state;
    if (currentState is! DashboardLoaded) {
      context.read<DashboardBloc>().add(const LoadDashboardEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Rol değişti → dashboard'u yeniden yükle
          context.read<DashboardBloc>().add(const LoadDashboardEvent());
        }
      },
      child: Scaffold(
        backgroundColor: KxColors.bgBase,
        body: isWide ? _buildWide() : _buildNarrow(),
      ),
    );
  }

  // ── Geniş ekran — sidebar + içerik ────────────────────────────

  Widget _buildWide() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return _DashboardContent(state: state);
      },
    );
  }

  // ── Dar ekran — tam genişlik ───────────────────────────────────

  Widget _buildNarrow() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) => _DashboardContent(state: state),
    );
  }

}

// ── İçerik alanı ──────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final DashboardState state;
  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DashboardInitial() || DashboardLoading() => const _LoadingView(),
      DashboardLoaded s => _LoadedView(state: s),
      DashboardError s => _ErrorView(message: s.message),
      _ => const _LoadingView(),
    };
  }
}

// ── Loading ────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(KxColors.teal400),
        strokeWidth: 2,
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: KxColors.crimson400),
          const SizedBox(height: 12),
          Text('Veri yüklenemedi', style: KxTypography.headingSm),
          const SizedBox(height: 8),
          Text(message,
              style: KxTypography.bodyMd.copyWith(color: KxColors.textSecondary)),
          const SizedBox(height: 20),
          KxButton.secondary(
            label: 'Tekrar dene',
            onPressed: () =>
                context.read<DashboardBloc>().add(const LoadDashboardEvent()),
          ),
        ],
      ),
    );
  }
}

// ── Loaded ─────────────────────────────────────────────────────────

class _LoadedView extends StatefulWidget {
  final DashboardLoaded state;
  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  static const _infoDismissedKey = 'vaka_hub_info_dismissed';
  bool _showInfoCard = false;

  @override
  void initState() {
    super.initState();
    _checkInfoCardVisibility();
  }

  void _checkInfoCardVisibility() {
    final prefs = GetIt.instance<SharedPreferences>();
    final dismissed = prefs.getBool(_infoDismissedKey) ?? false;
    if (!dismissed) {
      setState(() => _showInfoCard = true);
    }
  }

  void _dismissInfoCard() {
    setState(() => _showInfoCard = false);
    final prefs = GetIt.instance<SharedPreferences>();
    prefs.setBool(_infoDismissedKey, true);
  }

  DashboardLoaded get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: KxColors.teal400,
      backgroundColor: KxColors.bgCard,
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboardEvent());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────
          SliverAppBar(
            backgroundColor: KxColors.bgBase,
            floating: true,
            snap: true,
            elevation: 0,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: KxTypography.headingMd,
                    ),
                    Text(
                      '${state.onlineDoctors} doktor çevrimiçi',
                      style: KxTypography.caption.copyWith(
                        color: KxColors.teal400,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search_rounded,
                      color: KxColors.textSecondary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: KxColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ── Istatistik kartlari ────────────────────────────
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _StatsRow(state: state),
              ),
            ),
          ),

          // ── Vaka vs Hub Bilgi Kartı (ilk ziyarette) ──────
          if (_showInfoCard)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _VakaHubInfoCard(onDismiss: _dismissInfoCard),
              ),
            ),

          // ── Rol Banner + XP ──────────────────────────────
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _RoleBanner(state: state),
              ),
            ),
          ),

          // ── Hizli Eylemler (rol bazli) ─────────────────────
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _QuickActions(userRole: state.userRole),
              ),
            ),
          ),

          // ── Size Atanan Vakalar (intern/resident) ──────────
          if (state.assignedCases.isNotEmpty || state.isLearner)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _AssignedCasesSection(state: state),
                ),
              ),
            ),

          // ── Son Bildirimler ─────────────────────────────────
          if (state.recentNotifications.isNotEmpty)
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _NotificationsPreview(
                    notifications: state.recentNotifications,
                  ),
                ),
              ),
            ),

          // ── Section başlığı ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Text('Son Vakalar', style: KxTypography.headingSm),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/cases'),
                    child: Text(
                      'Tümünü gör →',
                      style: KxTypography.labelSm.copyWith(
                        color: KxColors.teal400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Vaka listesi ───────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final c = state.recentCases[index];
                return RepaintBoundary(
                  child: KxCaseCard.compact(
                    caseId: c.id,
                    title: c.title,
                    summary: c.title,
                    authorName: c.authorName,
                    authorSpecialty: c.specialty,
                    urgency: KxCaseUrgency.routine,
                    commentCount: c.commentCount,
                    isSolved: c.isSolved,
                    postedAt: c.postedAt,
                    onTap: () => context.go('/cases/${c.id}'),
                  ),
                );
              },
              childCount: state.recentCases.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Rol Banner ────────────────────────────────────────────────────

class _RoleBanner extends StatelessWidget {
  final DashboardLoaded state;
  const _RoleBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final (emoji, roleName, roleColor) = switch (state.userRole) {
      'INTERN'     => ('🎓', 'İntern / Tıp Öğrencisi', KxColors.amber300),
      'RESIDENT'   => ('🩺', 'Asistan Doktor', KxColors.blue400),
      'SPECIALIST' => ('👨‍⚕️', 'Uzman Hekim', KxColors.teal400),
      'PROFESSOR'  => ('🏛️', 'Profesör / Doçent', KxColors.jade300),
      _            => ('🩺', 'Doktor', KxColors.teal400),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: roleColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: KxTypography.labelMd.copyWith(color: roleColor),
                ),
                const SizedBox(height: 2),
                Text(
                  state.userName.isNotEmpty
                      ? _titlePrefix(state.userRole) + state.userName
                      : 'Hoş geldiniz',
                  style: KxTypography.headingSm,
                ),
              ],
            ),
          ),
          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: KxColors.bgCard,
              borderRadius: KxSpacing.radiusPill,
              border: Border.all(color: KxColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: KxColors.amber300),
                const SizedBox(width: 4),
                Text(
                  '${state.totalXp} XP',
                  style: KxTypography.monoSm.copyWith(
                    color: KxColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titlePrefix(String role) => switch (role) {
        'SPECIALIST' => 'Uzm. Dr. ',
        'PROFESSOR'  => 'Prof. Dr. ',
        'RESIDENT'   => 'Dr. ',
        _            => '',
      };
}

// ── Stats Row ──────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardLoaded state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_open_rounded,
            label: 'Vakalar',
            value: state.totalCases.toString(),
            color: KxColors.teal400,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.group_rounded,
            label: 'Katkılar',
            value: state.totalContributions.toString(),
            color: KxColors.blue400,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.public_rounded,
            label: 'Ülkeler',
            value: state.totalCountries.toString(),
            color: KxColors.amber300,
          ),
        ),
        if (state.rank != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.leaderboard_rounded,
              label: 'Sıralama',
              value: '#${state.rank}',
              color: KxColors.amber300,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: KxTypography.monoMd.copyWith(
              color: KxColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: KxTypography.caption),
        ],
      ),
    );
  }
}

// ── Hızlı Eylemler (rol bazlı) ─────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final String userRole;
  const _QuickActions({required this.userRole});

  bool get _canAssign => userRole == 'SPECIALIST' || userRole == 'PROFESSOR';
  bool get _isLearner => userRole == 'INTERN' || userRole == 'RESIDENT';
  bool get _isProfessor => userRole == 'PROFESSOR';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Hızlı Eylemler', style: KxTypography.headingSm),
            const SizedBox(width: 8),
            KxBadge(
              _isLearner ? 'Öğrenen' : _isProfessor ? 'Akademisyen' : 'Uzman',
              variant: KxBadgeVariant.teal,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Üst satır — 3 kart
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.folder_open_rounded,
                label: 'Vakalar',
                subtitle: _canAssign ? 'İncele & ata' : 'Tüm vakalar',
                color: KxColors.teal400,
                onTap: () => context.go('/cases'),
              ).animate().fadeIn(delay: 50.ms),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Asistan',
                subtitle: 'Analiz yap',
                color: KxColors.blue400,
                onTap: () => context.go('/ai-chat'),
              ).animate().fadeIn(delay: 80.ms),
            ),
            const SizedBox(width: 10),
            if (_isLearner)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.description_outlined,
                  label: 'Rapor Yaz',
                  subtitle: 'AI destekli',
                  color: KxColors.amber300,
                  onTap: () => context.go('/reports/upload'),
                ).animate().fadeIn(delay: 110.ms),
              )
            else
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Vaka Ata',
                  subtitle: 'Asistanlara',
                  color: KxColors.amber300,
                  onTap: () => context.go('/cases'),
                ).animate().fadeIn(delay: 110.ms),
              ),
          ],
        ),
        // Alt satır — Professor/Specialist'e ek eylemler
        if (_canAssign) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people_alt_rounded,
                  label: _isProfessor ? 'Asistanlarım' : 'Ekibim',
                  subtitle: _isProfessor ? 'Profil & ilerleme' : 'Takım üyeleri',
                  color: KxColors.jade300,
                  onTap: () => context.go('/assistants'),
                ).animate().fadeIn(delay: 140.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.analytics_rounded,
                  label: 'İstatistikler',
                  subtitle: 'Performans analizi',
                  color: KxColors.crimson400,
                  onTap: () => context.go('/analytics'),
                ).animate().fadeIn(delay: 170.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Hub',
                  subtitle: 'Bilgi deposu',
                  color: KxColors.textSecondary,
                  onTap: () => context.go('/knowledge-hub'),
                ).animate().fadeIn(delay: 200.ms),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: KxTypography.labelSm.copyWith(color: KxColors.textPrimary)),
            Text(subtitle, style: KxTypography.caption),
          ],
        ),
      ),
    );
  }
}

// ── Atanan Vakalar Bölümü (intern/resident) ─────────────────────────

class _AssignedCasesSection extends StatelessWidget {
  final DashboardLoaded state;
  const _AssignedCasesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 16,
              decoration: BoxDecoration(
                color: KxColors.amber300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Size Atanan Vakalar', style: KxTypography.headingSm),
            const SizedBox(width: 8),
            if (state.assignedCases.isNotEmpty)
              KxBadge.amber('${state.assignedCases.length}'),
          ],
        ),
        const SizedBox(height: 10),
        if (state.assignedCases.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KxColors.bgCard,
              borderRadius: KxSpacing.radiusMd,
              border: Border.all(color: KxColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment_outlined,
                    size: 20, color: KxColors.textMuted),
                const SizedBox(width: 10),
                Text('Henüz atanmış vaka yok.',
                    style: KxTypography.bodyMd
                        .copyWith(color: KxColors.textSecondary)),
              ],
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.assignedCases.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final a = state.assignedCases[i];
                return _AssignmentCard(
                  assignment: a,
                  onTap: () => context.go('/cases/${a.caseId}'),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 + i * 60));
              },
            ),
          ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final DashboardAssignment assignment;
  final VoidCallback onTap;

  const _AssignmentCard({required this.assignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (assignment.status) {
      'completed'   => KxColors.jade300,
      'in_progress' => KxColors.teal400,
      _             => KxColors.amber300,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: KxColors.bgCard,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  switch (assignment.status) {
                    'completed'   => 'Tamamlandı',
                    'in_progress' => 'Devam ediyor',
                    _             => 'Bekliyor',
                  },
                  style: KxTypography.caption.copyWith(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              assignment.caseTitle,
              style: KxTypography.labelSm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '${assignment.assignedByTitle} ${assignment.assignedByName}',
              style: KxTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bildirim Önizlemesi ─────────────────────────────────────────────

class _NotificationsPreview extends StatelessWidget {
  final List<DashboardNotificationPreview> notifications;
  const _NotificationsPreview({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 16,
              decoration: BoxDecoration(
                color: KxColors.blue400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Son Bildirimler', style: KxTypography.headingSm),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/notifications'),
              child: Text('Tümü →',
                  style: KxTypography.labelSm.copyWith(color: KxColors.teal400)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...notifications.take(3).indexed.map((entry) {
          final i = entry.$1;
          final n = entry.$2;
          return _NotifRow(notif: n)
              .animate().fadeIn(delay: Duration(milliseconds: 40 + i * 50));
        }),
      ],
    );
  }
}

class _NotifRow extends StatelessWidget {
  final DashboardNotificationPreview notif;
  const _NotifRow({required this.notif});

  @override
  Widget build(BuildContext context) {
    final icon = switch (notif.type) {
      'case_assigned' => Icons.assignment_ind_rounded,
      'comment'       => Icons.chat_bubble_outline_rounded,
      'like'          => Icons.favorite_outline_rounded,
      _               => Icons.notifications_outlined,
    };
    final color = switch (notif.type) {
      'case_assigned' => KxColors.amber300,
      'comment'       => KxColors.teal400,
      'like'          => KxColors.crimson400,
      _               => KxColors.textSecondary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: notif.isRead ? KxColors.bgCard : KxColors.bgElevated,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title,
                    style: KxTypography.labelSm.copyWith(
                      color: notif.isRead
                          ? KxColors.textSecondary
                          : KxColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(notif.body,
                    style: KxTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (!notif.isRead)
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: KxColors.teal400,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Vaka vs Hub Bilgi Kartı ──────────────────────────────────────────

class _VakaHubInfoCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _VakaHubInfoCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.blue400.withOpacity(0.06),
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.blue400.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: KxColors.blue400),
              const SizedBox(width: 8),
              Text(
                'Vakalar ve Knowledge Hub Nedir?',
                style: KxTypography.labelMd.copyWith(color: KxColors.blue400),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close_rounded,
                    size: 18, color: KxColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Vakalar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KxColors.teal400.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.folder_open_rounded,
                    size: 14, color: KxColors.teal400),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vakalar',
                        style: KxTypography.labelSm
                            .copyWith(color: KxColors.teal400)),
                    const SizedBox(height: 2),
                    Text(
                      'Aktif klinik tartışma — doktorlar analiz eder, yorum yapar, puanlanır.',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Knowledge Hub
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: KxColors.amber300.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.menu_book_rounded,
                    size: 14, color: KxColors.amber300),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Knowledge Hub',
                        style: KxTypography.labelSm
                            .copyWith(color: KxColors.amber300)),
                    const SizedBox(height: 2),
                    Text(
                      'Eğitim kütüphanesi — klinik inciler, nadir hastalıklar, kılavuz özetleri.',
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}
