/// Centraliza todas las rutas de la API propia.
///
/// ⚠️ **PENDIENTE**: Tu equipo debe ajustar estas rutas
/// para que coincidan con las de tu backend real.
///
/// ## Convención
/// - `v1/` → versión de la API
/// - Usa sustantivos en plural
/// - Sin slash al inicio (Dio lo maneja)
///
/// ## Ejemplo de uso
/// ```dart
/// final response = await client.post(ApiEndpoints.login, data: {...});
/// ```
class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════
  //  AUTENTICACIÓN
  // ═══════════════════════════════════════════════════════════════

  /// Iniciar sesión — POST
  /// Request:  `{ email, password }`
  /// Response: `{ token, user }`
  static const String login = 'v1/auth/login';

  /// Registrar usuario — POST
  /// Request:  `{ email, password, name }`
  /// Response: `{ token, user }`
  static const String register = 'v1/auth/register';

  /// Cerrar sesión — POST
  /// Header: Authorization: Bearer <token>
  /// Response: `{ message: string }`
  static const String logout = 'v1/auth/logout';

  /// Obtener perfil del usuario actual — GET
  /// Header: Authorization: Bearer <token>
  /// Response: `{ user: UserDto }`
  static const String profile = 'v1/auth/profile';

  // ═══════════════════════════════════════════════════════════════
  //  PLAN DE COMIDAS
  // ═══════════════════════════════════════════════════════════════

  /// Obtener plan semanal — GET
  /// Query: `?weekStart=2025-07-07`
  /// Response: `{ meals: MealDto[] }`
  static const String weeklyPlan = 'v1/meal-plans/weekly';

  /// Actualizar comida — PUT /:mealId
  /// Body: `{ isCompleted, substituteNote, ... }`
  static const String meals = 'v1/meals';

  // ═══════════════════════════════════════════════════════════════
  //  HIDRATACIÓN
  // ═══════════════════════════════════════════════════════════════

  /// Registrar agua — POST
  /// Body: `{ amountMl: number, date: string }`
  static const String hydration = 'v1/hydration';

  /// Resumen diario — GET
  /// Query: `?date=2025-07-07`
  static const String dailyHydration = 'v1/hydration/daily';

  // ═══════════════════════════════════════════════════════════════
  //  MEDICAMENTOS
  // ═══════════════════════════════════════════════════════════════

  static const String medications = 'v1/medications';

  // ═══════════════════════════════════════════════════════════════
  //  ESTADO DE ÁNIMO
  // ═══════════════════════════════════════════════════════════════

  static const String moods = 'v1/moods';
}