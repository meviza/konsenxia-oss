import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.184:3000/api/v1';
  static const String healthEndpoint = '$baseUrl/health';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String aiChatEndpoint = '$baseUrl/ai/chat';
  static const String dashboardEndpoint = '$baseUrl/dashboard';
  static const String profileEndpoint = '$baseUrl/profile';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Cache Keys (must match auth_repository_impl & local_storage)
  static const String userTokenKey = 'auth_token';
  static const String userDataKey = 'auth_user';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Screen Names
  static const String splashScreen = 'splash';
  static const String loginScreen = 'login';
  static const String registerScreen = 'register';
  static const String dashboardScreen = 'dashboard';
  static const String aiChatScreen = 'ai_chat';
  static const String profileScreen = 'profile';
  
  // User Roles
  static const String patientRole = 'PATIENT';
  static const String doctorRole = 'DOCTOR';
  static const String adminRole = 'ADMIN';
  
  // API Status Codes
  static const int badRequestCode = 400;
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxMessageLength = 1000;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];
  
  // App Info
  static const String appName = 'KONSENXIA';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Deep Links
  static const String appScheme = 'konsexia';
  static const String webUrl = 'https://konsexia.com';
  
  // Analytics
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // Feature Flags
  static const bool enableAIChat = true;
  static const bool enableNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  
  // Rate Limiting
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Session Management
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshInterval = Duration(hours: 1);
  
  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 30.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  
  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  
  // Text Styles
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 32.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // Input Field Heights
  static const double inputFieldHeight = 48.0;
  static const double inputFieldHeightSmall = 36.0;
  static const double inputFieldHeightLarge = 56.0;
  
  // Card Sizes
  static const double cardHeightSmall = 80.0;
  static const double cardHeightMedium = 120.0;
  static const double cardHeightLarge = 200.0;
  
  // Avatar Sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 96.0;
  
  // Image Aspect Ratios
  static const double imageAspectRatioSquare = 1.0;
  static const double imageAspectRatioWide = 16.0 / 9.0;
  static const double imageAspectRatioPortrait = 3.0 / 4.0;
  
  // Grid Constants
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.0;
  static const double gridSpacing = 16.0;
  
  // List Constants
  static const double listTileHeight = 56.0;
  static const double listTileHeightSmall = 48.0;
  static const double listTileHeightLarge = 72.0;
  
  // Tab Bar Constants
  static const double tabBarHeight = 48.0;
  static const double tabBarIconSize = 24.0;
  
  // Bottom Navigation Constants
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;
  
  // AppBar Constants
  static const double appBarHeight = 56.0;
  static const double appBarLargeHeight = 112.0;
  
  // Dialog Constants
  static const double dialogBorderRadius = 12.0;
  static const double dialogPadding = 24.0;
  
  // Sheet Constants
  static const double sheetBorderRadius = 20.0;
  static const double sheetMinHeight = 200.0;
  
  // Toast Constants
  static const double toastBorderRadius = 8.0;
  static const double toastPadding = 12.0;
  
  // Progress Indicator Constants
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLarge = 48.0;
  
  // Skeleton Loader Constants
  static const double skeletonBaseColor = 0xE0E0E0;
  static const double skeletonHighlightColor = 0xF5F5F5;
  
  // Shimmer Constants
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);
  
  // Glass Effect Constants
  static const double glassOpacity = 0.15;
  static const double glassBorderOpacity = 0.3;
  static const double glassBlur = 15.0;
  
  // Shadow Constants
  static const double shadowBlurSmall = 8.0;
  static const double shadowBlurMedium = 16.0;
  static const double shadowBlurLarge = 32.0;
  static const double shadowBlurXLarge = 64.0;
  
  static const double shadowOffsetSmall = 2.0;
  static const double shadowOffsetMedium = 4.0;
  static const double shadowOffsetLarge = 8.0;
  static const double shadowOffsetXLarge = 16.0;
  
  // Gradient Constants
  static const double gradientOpacity = 0.8;
  static const List<double> gradientStops = [0.0, 1.0];
  
  // Color Constants (Bio-Luminescent Clinical)
  static const Color primaryColor = Color(0xFF00E5FF); // Electric Cyan
  static const Color secondaryColor = Color(0xFF00FFAA); // Bio-Teal
  static const Color accentColor = Color(0xFFFF2D55); // Pulse Red
  static const Color successColor = Color(0xFF00FF88);
  static const Color warningColor = Color(0xFFFFD600);
  static const Color errorColor = Color(0xFFFF3D00);
  static const Color infoColor = Color(0xFF00B0FF);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  static const Color textHintColor = Color(0xFF9E9E9E);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Dark Theme Colors (Obsidian/Indigo)
  static const Color darkBackgroundColor = Color(0xFF0A0B1E); // Midnight Indigo
  static const Color darkSurfaceColor = Color(0xFF12142B);
  static const Color darkCardColor = Color(0xFF1A1D3D);
  static const Color darkDividerColor = Color(0xFF2E325A);
  
  // Dark Theme Text Colors
  static const Color darkTextPrimaryColor = Color(0xFFF0F2FF);
  static const Color darkTextSecondaryColor = Color(0xFFADB4D9);
  static const Color darkTextDisabledColor = Color(0xFF5C638C);
  static const Color darkTextHintColor = Color(0xFF7E86AF);
  
  // Status Colors
  static const Color onlineColor = Color(0xFF4CAF50);
  static const Color offlineColor = Color(0xFF9E9E9E);
  static const Color busyColor = Color(0xFFFF9800);
  static const Color awayColor = Color(0xFF2196F3);
  
  // Priority Colors
  static const Color lowPriorityColor = Color(0xFF4CAF50);
  static const Color mediumPriorityColor = Color(0xFFFF9800);
  static const Color highPriorityColor = Color(0xFFF44336);
  static const Color criticalPriorityColor = Color(0xFF9C27B0);
  
  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF4081), // Pink
    Color(0xFF795548), // Brown
  ];
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFFFF4081),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
  ];
  
  // Social Media Colors
  static const Color facebookColor = Color(0xFF1877F2);
  static const Color twitterColor = Color(0xFF1DA1F2);
  static const Color googleColor = Color(0xFF4285F4);
  static const Color linkedinColor = Color(0xFF0077B5);
  static const Color instagramColor = Color(0xFFE4405F);
  static const Color youtubeColor = Color(0xFFFF0000);
  
  // Payment Colors
  static const Color visaColor = Color(0xFF1434CB);
  static const Color mastercardColor = Color(0xFFEB001B);
  static const Color amexColor = Color(0xFF006FCF);
  static const Color paypalColor = Color(0xFF00457C);
  
  // Brand Colors
  static const Color appleColor = Color(0xFF000000);
  static const Color androidColor = Color(0xFF3DDC84);
  static const Color windowsColor = Color(0xFF0078D4);
  static const Color linuxColor = Color(0xFFFCC624);
  
  // Accessibility Colors
  static const Color highContrastColor = Color(0xFF000000);
  static const Color lowContrastColor = Color(0xFFCCCCCC);
  static const Color focusColor = Color(0xFF2196F3);
  static const Color selectedColor = Color(0xFF2196F3);
  static const Color disabledColor = Color(0xFFBDBDBD);
  
  // Error Handling Colors
  static const Color errorBackgroundColor = Color(0xFFFFEBEE);
  static const Color errorTextColor = Color(0xFFC62828);
  static const Color warningBackgroundColor = Color(0xFFFFF8E1);
  static const Color warningTextColor = Color(0xFFF57C00);
  static const Color successBackgroundColor = Color(0xFFE8F5E8);
  static const Color successTextColor = Color(0xFF2E7D32);
  static const Color infoBackgroundColor = Color(0xFFE3F2FD);
  static const Color infoTextColor = Color(0xFF1565C0);
  
  // Loading Colors
  static const Color loadingPrimaryColor = Color(0xFF2196F3);
  static const Color loadingSecondaryColor = Color(0xFF00BCD4);
  static const Color loadingBackgroundColor = Color(0xFFF5F5F5);
  
  // Empty State Colors
  static const Color emptyStateIconColor = Color(0xFF9E9E9E);
  static const Color emptyStateTextColor = Color(0xFF757575);
  static const Color emptyStateBackgroundColor = Color(0xFFF5F5F5);
  
  // Network Error Colors
  static const Color networkErrorColor = Color(0xFFF44336);
  static const Color networkErrorBackgroundColor = Color(0xFFFFEBEE);
  static const Color networkErrorTextColor = Color(0xFFC62828);
  
  // Validation Error Colors
  static const Color validationErrorColor = Color(0xFFF44336);
  static const Color validationErrorBackgroundColor = Color(0xFFFFEBEE);
  static const Color validationErrorTextColor = Color(0xFFC62828);
  
  // Success Icon Color
  static const Color successIconColor = Color(0xFF4CAF50);
  
  // Warning Icon Color
  static const Color warningIconColor = Color(0xFFFF9800);
  
  // Info Icon Color
  static const Color infoIconColor = Color(0xFF2196F3);
}
