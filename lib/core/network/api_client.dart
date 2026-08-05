import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';

/// Cliente HTTP centralizado para llamar al backend propio.
///
/// ⚠️ **PENDIENTE**: Tu equipo debe:
/// 1. Ajustar [baseUrl] en [AppConfig.apiBaseUrl]
/// 2. Verificar que los endpoints en [ApiEndpoints] coincidan con tu API
/// 3. Probar el flujo de refresh token si aplica
///
/// Uso:
/// ```dart
/// final client = sl<ApiClient>();
/// final response = await client.post('/auth/login', data: {...});
/// ```
class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    final normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    _dio = Dio(BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para JWT
    _dio.interceptors.add(AuthInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  // ── Métodos HTTP públicos ──────────────────────────────────────

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters);

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.delete<T>(path, queryParameters: queryParameters);
}