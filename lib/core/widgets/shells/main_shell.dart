import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/organisms/kx_bottom_navigation_bar.dart';

/// KONSENXIA — MainShell
///
/// ShellRoute için shell widget.
///
/// Üç kademeli responsive breakpoint sistemi:
/// - Mobil    (<768px):    Alt navigasyon çubuğu (BottomNavigationBar)
/// - Tablet   (768-1200px): Daraltılmış sidebar (yalnızca ikonlar) + içerik
/// - Masaüstü (>1200px):   Genişletilmiş sidebar + içerik + Cmd/Ctrl+K kısayol desteği
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ── Mobil (<768px): Alt navigasyon çubuğu ──
    if (width < 768) {
      final location = GoRouterState.of(context).uri.path;
      return Scaffold(
        backgroundColor: KxColors.bgBase,
        body: child,
        bottomNavigationBar: KxBottomNavigationBar(
          currentLocation: location,
          onTap: (route) => context.go(route),
        ),
      );
    }

    // ── Tablet (768-1200px): Daraltılmış sidebar ──
    if (width <= 1200) {
      final location = GoRouterState.of(context).uri.path;
      return Scaffold(
        backgroundColor: KxColors.bgBase,
        body: Row(
          children: [
            _KxCollapsedSidebar(
              currentLocation: location,
              onTap: (route) => context.go(route),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    // ── Masaüstü (>1200px): Genişletilmiş sidebar + klavye kısayolları ──
    final location = GoRouterState.of(context).uri.path;
    return _DesktopShell(
      location: location,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Sidebar Navigation Tab Model ───────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SidebarTab {
  final String label;
  final IconData icon;
  final IconData iconActive;
  final String route;

  const _SidebarTab({
    required this.label,
    required this.icon,
    required this.iconActive,
    required this.route,
  });
}

const _sidebarTabs = [
  _SidebarTab(
    label: 'Anasayfa',
    icon: Icons.grid_view_outlined,
    iconActive: Icons.grid_view_rounded,
    route: '/dashboard',
  ),
  _SidebarTab(
    label: 'Vakalar',
    icon: Icons.folder_outlined,
    iconActive: Icons.folder_rounded,
    route: '/cases',
  ),
  _SidebarTab(
    label: 'AI Asistan',
    icon: Icons.auto_awesome_outlined,
    iconActive: Icons.auto_awesome_rounded,
    route: '/ai-chat',
  ),
  _SidebarTab(
    label: 'Bilgi Merkezi',
    icon: Icons.menu_book_outlined,
    iconActive: Icons.menu_book_rounded,
    route: '/knowledge-hub',
  ),
  _SidebarTab(
    label: 'Profil',
    icon: Icons.person_outline_rounded,
    iconActive: Icons.person_rounded,
    route: '/profile',
  ),
];

bool _isTabActive(_SidebarTab tab, String location) {
  if (tab.route == '/dashboard') {
    return location == '/dashboard' || location == '/';
  }
  return location.startsWith(tab.route);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Desktop Shell (Expanded sidebar + keyboard shortcuts) ──────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopShell extends StatefulWidget {
  final String location;
  final Widget child;

  const _DesktopShell({required this.location, required this.child});

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMetaOrCtrl = HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;
      if (isMetaOrCtrl && event.logicalKey == LogicalKeyboardKey.keyK) {
        _showSearchOverlay();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _showSearchOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const _SearchOverlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: KxColors.bgBase,
        body: Row(
          children: [
            _KxExpandedSidebar(
              currentLocation: widget.location,
              onTap: (route) => context.go(route),
              onSearchTap: _showSearchOverlay,
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Search Overlay Dialog (Cmd/Ctrl+K) ─────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchOverlayDialog extends StatelessWidget {
  const _SearchOverlayDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: KxColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: KxColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: KxColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: KxTypography.bodyLg,
                      decoration: InputDecoration(
                        hintText: 'Vaka, doktor veya konu ara...',
                        hintStyle: KxTypography.bodyLg.copyWith(
                          color: KxColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: KxColors.bgElevated,
                      borderRadius: KxSpacing.radiusSm,
                      border: Border.all(color: KxColors.border, width: 0.5),
                    ),
                    child: Text(
                      'ESC',
                      style: KxTypography.monoSm.copyWith(
                        color: KxColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Placeholder content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_rounded,
                      color: KxColors.textDisabled, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Aramaya başlamak için yazın',
                    style: KxTypography.bodyMd.copyWith(
                      color: KxColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Collapsed Sidebar (Tablet: 768–1200px) ─────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _KxCollapsedSidebar extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onTap;

  const _KxCollapsedSidebar({
    required this.currentLocation,
    required this.onTap,
  });

  static const double _width = 72.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: const BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(
          right: BorderSide(color: KxColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo mark
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: KxColors.teal400.withOpacity(0.12),
                borderRadius: KxSpacing.radiusMd,
              ),
              alignment: Alignment.center,
              child: Text(
                'K',
                style: KxTypography.headingLg.copyWith(
                  color: KxColors.teal400,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Navigation items
            ..._sidebarTabs.map((tab) {
              final active = _isTabActive(tab, currentLocation);
              return Tooltip(
                message: tab.label,
                preferBelow: false,
                waitDuration: const Duration(milliseconds: 400),
                child: _CollapsedSidebarItem(
                  icon: active ? tab.iconActive : tab.icon,
                  isActive: active,
                  onTap: () => onTap(tab.route),
                ),
              );
            }),
            const Spacer(),
            // Settings
            Tooltip(
              message: 'Ayarlar',
              preferBelow: false,
              child: _CollapsedSidebarItem(
                icon: Icons.settings_outlined,
                isActive: false,
                onTap: () => onTap('/settings'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CollapsedSidebarItem extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CollapsedSidebarItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CollapsedSidebarItem> createState() => _CollapsedSidebarItemState();
}

class _CollapsedSidebarItemState extends State<_CollapsedSidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? KxColors.teal400.withOpacity(0.12)
                : _hovered
                    ? KxColors.bgHover
                    : Colors.transparent,
            borderRadius: KxSpacing.radiusMd,
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.isActive
                ? KxColors.teal400
                : _hovered
                    ? KxColors.textPrimary
                    : KxColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Expanded Sidebar (Desktop: >1200px) ────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _KxExpandedSidebar extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onTap;
  final VoidCallback onSearchTap;

  const _KxExpandedSidebar({
    required this.currentLocation,
    required this.onTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: KxSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(
          right: BorderSide(color: KxColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: KxColors.teal400.withOpacity(0.12),
                      borderRadius: KxSpacing.radiusSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'K',
                      style: KxTypography.headingMd.copyWith(
                        color: KxColors.teal400,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'KONSENXIA',
                    style: KxTypography.headingMd.copyWith(
                      color: KxColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Search bar shortcut
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: KxSpacing.radiusMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: KxColors.bgElevated,
                      borderRadius: KxSpacing.radiusMd,
                      border:
                          Border.all(color: KxColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: KxColors.textMuted, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ara...',
                            style: KxTypography.bodyMd.copyWith(
                              color: KxColors.textMuted,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: KxColors.bgCard,
                            borderRadius: KxSpacing.radiusXs,
                            border: Border.all(
                                color: KxColors.border, width: 0.5),
                          ),
                          child: Text(
                            '\u2318K',
                            style: KxTypography.monoSm.copyWith(
                              color: KxColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'NAVIGASYON',
                style: KxTypography.overline.copyWith(
                  color: KxColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Navigation items
            ..._sidebarTabs.map((tab) {
              final active = _isTabActive(tab, currentLocation);
              return Tooltip(
                message: tab.label,
                waitDuration: const Duration(milliseconds: 800),
                child: _ExpandedSidebarItem(
                  label: tab.label,
                  icon: active ? tab.iconActive : tab.icon,
                  isActive: active,
                  onTap: () => onTap(tab.route),
                ),
              );
            }),
            const Spacer(),
            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(color: KxColors.border, height: 1),
            ),
            const SizedBox(height: 8),
            _ExpandedSidebarItem(
              label: 'Ayarlar',
              icon: Icons.settings_outlined,
              isActive: false,
              onTap: () => onTap('/settings'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ExpandedSidebarItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ExpandedSidebarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ExpandedSidebarItem> createState() => _ExpandedSidebarItemState();
}

class _ExpandedSidebarItemState extends State<_ExpandedSidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? KxColors.teal400.withOpacity(0.12)
                : _hovered
                    ? KxColors.bgHover
                    : Colors.transparent,
            borderRadius: KxSpacing.radiusMd,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive
                    ? KxColors.teal400
                    : _hovered
                        ? KxColors.textPrimary
                        : KxColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: KxTypography.labelLg.copyWith(
                    color: widget.isActive
                        ? KxColors.teal400
                        : _hovered
                            ? KxColors.textPrimary
                            : KxColors.textSecondary,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (widget.isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: KxColors.teal400,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
