import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  /// Se invoca cuando la sesión expira (401) y los tokens se limpian.
  /// Registra este callback en bootstrap.dart para redirigir al login.
  static void Function()? onSessionExpired;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Evitar bucle infinito: no refrescar si ya es la petición de refresh
      if (err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
        await _clearAllTokens();
        handler.next(err);
        return;
      }

      // Intentar refresh silencioso
      final success = await _tryRefreshToken();
      if (success) {
        // Reintentar la petición original con el nuevo token
        try {
          final retryResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (retryErr) {
          return handler.next(retryErr as DioException);
        }
      }

      // Si el refresh falló, limpiar tokens y notificar para redirigir al login
      await _clearAllTokens();
      onSessionExpired?.call();
    }
    handler.next(err);
  }

  /// Intenta renovar el accessToken usando el refreshToken guardado.
  /// Retorna true si tuvo éxito.
  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final client = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      final response = await client.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) return false;

      final newAccessToken = body['data']?['accessToken'] as String?;
      if (newAccessToken == null) return false;

      await saveToken(newAccessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reintenta la petición original con el nuevo token
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final prefs = await SharedPreferences.getInstance();
    final newToken = prefs.getString(_tokenKey);

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (newToken != null) 'Authorization': 'Bearer $newToken',
      },
    );

    final client = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    return client.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Guarda el JWT en SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Guarda el refresh token en SharedPreferences
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Elimina ambos tokens
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// Verifica si hay un token de acceso guardado
  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> _clearAllTokens() => clearToken();
}