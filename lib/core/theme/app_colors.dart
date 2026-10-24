import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppColors {
  // Primary Colors
  static const Color primary = AppConstants.primaryColor;
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = AppConstants.secondaryColor;
  static const Color secondaryVariant = Color(0xFF0097A7);
  
  // Accent Colors
  static const Color accent = AppConstants.accentColor;
  static const Color accentVariant = Color(0xFFE91E63);
  
  // Status Colors
  static const Color success = AppConstants.successColor;
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color warning = AppConstants.warningColor;
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color error = AppConstants.errorColor;
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = AppConstants.infoColor;
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1976D2);
  
  // Text Colors
  static const Color textPrimary = AppConstants.textPrimaryColor;
  static const Color textSecondary = AppConstants.textSecondaryColor;
  static const Color textDisabled = AppConstants.textDisabledColor;
  static const Color textHint = AppConstants.textHintColor;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  static const Color textOnAccent = Colors.white;
  
  // Background Colors
  static const Color background = AppConstants.backgroundColor;
  static const Color surface = AppConstants.surfaceColor;
  static const Color card = AppConstants.cardColor;
  static const Color divider = AppConstants.dividerColor;
  
  // Dark Theme Colors
  static const Color darkBackground = AppConstants.darkBackgroundColor;
  static const Color darkSurface = AppConstants.darkSurfaceColor;
  static const Color darkCard = AppConstants.darkCardColor;
  static const Color darkDivider = AppConstants.darkDividerColor;
  
  // Dark Theme Text Colors
  static const Color darkTextPrimary = AppConstants.darkTextPrimaryColor;
  static const Color darkTextSecondary = AppConstants.darkTextSecondaryColor;
  static const Color darkTextDisabled = AppConstants.darkTextDisabledColor;
  static const Color darkTextHint = AppConstants.darkTextHintColor;
  
  // Glass Effect Colors (Enhanced)
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);
  static const Color glassShadow = Color(0x66000000);
  
  // Dark Theme Glass Effect Colors (Luminescent)
  static const Color darkGlassBackground = Color(0x2600E5FF); // Tinted with Primary
  static const Color darkGlassBorder = Color(0x4000E5FF);
  static const Color darkGlassShadow = Color(0x80000000);
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x3F000000);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    primary,
    primaryVariant,
  ];
  
  static const List<Color> secondaryGradient = [
    secondary,
    secondaryVariant,
  ];
  
  static const List<Color> accentGradient = [
    accent,
    accentVariant,
  ];
  
  static const List<Color> successGradient = [
    success,
    Color(0xFF66BB6A),
  ];
  
  static const List<Color> warningGradient = [
    warning,
    Color(0xFFFFB74D),
  ];
  
  static const List<Color> errorGradient = [
    error,
    Color(0xFFEF5350),
  ];
  
  static const List<Color> infoGradient = [
    info,
    Color(0xFF42A5F5),
  ];
  
  // Status Colors
  static const Color online = AppConstants.onlineColor;
  static const Color offline = AppConstants.offlineColor;
  static const Color busy = AppConstants.busyColor;
  static const Color away = AppConstants.awayColor;
  
  // Priority Colors
  static const Color lowPriority = AppConstants.lowPriorityColor;
  static const Color mediumPriority = AppConstants.mediumPriorityColor;
  static const Color highPriority = AppConstants.highPriorityColor;
  static const Color criticalPriority = AppConstants.criticalPriorityColor;
  
  // Category Colors
  static const List<Color> categories = AppConstants.categoryColors;
  
  // Chart Colors
  static const List<Color> charts = AppConstants.chartColors;
  
  // Social Media Colors
  static const Color facebook = AppConstants.facebookColor;
  static const Color twitter = AppConstants.twitterColor;
  static const Color google = AppConstants.googleColor;
  static const Color linkedin = AppConstants.linkedinColor;
  static const Color instagram = AppConstants.instagramColor;
  static const Color youtube = AppConstants.youtubeColor;
  
  // Payment Colors
  static const Color visa = AppConstants.visaColor;
  static const Color mastercard = AppConstants.mastercardColor;
  static const Color amex = AppConstants.amexColor;
  static const Color paypal = AppConstants.paypalColor;
  
  // Brand Colors
  static const Color apple = AppConstants.appleColor;
  static const Color android = AppConstants.androidColor;
  static const Color windows = AppConstants.windowsColor;
  static const Color linux = AppConstants.linuxColor;
  
  // Accessibility Colors
  static const Color highContrast = AppConstants.highContrastColor;
  static const Color lowContrast = AppConstants.lowContrastColor;
  static const Color focus = AppConstants.focusColor;
  static const Color selected = AppConstants.selectedColor;
  static const Color disabled = AppConstants.disabledColor;
  
  // Loading Colors
  static const Color loadingPrimary = AppConstants.loadingPrimaryColor;
  static const Color loadingSecondary = AppConstants.loadingSecondaryColor;
  static const Color loadingBackground = AppConstants.loadingBackgroundColor;
  
  // Empty State Colors
  static const Color emptyStateIcon = AppConstants.emptyStateIconColor;
  static const Color emptyStateText = AppConstants.emptyStateTextColor;
  static const Color emptyStateBackground = AppConstants.emptyStateBackgroundColor;
  
  // Network Error Colors
  static const Color networkError = AppConstants.networkErrorColor;
  static const Color networkErrorBackground = AppConstants.networkErrorBackgroundColor;
  static const Color networkErrorText = AppConstants.networkErrorTextColor;
  
  // Validation Error Colors
  static const Color validationError = AppConstants.validationErrorColor;
  static const Color validationErrorBackground = AppConstants.validationErrorBackgroundColor;
  static const Color validationErrorText = AppConstants.validationErrorTextColor;
  
  // Success State Colors
  static const Color successIcon = AppConstants.successIconColor;
  static const Color successBackground = AppConstants.successBackgroundColor;
  static const Color successText = AppConstants.successTextColor;
  
  // Warning State Colors
  static const Color warningIcon = AppConstants.warningIconColor;
  static const Color warningBackground = AppConstants.warningBackgroundColor;
  static const Color warningText = AppConstants.warningTextColor;
  
  // Info State Colors
  static const Color infoIcon = AppConstants.infoIconColor;
  static const Color infoBackground = AppConstants.infoBackgroundColor;
  static const Color infoText = AppConstants.infoTextColor;
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color borderFocus = primary;
  static const Color borderError = error;
  static const Color borderSuccess = success;
  static const Color borderWarning = warning;
  
  // Dark Border Colors
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkBorderLight = Color(0xFF616161);
  static const Color darkBorderDark = Color(0xFF303030);
  static const Color darkBorderFocus = primary;
  static const Color darkBorderError = error;
  static const Color darkBorderSuccess = success;
  static const Color darkBorderWarning = warning;
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayDark = Color(0xC0000000);
  
  // Skeleton Colors
  static const Color skeletonBase = Color(0xFFE0E0E0);
  static const Color skeletonHighlight = Color(0xFFF5F5F5);
  static const Color darkSkeletonBase = Color(0xFF424242);
  static const Color darkSkeletonHighlight = Color(0xFF616161);
  
  // Shimmer Colors
  static const Color shimmerBase = AppConstants.shimmerBaseColor;
  static const Color shimmerHighlight = AppConstants.shimmerHighlightColor;
  static const Color darkShimmerBase = Color(0xFF424242);
  static const Color darkShimmerHighlight = Color(0xFF616161);
  
  // Rating Colors
  static const Color ratingActive = Color(0xFFFFD700);
  static const Color ratingInactive = Color(0xFFE0E0E0);
  static const Color darkRatingActive = Color(0xFFFFD700);
  static const Color darkRatingInactive = Color(0xFF424242);
  
  // Progress Colors
  static const Color progressBackground = Color(0xFFE0E0E0);
  static const Color progressForeground = primary;
  static const Color darkProgressBackground = Color(0xFF424242);
  static const Color darkProgressForeground = primary;
  
  // Switch Colors
  static const Color switchActive = primary;
  static const Color switchInactive = Color(0xFFBDBDBD);
  static const Color switchThumb = Colors.white;
  static const Color darkSwitchActive = primary;
  static const Color darkSwitchInactive = Color(0xFF616161);
  static const Color darkSwitchThumb = Colors.white;
  
  // Checkbox Colors
  static const Color checkboxActive = primary;
  static const Color checkboxInactive = Color(0xFFBDBDBD);
  static const Color checkboxCheck = Colors.white;
  static const Color darkCheckboxActive = primary;
  static const Color darkCheckboxInactive = Color(0xFF616161);
  static const Color darkCheckboxCheck = Colors.white;
  
  // Radio Colors
  static const Color radioActive = primary;
  static const Color radioInactive = Color(0xFFBDBDBD);
  static const Color radioDot = Colors.white;
  static const Color darkRadioActive = primary;
  static const Color darkRadioInactive = Color(0xFF616161);
  static const Color darkRadioDot = Colors.white;
  
  // Slider Colors
  static const Color sliderActive = primary;
  static const Color sliderInactive = Color(0xFFE0E0E0);
  static const Color sliderThumb = primary;
  static const Color darkSliderActive = primary;
  static const Color darkSliderInactive = Color(0xFF424242);
  static const Color darkSliderThumb = primary;
  
  // Badge Colors
  static const Color badgePrimary = primary;
  static const Color badgeSecondary = secondary;
  static const Color badgeSuccess = success;
  static const Color badgeWarning = warning;
  static const Color badgeError = error;
  static const Color badgeInfo = info;
  
  // Tab Colors
  static const Color tabActive = primary;
  static const Color tabInactive = Color(0xFF757575);
  static const Color tabIndicator = primary;
  static const Color darkTabActive = primary;
  static const Color darkTabInactive = Color(0xFFB3B3B3);
  static const Color darkTabIndicator = primary;
  
  // Bottom Navigation Colors
  static const Color bottomNavActive = primary;
  static const Color bottomNavInactive = Color(0xFF757575);
  static const Color darkBottomNavActive = primary;
  static const Color darkBottomNavInactive = Color(0xFFB3B3B3);
  
  // AppBar Colors
  static const Color appBarBackground = primary;
  static const Color appBarForeground = Colors.white;
  static const Color darkAppBarBackground = primary;
  static const Color darkAppBarForeground = Colors.white;
  
  // FloatingActionButton Colors
  static const Color fabBackground = accent;
  static const Color fabForeground = Colors.white;
  static const Color darkFabBackground = accent;
  static const Color darkFabForeground = Colors.white;
  
  // Chip Colors
  static const Color chipBackground = Color(0xFFE0E0E0);
  static const Color chipForeground = Color(0xFF212121);
  static const Color chipSelectedBackground = primary;
  static const Color chipSelectedForeground = Colors.white;
  static const Color darkChipBackground = Color(0xFF424242);
  static const Color darkChipForeground = Color(0xFFFFFFFF);
  static const Color darkChipSelectedBackground = primary;
  static const Color darkChipSelectedForeground = Colors.white;
  
  // Dialog Colors
  static const Color dialogBackground = Colors.white;
  static const Color dialogForeground = Color(0xFF212121);
  static const Color darkDialogBackground = Color(0xFF2D2D2D);
  static const Color darkDialogForeground = Color(0xFFFFFFFF);
  
  // Bottom Sheet Colors
  static const Color sheetBackground = Colors.white;
  static const Color sheetForeground = Color(0xFF212121);
  static const Color darkSheetBackground = Color(0xFF2D2D2D);
  static const Color darkSheetForeground = Color(0xFFFFFFFF);
  
  // Toast Colors
  static const Color toastBackground = Color(0xFF323232);
  static const Color toastForeground = Colors.white;
  static const Color darkToastBackground = Color(0xFF323232);
  static const Color darkToastForeground = Colors.white;
  
  // SnackBar Colors
  static const Color snackbarBackground = Color(0xFF323232);
  static const Color snackbarForeground = Colors.white;
  static const Color darkSnackbarBackground = Color(0xFF323232);
  static const Color darkSnackbarForeground = Colors.white;
  
  // Tooltip Colors
  static const Color tooltipBackground = Color(0xFF616161);
  static const Color tooltipForeground = Colors.white;
  static const Color darkTooltipBackground = Color(0xFF424242);
  static const Color darkTooltipForeground = Colors.white;
  
  // Banner Colors
  static const Color bannerBackground = Color(0xFFFFF8E1);
  static const Color bannerForeground = Color(0xFF212121);
  static const Color darkBannerBackground = Color(0xFF424242);
  static const Color darkBannerForeground = Color(0xFFFFFFFF);
  
  // Divider Colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color darkDividerColor = Color(0xFF424242);
  
  // Input Field Colors
  static const Color inputBackground = Colors.white;
  static const Color inputForeground = Color(0xFF212121);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = primary;
  static const Color inputErrorBorder = error;
  static const Color darkInputBackground = Color(0xFF2D2D2D);
  static const Color darkInputForeground = Color(0xFFFFFFFF);
  static const Color darkInputBorder = Color(0xFF424242);
  static const Color darkInputFocusBorder = primary;
  static const Color darkInputErrorBorder = error;
  
  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonPrimaryForeground = Colors.white;
  static const Color buttonSecondary = secondary;
  static const Color buttonSecondaryForeground = Colors.white;
  static const Color buttonOutline = primary;
  static const Color buttonOutlineForeground = primary;
  static const Color buttonGhost = primary;
  static const Color buttonGhostForeground = primary;
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonDisabledForeground = Colors.white;
  static const Color darkButtonPrimary = primary;
  static const Color darkButtonPrimaryForeground = Colors.white;
  static const Color darkButtonSecondary = secondary;
  static const Color darkButtonSecondaryForeground = Colors.white;
  static const Color darkButtonOutline = primary;
  static const Color darkButtonOutlineForeground = primary;
  static const Color darkButtonGhost = primary;
  static const Color darkButtonGhostForeground = primary;
  static const Color darkButtonDisabled = Color(0xFF616161);
  static const Color darkButtonDisabledForeground = Colors.white;
  
  // Link Colors
  static const Color link = primary;
  static const Color linkVisited = Color(0xFF7B1FA2);
  static const Color darkLink = primary;
  static const Color darkLinkVisited = Color(0xFF9C27B0);
  
  // Code Colors
  static const Color codeBackground = Color(0xFFF5F5F5);
  static const Color codeForeground = Color(0xFF212121);
  static const Color darkCodeBackground = Color(0xFF2D2D2D);
  static const Color darkCodeForeground = Color(0xFFFFFFFF);
  
  // Selection Colors
  static const Color selectionBackground = Color(0x402196F3);
  static const Color selectionForeground = Color(0xFF212121);
  static const Color darkSelectionBackground = Color(0x402196F3);
  static const Color darkSelectionForeground = Color(0xFFFFFFFF);
  
  // Splash Colors
  static const Color splash = Color(0x1F2196F3);
  static const Color darkSplash = Color(0x1F2196F3);
  
  // Highlight Colors
  static const Color highlight = Color(0x402196F3);
  static const Color darkHighlight = Color(0x402196F3);
  
  // Ripple Colors
  static const Color ripple = Color(0x402196F3);
  static const Color darkRipple = Color(0x402196F3);
  
  // Focus Colors
  static const Color darkFocus = Color(0x402196F3);
  
  // Hover Colors
  static const Color hover = Color(0x08000000);
  static const Color darkHover = Color(0x08FFFFFF);
  
  // Pressed Colors
  static const Color pressed = Color(0x14000000);
  static const Color darkPressed = Color(0x14FFFFFF);
  
  // Drag Colors
  static const Color drag = Color(0x402196F3);
  static const Color darkDrag = Color(0x402196F3);
  
  // Resize Colors
  static const Color resize = Color(0x402196F3);
  static const Color darkResize = Color(0x402196F3);
  
  // Scrollbar Colors
  static const Color scrollbar = Color(0xFFBDBDBD);
  static const Color scrollbarThumb = Color(0xFF757575);
  static const Color darkScrollbar = Color(0xFF424242);
  static const Color darkScrollbarThumb = Color(0xFF757575);
  
  // Scrim Colors
  static const Color scrim = Color(0x80000000);
  static const Color darkScrim = Color(0x80000000);
  
  // Elevation Colors
  static const Color elevation1 = Color(0x0F000000);
  static const Color elevation2 = Color(0x1F000000);
  static const Color elevation3 = Color(0x2F000000);
  static const Color elevation4 = Color(0x3F000000);
  static const Color elevation5 = Color(0x4F000000);
  static const Color elevation6 = Color(0x5F000000);
  static const Color elevation7 = Color(0x6F000000);
  static const Color elevation8 = Color(0x7F000000);
  
  // Dark Elevation Colors
  static const Color darkElevation1 = Color(0x1FFFFFFF);
  static const Color darkElevation2 = Color(0x2FFFFFFF);
  static const Color darkElevation3 = Color(0x3FFFFFFF);
  static const Color darkElevation4 = Color(0x4FFFFFFF);
  static const Color darkElevation5 = Color(0x5FFFFFFF);
  static const Color darkElevation6 = Color(0x6FFFFFFF);
  static const Color darkElevation7 = Color(0x7FFFFFFF);
  static const Color darkElevation8 = Color(0x8FFFFFFF);
}
