import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../models/user_model.dart';

/// Datasource remoto para autenticación contra el backend propio.
///
/// ⚠️ **PENDIENTE**: Tu equipo debe:
/// 1. Ajustar el mapeo de la respuesta JSON al [UserModel]
/// 2. Confirmar que los endpoints en [ApiEndpoints] coincidan con tu API
/// 3. Manejar errores HTTP específicos (400, 401, 422, 500)
///
/// ## Flujo esperado de la API:
/// - `POST /auth/login`  → `{ "token": "jwt...", "user": { "id": "...", "email": "...", "name": "..." } }`
/// - `POST /auth/register` → `{ "token": "jwt...", "user": { ... } }`
/// - `POST /auth/logout` → `{ "message": "Sesión cerrada" }`
/// - `GET /auth/profile` → `{ "user": { ... } }`
class AuthRemoteDatasource {
  final ApiClient _client;

  const AuthRemoteDatasource({required ApiClient client}) : _client = client;

  /// Inicia sesión en el backend.
  /// Guarda el JWT automáticamente vía [AuthInterceptor].
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      // Guardar JWT para futuros requests
      await AuthInterceptor.saveToken(token);

      // ⚠️ TODO: Ajustar factory si el JSON de tu API es diferente
      final user = UserModel.fromJson({
        ...userJson,
        'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
      });

      return Right(user);
    } on Exception catch (e) {
      return Left(UnexpectedFailure(_mapError(e)));
    }
  }

  /// Registra un nuevo usuario en el backend.
  /// Guarda el JWT automáticamente vía [AuthInterceptor].
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: {'email': email, 'password': password, 'name': name},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      // Guardar JWT para futuros requests
      await AuthInterceptor.saveToken(token);

      // ⚠️ TODO: Ajustar factory si el JSON de tu API es diferente
      final user = UserModel.fromJson({
        ...userJson,
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
      // Ignorar error si el backend no responde — igual limpiamos token
    } finally {
      await AuthInterceptor.clearToken();
    }
    return const Right(null);
  }

  /// Obtiene el perfil del usuario actual desde el backend.
  Future<Either<Failure, UserModel?>> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.profile);
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>?;

      if (userJson == null) return const Right(null);

      return Right(UserModel.fromJson({
        ...userJson,
        'createdAt': userJson['createdAt'] ?? DateTime.now().toIso8601String(),
      }));
    } on Exception catch (e) {
      return Left(UnexpectedFailure(_mapError(e)));
    }
  }

  /// Traduce errores HTTP a mensajes legibles.
  String _mapError(Exception e) {
    // ⚠️ TODO: Mapear códigos HTTP específicos de tu backend
    // Ej: 401 → "Credenciales inválidas"
    // Ej: 422 → "El correo ya está registrado"
    return e.toString();
  }
}