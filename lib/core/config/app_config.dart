class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // App Info
  static const String appName = 'KONSENXIA';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double spacing = 8.0;
  
  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
}
