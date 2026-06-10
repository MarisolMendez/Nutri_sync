import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de la app.
/// Usamos [Either<Failure, T>] en los use cases para
/// no lanzar excepciones — retornamos el error como valor.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// ── Fallos de red ─────────────────────────────────────────────────────────────

/// Sin conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Sin conexión a internet');
}

/// El servidor respondió pero con error (4xx, 5xx)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Timeout — el servidor tardó demasiado
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('La solicitud tardó demasiado');
}

// ── Fallos de base de datos local ─────────────────────────────────────────────

/// Error al leer o escribir en Drift
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Error en base de datos local']);
}

/// Se buscó un registro y no existe
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Registro no encontrado']);
}

// ── Fallos de autenticación ───────────────────────────────────────────────────

/// Token expirado o sesión inválida
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesión expirada, inicia sesión nuevamente']);
}

/// Credenciales incorrectas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Correo o contraseña incorrectos');
}

/// El correo ya está registrado
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('Este correo ya está registrado');
}

// ── Fallos de validación ──────────────────────────────────────────────────────

/// Los datos enviados no pasan validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

// ── Fallo genérico ────────────────────────────────────────────────────────────

/// Cualquier error no contemplado
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado']);
}