import 'package:flutter/material.dart';

/// KONSENXIA — Clinical Noir Design System
/// Spacing & Layout Tokens
///
/// 4px grid sistemi. Tüm margin, padding, gap değerleri
/// bu sabitlerden türetilir.
abstract final class KxSpacing {
  // ── Base Grid: 4px ───────────────────────────────────────────
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 28.0;
  static const double xl4 = 32.0;
  static const double xl5 = 40.0;
  static const double xl6 = 48.0;
  static const double xl8 = 64.0;

  // ── EdgeInsets shortcuts ─────────────────────────────────────
  static const EdgeInsets pagePadding    = EdgeInsets.all(xl2);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: xl2, vertical: xl,
  );
  static const EdgeInsets screenPadding  = EdgeInsets.symmetric(horizontal: xl2, vertical: xl2);
  static const EdgeInsets cardPadding    = EdgeInsets.all(xl);
  static const EdgeInsets cardPaddingLg  = EdgeInsets.all(xl2);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg, vertical: md,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: md, vertical: xs + 2,
  );

  // ── Border Radius ─────────────────────────────────────────────
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(6));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(100));
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(100));

  // ── Icon Sizes ───────────────────────────────────────────────
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ── Avatar Sizes ─────────────────────────────────────────────
  static const double avatarSm = 28.0;
  static const double avatarMd = 36.0;
  static const double avatarLg = 44.0;
  static const double avatarXl = 56.0;

  // ── Touch Target (min 44x44) ─────────────────────────────────
  static const double touchTarget = 44.0;

  // ── Content Padding (desktop geniş ekran içerik alanı) ──────
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: xl2, vertical: xl2,
  );

  // ── Sidebar Width ────────────────────────────────────────────
  static const double sidebarWidth      = 240.0;
  static const double rightPanelWidth   = 300.0;
  static const double chatSidebarWidth  = 260.0;
}
