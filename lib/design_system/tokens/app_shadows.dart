import 'package:flutter/material.dart';
import 'app_colors.dart';

/// KONSENXIA — Clinical Noir Design System
/// Shadow & Glow Tokens
abstract final class KxShadows {
  // ── Standart Gölgeler ────────────────────────────────────────

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 40,
      offset: Offset(0, 8),
    ),
  ];

  // ── Teal Glow — primary elementler için ─────────────────────
  static List<BoxShadow> tealGlow({double opacity = 0.18}) => [
    BoxShadow(
      color: KxColors.teal400.withOpacity(opacity),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> tealGlowStrong({double opacity = 0.35}) => [
    BoxShadow(
      color: KxColors.teal400.withOpacity(opacity),
      blurRadius: 32,
      spreadRadius: 2,
    ),
  ];

  // ── Blue Glow — secondary/interactive elementler ─────────────
  static List<BoxShadow> blueGlow({double opacity = 0.15}) => [
    BoxShadow(
      color: KxColors.blue400.withOpacity(opacity),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // ── Amber Glow — XP, level, premium ─────────────────────────
  static List<BoxShadow> amberGlow({double opacity = 0.2}) => [
    BoxShadow(
      color: KxColors.amber500.withOpacity(opacity),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // ── Card Hover — card:hover efekti ──────────────────────────
  static List<BoxShadow> cardHover = [
    BoxShadow(
      color: KxColors.teal400.withOpacity(0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    const BoxShadow(
      color: Color(0x66000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // ── Focus Ring — input focus state ───────────────────────────
  static List<BoxShadow> focusRing = [
    BoxShadow(
      color: KxColors.teal500.withOpacity(0.12),
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];
}
