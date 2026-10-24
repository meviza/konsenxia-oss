import 'package:flutter/material.dart';

/// KONSENXIA — Light Mode Color Tokens
///
/// Koyu tema yapısını yansılar, açık zemin renkleriyle.
/// Aksanlar (teal, amber, crimson, jade) korunur.
///
/// Kullanım:
///   Container(color: KxColorsLight.bgSurface)
abstract final class KxColorsLight {
  // ── Background Scale ──────────────────────────────────────────
  static const Color bgVoid     = Color(0xFFF8FAFC); // En açık zemin
  static const Color bgBase     = Color(0xFFFFFFFF); // Ana sayfa zemini
  static const Color bgSurface  = Color(0xFFF1F5F9); // Kart/panel zemini
  static const Color bgElevated = Color(0xFFE2E8F0); // Yükseltilmiş yüzey
  static const Color bgCard     = Color(0xFFFFFFFF); // Kart içeriği
  static const Color bgHover    = Color(0xFFE2E8F0); // Hover state

  // ── Clinical Teal — birincil kimlik rengi ────────────────────
  static const Color teal900 = Color(0xFF003D37);
  static const Color teal700 = Color(0xFF005F56);
  static const Color teal500 = Color(0xFF00A896);
  static const Color teal400 = Color(0xFF00A896); // Primary — biraz koyu
  static const Color teal300 = Color(0xFF00C4B0);
  static const Color teal100 = Color(0xFFB3F5EE);

  // ── Electric Blue ─────────────────────────────────────────────
  static const Color blue500 = Color(0xFF2563EB);
  static const Color blue400 = Color(0xFF3B82F6);
  static const Color blue300 = Color(0xFF60A5FA);

  // ── Amber ─────────────────────────────────────────────────────
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber300 = Color(0xFFFCD34D);

  // ── Crimson ───────────────────────────────────────────────────
  static const Color crimson500 = Color(0xFFDC2626);
  static const Color crimson400 = Color(0xFFEF4444);
  static const Color crimson300 = Color(0xFFF87171);

  // ── Jade ──────────────────────────────────────────────────────
  static const Color jade500 = Color(0xFF059669);
  static const Color jade300 = Color(0xFF34D399);

  // ── Metin ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted     = Color(0xFF94A3B8);
  static const Color textDisabled  = Color(0xFFCBD5E1);

  // ── Sınır ─────────────────────────────────────────────────────
  static const Color border       = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // ── Overlay'ler ───────────────────────────────────────────────
  static Color tealGlow(double opacity) =>
      teal400.withOpacity(opacity);
  static Color blueGlow(double opacity) =>
      blue400.withOpacity(opacity);

  // ── Semantic shortcuts ────────────────────────────────────────
  static const Color primary   = teal400;
  static const Color secondary = blue400;
  static const Color warning   = amber500;
  static const Color error     = crimson500;
  static const Color success   = jade500;
}
