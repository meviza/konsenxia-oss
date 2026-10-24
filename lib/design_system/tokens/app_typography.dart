import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// KONSENXIA — Clinical Noir Design System
/// Typography Tokens
///
/// Font seçimi:
///   - Instrument Serif → Başlıklar (tıbbi dergi otoritesi)
///   - IBM Plex Sans    → Gövde metni (teknik netlik)
///   - IBM Plex Mono    → Veri / kod / lab değerleri (klinik hassasiyet)
abstract final class KxTypography {
  // ── Font Families ─────────────────────────────────────────────

  /// Başlıklar, hero text — serif otorite hissi
  static TextStyle get _displayBase => GoogleFonts.instrumentSerif(
    color: KxColors.textPrimary,
    fontFeatures: const [FontFeature.enable('kern')],
  );

  /// Gövde, UI elementleri — teknik okunabilirlik
  static TextStyle get _bodyBase => GoogleFonts.ibmPlexSans(
    color: KxColors.textPrimary,
  );

  /// Lab değerleri, kodlar, ilaç isimleri — mono hassasiyet
  static TextStyle get _monoBase => GoogleFonts.ibmPlexMono(
    color: KxColors.textPrimary,
  );

  // ── Display Scale (Instrument Serif) ─────────────────────────

  /// H1 — hero başlıklar, onboarding
  static TextStyle get displayLg => _displayBase.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.5,
    height: 1.1,
  );

  /// H2 — sayfa başlıkları
  static TextStyle get displayMd => _displayBase.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.8,
    height: 1.2,
  );

  /// H3 — section başlıkları
  static TextStyle get displaySm => _displayBase.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    height: 1.3,
  );

  // ── Heading Scale (IBM Plex Sans) ────────────────────────────

  static TextStyle get headingLg => _bodyBase.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.4,
  );

  static TextStyle get headingMd => _bodyBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle get headingSm => _bodyBase.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ── Body Scale (IBM Plex Sans) ───────────────────────────────

  /// Ana metin
  static TextStyle get bodyLg => _bodyBase.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodyMd => _bodyBase.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodySm => _bodyBase.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Label Scale ──────────────────────────────────────────────

  static TextStyle get labelLg => _bodyBase.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle get labelMd => _bodyBase.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle get labelSm => _bodyBase.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // ── Caption / Overline ───────────────────────────────────────

  static TextStyle get caption => _bodyBase.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: KxColors.textMuted,
    height: 1.4,
  );

  /// Bölüm etiketleri — tüm büyük harf, geniş tracking
  static TextStyle get overline => _monoBase.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    height: 1.4,
    color: KxColors.textMuted,
  );

  // ── Mono Scale (IBM Plex Mono) ───────────────────────────────

  /// Lab değerleri, vital signs, büyük sayılar
  static TextStyle get monoLg => _monoBase.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get monoMd => _monoBase.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get monoSm => _monoBase.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ── Convenience extensions ────────────────────────────────────

  /// Vaka kodu, ID, timestamp'ler için
  static TextStyle get caseId => _monoBase.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    color: KxColors.textDisabled,
  );

  /// Tıbbi terim vurgusu (italic serif)
  static TextStyle get medicalTerm => _displayBase.copyWith(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: KxColors.teal300,
    height: 1.4,
  );
}
