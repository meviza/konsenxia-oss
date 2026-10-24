import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Organism — KxBottomNavigationBar
///
/// Dar ekranlarda (< 860px) gösterilen, 5 sekmelik alt gezinme çubuğu.
/// Glassmorphism arka plan + blur efekti. Aktif sekme teal vurgusu.
class KxBottomNavigationBar extends StatelessWidget {
  /// Aktif sekmenin rotası (GoRouter location path)
  final String currentLocation;

  /// Sekmeye dokunulduğunda hedef rota döner
  final ValueChanged<String> onTap;

  const KxBottomNavigationBar({
    super.key,
    required this.currentLocation,
    required this.onTap,
  });

  static const _tabs = [
    _KxBottomTab(
      label: 'Anasayfa',
      icon: Icons.grid_view_outlined,
      iconActive: Icons.grid_view_rounded,
      route: '/dashboard',
    ),
    _KxBottomTab(
      label: 'Vakalar',
      icon: Icons.folder_outlined,
      iconActive: Icons.folder_rounded,
      route: '/cases',
    ),
    _KxBottomTab(
      label: 'AI',
      icon: Icons.auto_awesome_outlined,
      iconActive: Icons.auto_awesome_rounded,
      route: '/ai-chat',
    ),
    _KxBottomTab(
      label: 'Hub',
      icon: Icons.menu_book_outlined,
      iconActive: Icons.menu_book_rounded,
      route: '/knowledge-hub',
    ),
    _KxBottomTab(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      iconActive: Icons.person_rounded,
      route: '/profile',
    ),
  ];

  bool _isActive(_KxBottomTab tab) {
    if (tab.route == '/dashboard') {
      return currentLocation == '/dashboard' || currentLocation == '/';
    }
    return currentLocation.startsWith(tab.route);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: KxColors.bgElevated.withOpacity(0.92),
            border: const Border(
              top: BorderSide(color: KxColors.border, width: 0.5),
            ),
          ),
          padding: EdgeInsets.only(
            top: 6,
            bottom: bottomPadding > 0 ? bottomPadding : 8,
          ),
          child: Row(
            children: _tabs.map((tab) {
              final active = _isActive(tab);
              return Expanded(
                child: _KxBottomTabItem(
                  tab: tab,
                  isActive: active,
                  onTap: () => onTap(tab.route),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Tek sekme öğesi ─────────────────────────────────────────────────

class _KxBottomTabItem extends StatelessWidget {
  final _KxBottomTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _KxBottomTabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with active pill indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? KxColors.teal400.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: KxSpacing.radiusPill,
              ),
              child: Icon(
                isActive ? tab.iconActive : tab.icon,
                size: 22,
                color: isActive ? KxColors.teal400 : KxColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: KxTypography.caption.copyWith(
                color: isActive ? KxColors.teal400 : KxColors.textMuted,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab model ────────────────────────────────────────────────────────

class _KxBottomTab {
  final String label;
  final IconData icon;
  final IconData iconActive;
  final String route;

  const _KxBottomTab({
    required this.label,
    required this.icon,
    required this.iconActive,
    required this.route,
  });
}
