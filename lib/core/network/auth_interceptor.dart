import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interceptor de Dio que inyecta el token JWT en cada request.
///
/// ⚠️ **PENDIENTE**: Tu equipo debe:
/// 1. Ajustar la clave 'auth_token' si tu backend usa otro nombre
/// 2. Implementar refresh token automático si aplica
/// 3. Manejar 401 Unauthorized (redirigir a login)
///
/// ## Flujo de sesión esperado:
/// 1. Login/Register → backend devuelve `{ "token": "eyJ...", "user": {...} }`
/// 2. El datasource guarda el token con: `await _saveToken(jwt)`
/// 3. Este interceptor lo agrega automáticamente a cada request
/// 4. Logout → llama a `await _clearToken()`
class AuthInterceptor extends Interceptor {
  /// Clave en SharedPreferences donde se guarda el JWT
  static const String _tokenKey = 'auth_token';

  /// Lee el token guardado y lo agrega al header Authorization
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

  /// Manejo global de errores HTTP
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // ⚠️ TODO: Redirigir a pantalla de login
      // Ejemplo: sl<AuthController>().logout();
      // Limpiar token
      await _clearToken();
    }
    handler.next(err);
  }

  /// Guarda el JWT en SharedPreferences (llamar desde datasource)
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Elimina el JWT (llamar en logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _clearToken() => clearToken();
}