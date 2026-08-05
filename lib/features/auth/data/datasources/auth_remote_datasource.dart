import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../models/user_model.dart';

/// Datasource remoto para autenticación contra el backend NutriSync.
///
/// Endpoints usados:
/// - `POST /v1/auth/login`  → `{ success, data: { accessToken, refreshToken, user } }`
/// - `POST /v1/auth/refresh` → `{ success, data: { accessToken } }`
/// - `POST /v1/auth/logout`  → `{ success, data: { message } }`
///
/// El nutriólogo crea pacientes desde el panel web.
/// El paciente solo inicia sesión (no hay registro público).
class AuthRemoteDatasource {
  final ApiClient _client;

  const AuthRemoteDatasource({required ApiClient client}) : _client = client;

  /// Inicia sesión contra el backend.
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        final message = body['error']?['message'] ?? 'Credenciales inválidas';
        return Left(UnexpectedFailure(message.toString()));
      }

      final data = body['data'] as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      // Guardar tokens
      await AuthInterceptor.saveToken(accessToken);
      await AuthInterceptor.saveRefreshToken(refreshToken);

      final user = UserModel.fromJson({
        'id': userJson['id'] as String,
        'email': userJson['email'] as String,
        'name': userJson['name'] as String,
        'role': userJson['role'] as String? ?? 'patient',
        'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
      });

      return Right(user);
    } on Exception catch (e) {
      return Left(UnexpectedFailure(_mapError(e)));
    }
  }

  /// Cierra sesión en el backend y elimina el token local.
  Future<Either<Failure, void>> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignorar error — igual limpiamos token
    } finally {
      await AuthInterceptor.clearToken();
    }
    return const Right(null);
  }

  /// Registra un nuevo paciente.
  Future<Either<Failure, UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      log('REGISTER DATA: name="$name", email="$email", password=${password.length} chars');
      final response = await _client.post(
        ApiEndpoints.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        final message = body['error']?['message'] ?? 'Error al crear la cuenta';
        return Left(UnexpectedFailure(message.toString()));
      }

      // El registro no devuelve tokens — solo datos del usuario
      final userJson = body['data'] as Map<String, dynamic>;

      final user = UserModel.fromJson({
        'id': userJson['id'] as String,
        'email': userJson['email'] as String,
        'name': userJson['name'] as String,
        'role': userJson['role'] as String? ?? 'patient',
        'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
      });

      return Right(user);
    } on Exception catch (e) {
      return Left(UnexpectedFailure(_mapError(e)));
    }
  }

  /// Obtiene el perfil del usuario actual (placeholder).
  Future<Either<Failure, UserModel?>> getProfile() async {
    return const Right(null);
  }

  /// Traduce errores HTTP a mensajes legibles.
  String _mapError(Exception e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 409) {
        final serverMessage =
            (e.response?.data as Map<String, dynamic>?)?['error']?['message'];
        return (serverMessage is String && serverMessage.isNotEmpty)
            ? serverMessage
            : 'Este correo ya está registrado';
      }
      if (statusCode == 401) {
        final serverMessage =
            (e.response?.data as Map<String, dynamic>?)?['error']?['message'];
        return (serverMessage is String && serverMessage.isNotEmpty)
            ? serverMessage
            : 'Credenciales inválidas';
      }
      if (statusCode != null && statusCode >= 500) {
        return 'Error del servidor, inténtalo de nuevo';
      }

      // Errores de conectividad
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'Error de conexión, inténtalo de nuevo';
        default:
          break;
      }

      // Intentar leer el mensaje del servidor para cualquier otro código de error
      if (e.response?.data != null) {
        final body = e.response!.data;
        if (body is Map<String, dynamic>) {
          final serverMessage = body['error']?['message'] ?? body['message'];
          if (serverMessage is String && serverMessage.isNotEmpty) {
            return serverMessage;
          }
        }
      }

      // Sin respuesta = servidor no alcanzable
      if (e.response == null) {
        return 'Error de conexión, inténtalo de nuevo';
      }

      return 'Error de conexión, inténtalo de nuevo';
    }

    return 'Error de conexión, inténtalo de nuevo';
  }
}