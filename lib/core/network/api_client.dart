import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    return await _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) async {
    return await _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return await _dio.delete<T>(path);
  }

  // ── Medical AI Endpoints ─────────────────────────────────────────

  Future<Map<String, dynamic>> reportAssistant({
    required String caseContext,
    required String draftText,
    String mode = 'suggest',
  }) async {
    final res = await post<Map<String, dynamic>>(
      '/api/v1/medical-ai/report-assistant',
      data: {
        'caseContext': caseContext,
        'draftText': draftText,
        'mode': mode,
      },
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> caseAnalysis({
    required String caseTitle,
    required String caseDescription,
    Map<String, String>? vitals,
    String? specialty,
    String? question,
  }) async {
    final res = await post<Map<String, dynamic>>(
      '/api/v1/medical-ai/case-analysis',
      data: {
        'caseData': {
          'title': caseTitle,
          'description': caseDescription,
          if (vitals != null) 'vitals': vitals,
          if (specialty != null) 'specialty': specialty,
        },
        if (question != null) 'question': question,
      },
    );
    return res.data ?? {};
  }
}
