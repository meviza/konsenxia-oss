import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// KONSENXIA Template — KxDashboardTemplate
///
/// Dashboard sayfa iskeleti.
/// Sidebar (desktop/tablet) + üst bar + scroll edilebilir içerik alanı.
/// Mobil'de sidebar gizlenir, alt navigation bar opsiyonel olarak eklenir.
///
/// Kullanım:
/// ```dart
/// KxDashboardTemplate(
///   title: 'Dashboard',
///   body: Column(children: [...]),
///   actions: [IconButton(...)],
///   sidebar: KxSidebar(...),
/// )
/// ```
class KxDashboardTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? sidebar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool scrollable;

  const KxDashboardTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.sidebar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showAppBar = true,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: KxColors.bgBase,
      appBar: showAppBar && !isWide ? _buildAppBar(context) : null,
      body: isWide ? _buildWide(context) : _buildNarrow(context),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: KxColors.bgSurface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF0F4FF),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: const Color(0xFF8B96B5),
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: KxColors.border),
      ),
    );
  }

  // ── Narrow (mobil) ────────────────────────────────────────────

  Widget _buildNarrow(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        padding: KxSpacing.pagePadding,
        child: body,
      );
    }
    return Padding(
      padding: KxSpacing.pagePadding,
      child: body,
    );
  }

  // ── Wide (tablet/desktop) — sidebar + içerik ──────────────────

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        if (sidebar != null)
          SizedBox(width: KxSpacing.sidebarWidth, child: sidebar!),

        // İçerik
        Expanded(
          child: Column(
            children: [
              // Üst bar (desktop)
              _buildDesktopTopBar(context),

              // İçerik scroll
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        padding: KxSpacing.contentPadding,
                        child: body,
                      )
                    : Padding(
                        padding: KxSpacing.contentPadding,
                        child: body,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: KxColors.bgSurface,
        border: Border(bottom: BorderSide(color: KxColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF0F4FF),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF8B96B5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
