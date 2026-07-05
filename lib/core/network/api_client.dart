import 'package:dio/dio.dart';
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
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para JWT
    _dio.interceptors.add(AuthInterceptor());
  }

  // ── Métodos HTTP públicos ──────────────────────────────────────

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