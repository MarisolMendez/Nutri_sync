/// Las excepciones viven SOLO en la capa data.
/// Los repositorios las atrapan y las convierten en [Failure].
/// El domain y presentation NUNCA ven excepciones — solo ven Failure.
library;

// ── Excepciones de red ────────────────────────────────────────────────────────

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sin conexión a internet']);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Error del servidor', this.statusCode});
}

class TimeoutException implements Exception {
  const TimeoutException();
}

// ── Excepciones de base de datos ──────────────────────────────────────────────

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Error en base de datos local']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Registro no encontrado']);
}

// ── Excepciones de autenticación ──────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Error de autenticación']);
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}

// ── Excepción de caché ────────────────────────────────────────────────────────

/// Cuando se intenta leer caché y no existe dato guardado
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'No hay datos en caché']);
}