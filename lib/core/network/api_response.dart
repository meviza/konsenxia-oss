import '../constants/app_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;
  final int? statusCode;
  final String? timestamp;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
    this.timestamp,
    this.metadata,
  });

  factory ApiResponse.success(
    T data, [
    String message = 'Success',
  ]) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: AppConstants.successCode,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.error(
    String message,
    List<String>? errors,
    int? statusCode,
  ) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.networkError(String message) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: 0,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == AppConstants.unauthorizedCode;
  bool get isForbidden => statusCode == AppConstants.forbiddenCode;
  bool get isNotFound => statusCode == AppConstants.notFoundCode;
  bool get isServerError => statusCode != null && 
      statusCode! >= AppConstants.serverErrorCode;
}
