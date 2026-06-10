import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Contrato que define qué puede hacer el repositorio de auth.
/// La implementación vive en data/ — domain solo define la firma.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Cierra sesión
  Future<Either<Failure, void>> logout();

  /// Retorna el usuario actual si hay sesión activa, null si no
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}