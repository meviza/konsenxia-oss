import 'package:flutter/material.dart';
import '../atoms/kx_avatar.dart';
import '../atoms/kx_badge.dart';
import '../atoms/kx_progress_bar.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_shadows.dart';

/// KONSENXIA Organism — KxSidebar
///
/// Ana navigasyon kenar çubuğu. Dashboard, Case Hub ve AI Chat sayfalarında
/// sabit sol panel olarak kullanılır.
/// Collapsed (72px) ve expanded (240px) modları vardır.

enum KxNavItem {
  dashboard,
  cases,
  aiChat,
  messages,
  leaderboard,
  analytics,
  profile,
}

extension KxNavItemExt on KxNavItem {
  String get label => switch (this) {
        KxNavItem.dashboard => 'Dashboard',
        KxNavItem.cases => 'Vaka Merkezi',
        KxNavItem.aiChat => 'AI Asistan',
        KxNavItem.messages => 'Mesajlar',
        KxNavItem.leaderboard => 'Liderboard',
        KxNavItem.analytics => 'Analitik',
        KxNavItem.profile => 'Profil',
      };

  IconData get icon => switch (this) {
        KxNavItem.dashboard => Icons.grid_view_rounded,
        KxNavItem.cases => Icons.folder_open_rounded,
        KxNavItem.aiChat => Icons.auto_awesome_rounded,
        KxNavItem.messages => Icons.chat_bubble_outline_rounded,
        KxNavItem.leaderboard => Icons.leaderboard_rounded,
        KxNavItem.analytics => Icons.bar_chart_rounded,
        KxNavItem.profile => Icons.person_outline_rounded,
      };

  IconData get iconSelected => switch (this) {
        KxNavItem.dashboard => Icons.grid_view_rounded,
        KxNavItem.cases => Icons.folder_rounded,
        KxNavItem.aiChat => Icons.auto_awesome_rounded,
        KxNavItem.messages => Icons.chat_bubble_rounded,
        KxNavItem.leaderboard => Icons.leaderboard_rounded,
        KxNavItem.analytics => Icons.bar_chart_rounded,
        KxNavItem.profile => Icons.person_rounded,
      };
}

class KxSidebar extends StatefulWidget {
  /// Aktif navigasyon öğesi
  final KxNavItem activeItem;

  /// Navigasyon değişince çağrılır
  final ValueChanged<KxNavItem> onItemSelected;

  /// Kullanıcı adı
  final String userName;

  /// Uzmanlık / rol
  final String userSpecialty;

  /// Profil fotoğrafı URL
  final String? userImageUrl;

  /// Level numarası
  final int? userLevel;

  /// Level başlığı (Resident, Senior vs.)
  final String? userLevelTitle;

  /// XP bilgileri (opsiyonel)
  final int? xpCurrent;
  final int? xpTotal;

  /// Online durumu
  final bool isOnline;

  /// Bildirim sayısı (AI Chat için)
  final int notificationCount;

  /// Başlangıçta expanded mı?
  final bool initiallyExpanded;

  const KxSidebar({
    super.key,
    required this.activeItem,
    required this.onItemSelected,
    required this.userName,
    required this.userSpecialty,
    this.userImageUrl,
    this.userLevel,
    this.userLevelTitle,
    this.xpCurrent,
    this.xpTotal,
    this.isOnline = false,
    this.notificationCount = 0,
    this.initiallyExpanded = true,
  });

  @override
  State<KxSidebar> createState() => _KxSidebarState();
}

class _KxSidebarState extends State<KxSidebar>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _widthAnim;
  late Animation<double> _fadeAnim;

  static const double _collapsedWidth = 72;
  static const double _expandedWidth = 240;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: _expanded ? 1.0 : 0.0,
    );
    _widthAnim = Tween<double>(
      begin: _collapsedWidth,
      end: _expandedWidth,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _ctrl.forward() : _ctrl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: _widthAnim.value,
          decoration: BoxDecoration(
            color: KxColors.bgSurface,
            border: Border(
              right: BorderSide(color: KxColors.border),
            ),
            boxShadow: KxShadows.md,
          ),
          child: Column(
            children: [
              // ── Logo & Toggle ─────────────────────────────
              _buildLogoRow(),

              const SizedBox(height: 16),

              // ── Nav Items ─────────────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: KxNavItem.values
                      .map((item) => _buildNavItem(item))
                      .toList(),
                ),
              ),

              // ── Kullanıcı paneli ──────────────────────────
              _buildUserPanel(),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ── Logo & Toggle ──────────────────────────────────────────────

  Widget _buildLogoRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KxColors.teal400, Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '⚕',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          // Wordmark (sadece expanded)
          if (_ctrl.value > 0.5) ...[
            const SizedBox(width: 10),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'KONSEN',
                        style: KxTypography.labelLg.copyWith(
                          color: KxColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'xia',
                        style: KxTypography.labelLg.copyWith(
                          color: KxColors.teal400,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Instrument Serif',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),

          // Toggle butonu
          GestureDetector(
            onTap: _toggle,
            child: Icon(
              _expanded
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: KxColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav Item ───────────────────────────────────────────────────

  Widget _buildNavItem(KxNavItem item) {
    final isActive = widget.activeItem == item;
    final hasNotif =
        item == KxNavItem.aiChat && widget.notificationCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: GestureDetector(
        onTap: () => widget.onItemSelected(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? KxColors.teal400.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: KxSpacing.radiusMd,
            border: isActive
                ? Border.all(color: KxColors.teal400.withOpacity(0.25))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              // İkon + bildirim badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? item.iconSelected : item.icon,
                    size: 20,
                    color: isActive ? KxColors.teal400 : KxColors.textMuted,
                  ),
                  if (hasNotif)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: KxColors.crimson400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.notificationCount > 9
                                ? '9+'
                                : widget.notificationCount.toString(),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Etiket (sadece expanded)
              if (_ctrl.value > 0.4) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Text(
                      item.label,
                      style: KxTypography.labelMd.copyWith(
                        color: isActive
                            ? KxColors.teal400
                            : KxColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Kullanıcı Paneli ───────────────────────────────────────────

  Widget _buildUserPanel() {
    final hasXp = widget.xpCurrent != null && widget.xpTotal != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(color: KxColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              KxAvatar(
                name: widget.userName,
                imageUrl: widget.userImageUrl,
                size: KxAvatarSize.sm,
                isOnline: widget.isOnline,
                showLevelRing: widget.userLevel != null,
                level: widget.userLevel,
              ),

              // İsim + uzmanlık (sadece expanded)
              if (_ctrl.value > 0.4) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: KxTypography.labelSm.copyWith(
                            color: KxColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.userSpecialty,
                          style: KxTypography.caption.copyWith(
                            color: KxColors.teal400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.userLevel != null) ...[
                          const SizedBox(height: 3),
                          KxBadge.amber('Lvl ${widget.userLevel}'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // XP Bar (sadece expanded + XP bilgisi varsa)
          if (_ctrl.value > 0.6 && hasXp) ...[
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnim,
              child: KxProgressBar.thin(
                value: widget.xpCurrent! / widget.xpTotal!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
