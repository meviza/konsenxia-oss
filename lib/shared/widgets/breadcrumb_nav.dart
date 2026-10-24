import 'package:flutter/material.dart';

import '../../design_system/tokens/app_colors.dart';
import '../../design_system/tokens/app_typography.dart';
import '../../design_system/tokens/app_spacing.dart';

/// KONSENXIA — Breadcrumb Navigation Widget
///
/// Geniş ekranlarda (>1200px) gösterilen yatay breadcrumb gezinme bileşeni.
/// Örnek: Anasayfa › Vakalar › Vaka Detayı
///
/// Kullanım:
/// ```dart
/// KxBreadcrumbNav(
///   items: [
///     KxBreadcrumbItem(label: 'Anasayfa', route: '/dashboard'),
///     KxBreadcrumbItem(label: 'Vakalar', route: '/cases'),
///     KxBreadcrumbItem(label: 'Vaka Detayı'),
///   ],
///   onNavigate: (route) => context.go(route),
/// )
/// ```
class KxBreadcrumbNav extends StatelessWidget {
  /// Breadcrumb öğeleri (soldan sağa, ilk öğe kök).
  final List<KxBreadcrumbItem> items;

  /// Tıklanabilir bir öğeye dokunulduğunda çağrılır.
  final ValueChanged<String>? onNavigate;

  const KxBreadcrumbNav({
    super.key,
    required this.items,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Yalnızca geniş ekranlarda göster (>1200px)
    if (width <= 1200) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KxSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildItems(),
      ),
    );
  }

  List<Widget> _buildItems() {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      if (isLast) {
        // Son öğe: aktif, tıklanamaz
        widgets.add(
          Text(
            item.label,
            style: KxTypography.labelMd.copyWith(
              color: KxColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        // Tıklanabilir öğe
        widgets.add(
          _BreadcrumbClickableItem(
            label: item.label,
            onTap: item.route != null && onNavigate != null
                ? () => onNavigate!(item.route!)
                : null,
          ),
        );
        // Ayırıcı
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KxSpacing.sm),
            child: Text(
              '\u203A',
              style: KxTypography.labelMd.copyWith(
                color: KxColors.textDisabled,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

// ── Breadcrumb Item Model ─────────────────────────────────────────────────

/// Bir breadcrumb öğesini temsil eder.
///
/// [route] null ise öğe tıklanamaz (genellikle son öğe).
class KxBreadcrumbItem {
  final String label;
  final String? route;

  const KxBreadcrumbItem({
    required this.label,
    this.route,
  });
}

// ── Clickable Breadcrumb Item (with hover) ────────────────────────────────

class _BreadcrumbClickableItem extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _BreadcrumbClickableItem({
    required this.label,
    this.onTap,
  });

  @override
  State<_BreadcrumbClickableItem> createState() =>
      _BreadcrumbClickableItemState();
}

class _BreadcrumbClickableItemState extends State<_BreadcrumbClickableItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: KxSpacing.xs + 2,
            vertical: KxSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _hovered ? KxColors.bgHover : Colors.transparent,
            borderRadius: KxSpacing.radiusSm,
          ),
          child: Text(
            widget.label,
            style: KxTypography.labelMd.copyWith(
              color: _hovered ? KxColors.teal400 : KxColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
