import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTextStyles {
  // Base Text Styles
  static TextStyle get base => GoogleFonts.outfit();
  
  // Display Styles
  static TextStyle get displayLarge => base.copyWith(
    fontSize: AppConstants.fontSizeXXXLarge,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
  );
  
  static TextStyle get displayMedium => base.copyWith(
    fontSize: AppConstants.fontSizeXXLarge,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.75,
  );
  
  static TextStyle get displaySmall => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  // Headline Styles
  static TextStyle get headlineLarge => base.copyWith(
    fontSize: AppConstants.fontSizeXXLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
  );
  
  static TextStyle get headlineMedium => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  
  static TextStyle get headlineSmall => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );
  
  // Title Styles
  static TextStyle get titleLarge => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static TextStyle get titleMedium => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static TextStyle get titleSmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  // Body Styles
  static TextStyle get bodyLarge => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
  );
  
  static TextStyle get bodyMedium => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  static TextStyle get bodySmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
  );
  
  // Label Styles
  static TextStyle get labelLarge => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static TextStyle get labelMedium => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static TextStyle get labelSmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 2,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  // Button Styles
  static TextStyle get buttonXLarge => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonLarge => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonMedium => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonSmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // Caption Styles
  static TextStyle get captionLarge => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get captionMedium => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 2,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get captionSmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 4,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  // Overline Styles
  static TextStyle get overlineLarge => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.5,
  );
  
  static TextStyle get overlineMedium => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 2,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.5,
  );
  
  static TextStyle get overlineSmall => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 4,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.5,
  );
  
  // Custom Styles
  static TextStyle get appBarTitle => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
  );
  
  static TextStyle get appBarSubtitle => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static TextStyle get cardTitle => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );
  
  static TextStyle get cardSubtitle => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static TextStyle get cardDescription => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  static TextStyle get listTileTitle => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.15,
  );
  
  static TextStyle get listTileSubtitle => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static TextStyle get dialogTitle => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );
  
  static TextStyle get dialogContent => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  static TextStyle get inputLabel => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
  );
  
  static TextStyle get inputHint => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static TextStyle get inputText => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static TextStyle get errorText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get successText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get warningText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get infoText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get chipText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get badgeText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall - 2,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static TextStyle get tabText => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 1.25,
  );
  
  static TextStyle get bottomNavText => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static TextStyle get heroTitle => base.copyWith(
    fontSize: AppConstants.fontSizeXXXLarge + 8,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
  );
  
  static TextStyle get heroSubtitle => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );
  
  static TextStyle get sectionTitle => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static TextStyle get sectionSubtitle => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  static TextStyle get priceLarge => base.copyWith(
    fontSize: AppConstants.fontSizeXXLarge,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );
  
  static TextStyle get priceMedium => base.copyWith(
    fontSize: AppConstants.fontSizeXLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
  );
  
  static TextStyle get priceSmall => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );
  
  static TextStyle get statValue => base.copyWith(
    fontSize: AppConstants.fontSizeXXLarge,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );
  
  static TextStyle get statLabel => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static TextStyle get code => base.copyWith(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
    fontFamily: 'monospace',
  );
  
  static TextStyle get quote => base.copyWith(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w300,
    height: 1.6,
    letterSpacing: 0.25,
    fontStyle: FontStyle.italic,
  );
  
  static TextStyle get link => base.copyWith(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.25,
    decoration: TextDecoration.underline,
  );
  
  // Utility methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
  
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }
  
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }
  
  static TextStyle withFontStyle(TextStyle style, FontStyle fontStyle) {
    return style.copyWith(fontStyle: fontStyle);
  }
  
  static TextStyle withFontFamily(TextStyle style, String fontFamily) {
    return style.copyWith(fontFamily: fontFamily);
  }
  
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
  
  static TextStyle withLineThrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }
  
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }
  
  static TextStyle withOverline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.overline);
  }
  
  static TextStyle withCaps(TextStyle style, {bool allCaps = false}) {
    return style.copyWith(
      textBaseline: allCaps ? TextBaseline.alphabetic : style.textBaseline,
    );
  }
  
  static TextStyle withSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }
  
  static TextStyle withWordSpacing(TextStyle style, double wordSpacing) {
    return style.copyWith(wordSpacing: wordSpacing);
  }
}
