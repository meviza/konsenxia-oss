import 'package:dio/dio.dart';

import '../models/ai_response_model.dart';
import '../models/chat_message_model.dart';

abstract class AIRemoteDataSource {
  Future<AIResponseModel> sendMessage({
    required String message,
    required String userRole,
    required String userId,
    Map<String, dynamic>? context,
  });

  Future<List<ChatMessageModel>> getChatHistory(String userId);

  Future<Map<String, dynamic>> analyzeHealthData({
    required Map<String, dynamic> patientData,
    required String analysisType,
  });

  Future<List<String>> getHealthSuggestions({
    required String userRole,
    required Map<String, dynamic> context,
  });

  Future<void> clearChatHistory(String userId);
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final Dio _dio;

  AIRemoteDataSourceImpl(this._dio);

  @override
  Future<AIResponseModel> sendMessage({
    required String message,
    required String userRole,
    required String userId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/chat/send',
        data: {
          'message': message,
          'userRole': userRole,
          'userId': userId,
          if (context != null) 'context': context,
        },
      );
      final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
      return AIResponseModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(String userId) async {
    try {
      final response = await _dio.get('/ai/chat/history/$userId');
      final list = response.data is List ? response.data as List : [];
      return list
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> analyzeHealthData({
    required Map<String, dynamic> patientData,
    required String analysisType,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/analyze',
        data: {'patientData': patientData, 'analysisType': analysisType},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to analyze health data: $e');
    }
  }

  @override
  Future<List<String>> getHealthSuggestions({
    required String userRole,
    required Map<String, dynamic> context,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/suggestions',
        data: {'userRole': userRole, 'context': context},
      );
      final list = response.data is List ? response.data as List : [];
      return list.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to get suggestions: $e');
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      await _dio.delete('/ai/chat/clear/$userId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to clear chat history: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Server timeout. Please try again later.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Unknown error';
        return Exception('HTTP $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.unknown:
      default:
        return Exception('Unexpected error: ${e.message}');
    }
  }
}
