import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_colors_light.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// KONSENXIA — Clinical Noir Design System
/// Theme Tokens — Dark Theme (birincil) + Light Theme
abstract final class KxTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary:          KxColors.teal400,
      onPrimary:        KxColors.bgVoid,
      primaryContainer: KxColors.teal900,
      secondary:        KxColors.blue400,
      onSecondary:      KxColors.textPrimary,
      surface:          KxColors.bgSurface,
      onSurface:        KxColors.textPrimary,
      error:            KxColors.crimson500,
      onError:          KxColors.textPrimary,
      outline:          KxColors.border,
      outlineVariant:   KxColors.borderSubtle,
      surfaceContainerHighest: KxColors.bgElevated,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KxColors.bgBase,
      canvasColor: KxColors.bgSurface,
      cardColor: KxColors.bgCard,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: KxColors.bgSurface,
        foregroundColor: KxColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: KxTypography.headingMd.copyWith(
          color: KxColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: KxColors.textSecondary),
        actionsIconTheme: const IconThemeData(color: KxColors.textSecondary),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: KxColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusLg,
          side: const BorderSide(color: KxColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KxColors.teal400,
          foregroundColor: KxColors.bgVoid,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
          textStyle: KxTypography.labelLg,
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KxColors.textPrimary,
          side: const BorderSide(color: KxColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
          textStyle: KxTypography.labelLg,
        ),
      ),

      // ── TextButton ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KxColors.teal400,
          textStyle: KxTypography.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KxColors.bgElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColors.teal500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColors.crimson500),
        ),
        hintStyle: KxTypography.bodyMd.copyWith(color: KxColors.textMuted),
        labelStyle: KxTypography.labelMd.copyWith(color: KxColors.textSecondary),
        errorStyle: KxTypography.caption.copyWith(color: KxColors.crimson300),
        floatingLabelStyle: KxTypography.labelSm.copyWith(color: KxColors.teal400),
      ),

      // ── Typography ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  KxTypography.displayLg,
        displayMedium: KxTypography.displayMd,
        displaySmall:  KxTypography.displaySm,
        headlineLarge: KxTypography.headingLg,
        headlineMedium: KxTypography.headingMd,
        headlineSmall: KxTypography.headingSm,
        bodyLarge:     KxTypography.bodyLg,
        bodyMedium:    KxTypography.bodyMd,
        bodySmall:     KxTypography.bodySm,
        labelLarge:    KxTypography.labelLg,
        labelMedium:   KxTypography.labelMd,
        labelSmall:    KxTypography.labelSm,
        titleLarge:    KxTypography.headingLg,
        titleMedium:   KxTypography.headingMd,
        titleSmall:    KxTypography.headingSm,
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: KxColors.border,
        thickness: 1,
        space: 0,
      ),

      // ── BottomNavigationBar ──────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KxColors.bgSurface,
        selectedItemColor: KxColors.teal400,
        unselectedItemColor: KxColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: KxTypography.labelSm,
        unselectedLabelStyle: KxTypography.labelSm,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: KxColors.bgCard,
        side: const BorderSide(color: KxColors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusXl,
        ),
        labelStyle: KxTypography.labelSm.copyWith(color: KxColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KxColors.bgElevated,
        contentTextStyle: KxTypography.bodyMd.copyWith(
          color: KxColors.textPrimary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusMd,
          side: BorderSide(color: KxColors.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: KxColors.bgElevated,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusXl,
          side: BorderSide(color: KxColors.border),
        ),
        titleTextStyle: KxTypography.headingLg,
        contentTextStyle: KxTypography.bodyMd.copyWith(
          color: KxColors.textSecondary,
        ),
      ),

      // ── PopupMenu ────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: KxColors.bgElevated,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusLg,
          side: BorderSide(color: KxColors.border),
        ),
        textStyle: KxTypography.bodyMd,
      ),

      // ── TabBar ───────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: KxColors.teal400,
        unselectedLabelColor: KxColors.textMuted,
        indicatorColor: KxColors.teal400,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: KxTypography.labelMd,
        unselectedLabelStyle: KxTypography.labelMd,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return KxColors.teal400;
          return KxColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KxColors.teal900;
          }
          return KxColors.bgCard;
        }),
      ),

      // ── ProgressIndicator ────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KxColors.teal400,
        linearTrackColor: KxColors.bgHover,
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary:          KxColorsLight.teal400,
      onPrimary:        Colors.white,
      primaryContainer: KxColorsLight.teal100,
      secondary:        KxColorsLight.blue400,
      onSecondary:      Colors.white,
      surface:          KxColorsLight.bgSurface,
      onSurface:        KxColorsLight.textPrimary,
      error:            KxColorsLight.crimson500,
      onError:          Colors.white,
      outline:          KxColorsLight.border,
      outlineVariant:   KxColorsLight.borderSubtle,
      surfaceContainerHighest: KxColorsLight.bgElevated,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KxColorsLight.bgBase,
      canvasColor: KxColorsLight.bgSurface,
      cardColor: KxColorsLight.bgCard,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: KxColorsLight.bgBase,
        foregroundColor: KxColorsLight.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: KxTypography.headingMd.copyWith(
          color: KxColorsLight.textPrimary,
        ),
        iconTheme: const IconThemeData(color: KxColorsLight.textSecondary),
        actionsIconTheme: const IconThemeData(color: KxColorsLight.textSecondary),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: KxColorsLight.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusLg,
          side: const BorderSide(color: KxColorsLight.border),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KxColorsLight.teal400,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
          textStyle: KxTypography.labelLg,
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KxColorsLight.textPrimary,
          side: const BorderSide(color: KxColorsLight.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
          textStyle: KxTypography.labelLg,
        ),
      ),

      // ── TextButton ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KxColorsLight.teal400,
          textStyle: KxTypography.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: KxSpacing.radiusMd,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KxColorsLight.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColorsLight.teal500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KxSpacing.radiusMd,
          borderSide: const BorderSide(color: KxColorsLight.crimson500),
        ),
        hintStyle: KxTypography.bodyMd.copyWith(color: KxColorsLight.textMuted),
        labelStyle: KxTypography.labelMd.copyWith(color: KxColorsLight.textSecondary),
        errorStyle: KxTypography.caption.copyWith(color: KxColorsLight.crimson300),
        floatingLabelStyle: KxTypography.labelSm.copyWith(color: KxColorsLight.teal400),
      ),

      // ── Typography ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  KxTypography.displayLg.copyWith(color: KxColorsLight.textPrimary),
        displayMedium: KxTypography.displayMd.copyWith(color: KxColorsLight.textPrimary),
        displaySmall:  KxTypography.displaySm.copyWith(color: KxColorsLight.textPrimary),
        headlineLarge: KxTypography.headingLg.copyWith(color: KxColorsLight.textPrimary),
        headlineMedium: KxTypography.headingMd.copyWith(color: KxColorsLight.textPrimary),
        headlineSmall: KxTypography.headingSm.copyWith(color: KxColorsLight.textPrimary),
        bodyLarge:     KxTypography.bodyLg.copyWith(color: KxColorsLight.textPrimary),
        bodyMedium:    KxTypography.bodyMd.copyWith(color: KxColorsLight.textPrimary),
        bodySmall:     KxTypography.bodySm.copyWith(color: KxColorsLight.textSecondary),
        labelLarge:    KxTypography.labelLg.copyWith(color: KxColorsLight.textPrimary),
        labelMedium:   KxTypography.labelMd.copyWith(color: KxColorsLight.textPrimary),
        labelSmall:    KxTypography.labelSm.copyWith(color: KxColorsLight.textSecondary),
        titleLarge:    KxTypography.headingLg.copyWith(color: KxColorsLight.textPrimary),
        titleMedium:   KxTypography.headingMd.copyWith(color: KxColorsLight.textPrimary),
        titleSmall:    KxTypography.headingSm.copyWith(color: KxColorsLight.textPrimary),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: KxColorsLight.border,
        thickness: 1,
        space: 0,
      ),

      // ── BottomNavigationBar ──────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KxColorsLight.bgBase,
        selectedItemColor: KxColorsLight.teal400,
        unselectedItemColor: KxColorsLight.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: KxTypography.labelSm,
        unselectedLabelStyle: KxTypography.labelSm,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: KxColorsLight.bgSurface,
        side: const BorderSide(color: KxColorsLight.border),
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusXl,
        ),
        labelStyle: KxTypography.labelSm.copyWith(color: KxColorsLight.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KxColorsLight.bgCard,
        contentTextStyle: KxTypography.bodyMd.copyWith(
          color: KxColorsLight.textPrimary,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusMd,
          side: BorderSide(color: KxColorsLight.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ───────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: KxColorsLight.bgCard,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusXl,
          side: BorderSide(color: KxColorsLight.border),
        ),
        titleTextStyle: KxTypography.headingLg.copyWith(color: KxColorsLight.textPrimary),
        contentTextStyle: KxTypography.bodyMd.copyWith(
          color: KxColorsLight.textSecondary,
        ),
      ),

      // ── PopupMenu ────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: KxColorsLight.bgCard,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusLg,
          side: BorderSide(color: KxColorsLight.border),
        ),
        textStyle: KxTypography.bodyMd.copyWith(color: KxColorsLight.textPrimary),
      ),

      // ── TabBar ───────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: KxColorsLight.teal400,
        unselectedLabelColor: KxColorsLight.textMuted,
        indicatorColor: KxColorsLight.teal400,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: KxTypography.labelMd,
        unselectedLabelStyle: KxTypography.labelMd,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return KxColorsLight.teal400;
          return KxColorsLight.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KxColorsLight.teal100;
          }
          return KxColorsLight.bgElevated;
        }),
      ),

      // ── ProgressIndicator ────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KxColorsLight.teal400,
        linearTrackColor: KxColorsLight.bgElevated,
      ),
    );
  }
}
