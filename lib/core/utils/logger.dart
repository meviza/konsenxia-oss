import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'KONSENXIA';

  void d(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 500,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void i(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 800,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void w(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 900,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      time: DateTime.now(),
      level: 1000,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

// Global logger instance
final logger = AppLogger();
