import 'package:flutter/material.dart';

/// KONSENXIA — Clinical Noir Design System
/// Color Tokens
///
/// Kullanım:
///   Container(color: KxColors.bgSurface)
///   Text('...', style: TextStyle(color: KxColors.textPrimary))
abstract final class KxColors {
  // ── Background Scale ──────────────────────────────────────────
  static const Color bgVoid     = Color(0xFF060A14); // Tam karanlık zemin
  static const Color bgBase     = Color(0xFF0A0F1E); // Ana sayfa zemini
  static const Color bgSurface  = Color(0xFF0E1628); // Kart/panel zemini
  static const Color bgElevated = Color(0xFF141E35); // Yükseltilmiş yüzey
  static const Color bgCard     = Color(0xFF192240); // Kart içeriği
  static const Color bgHover    = Color(0xFF1E2A4A); // Hover state

  // ── Clinical Teal — birincil kimlik rengi ────────────────────
  static const Color teal900 = Color(0xFF003D37);
  static const Color teal700 = Color(0xFF005F56);
  static const Color teal500 = Color(0xFF00A896); // Active state
  static const Color teal400 = Color(0xFF00C4B0); // Primary — CTA'lar
  static const Color teal300 = Color(0xFF00D9C3); // Vurgu / başlık
  static const Color teal100 = Color(0xFFB3F5EE); // Çok açık teal

  // ── Electric Blue — interaktif elementler ───────────────────
  static const Color blue500 = Color(0xFF2563EB);
  static const Color blue400 = Color(0xFF3B82F6);
  static const Color blue300 = Color(0xFF60A5FA);

  // ── Amber — XP / uyarı / lab değerleri ──────────────────────
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber300 = Color(0xFFFCD34D);

  // ── Crimson — kritik / acil ──────────────────────────────────
  static const Color crimson500 = Color(0xFFDC2626);
  static const Color crimson400 = Color(0xFFEF4444);
  static const Color crimson300 = Color(0xFFF87171);

  // ── Jade — başarı / normal değerler ─────────────────────────
  static const Color jade500 = Color(0xFF059669);
  static const Color jade300 = Color(0xFF34D399);

  // ── Metin ────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B96B5);
  static const Color textMuted     = Color(0xFF4A5578);
  static const Color textDisabled  = Color(0xFF2D3556);

  // ── Sınır ────────────────────────────────────────────────────
  static const Color border       = Color(0xFF1E2C4F);
  static const Color borderSubtle = Color(0xFF131D38);

  // ── Overlay'ler (opacity ile) ─────────────────────────────────
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

  // ── Uzmanlık renkleri (specialty badge'ler için) ──────────────
  static const Map<String, Color> specialtyColors = {
    'kardiyoloji':    teal400,
    'nöroloji':       blue400,
    'endokrinoloji':  amber500,
    'onkoloji':       crimson300,
    'pediatri':       Color(0xFF818CF8), // indigo
    'ortopedi':       Color(0xFF34D399), // jade
    'psikiyatri':     Color(0xFFA78BFA), // violet
    'genel_cerrahi':  Color(0xFF94A3B8), // slate
  };
}
