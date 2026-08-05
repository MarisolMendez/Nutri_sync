/// Rutas de la API REST del backend propio.
///
/// Convención:
/// - Prefijo `v1/` para versionado
/// - Sustantivos en plural
/// - Sin slash inicial (Dio lo añade desde baseUrl)
class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════
  //  AUTENTICACIÓN
  // ═══════════════════════════════════════════════════════════════

  /// POST — Iniciar sesión
  /// Body: `{ email, password }`
  /// Response: `{ success, data: { accessToken, refreshToken, user } }`
  static const String login = 'v1/auth/login';
  static const String register = 'v1/auth/register';

  /// POST — Refrescar access token
  /// Body: `{ refreshToken }`
  /// Response: `{ success, data: { accessToken } }`
  static const String refreshToken = 'v1/auth/refresh';

  /// POST — Cerrar sesión
  /// Body: `{ refreshToken }`
  static const String logout = 'v1/auth/logout';

  // ═══════════════════════════════════════════════════════════════
  //  PLAN DE COMIDAS
  // ═══════════════════════════════════════════════════════════════

  static const String weeklyPlan = 'v1/meal-plans/weekly';
  static const String myPlan = 'v1/meal-plans/my-plan';
  static const String meals = 'v1/meals';

  // ═══════════════════════════════════════════════════════════════
  //  EXPEDIENTE CLÍNICO
  // ═══════════════════════════════════════════════════════════════

  static const String clinicalRecordMetrics = 'v1/clinical-records/metrics';

  // ═══════════════════════════════════════════════════════════════
  //  ADHERENCIA / HIDRATACIÓN / MOOD
  // ═══════════════════════════════════════════════════════════════

  static const String hydration = 'v1/adherence/hydration';
  static const String dailyHydration = 'v1/adherence/hydration/daily';
  static const String mood = 'v1/adherence/mood';
  static const String mealLogs = 'v1/adherence/meals';
  static const String mySummary = 'v1/adherence/my-summary';

  // ═══════════════════════════════════════════════════════════════
  //  MEDICAMENTOS
  // ═══════════════════════════════════════════════════════════════

  static const String medications = 'v1/medications';
  static const String medicationTakes = 'v1/medications'; // + /:id/takes

  // ═══════════════════════════════════════════════════════════════
  //  PROGRESO
  // ═══════════════════════════════════════════════════════════════

  static const String progress = 'v1/progress';
  static const String myProgressHistory = 'v1/progress/my-history';

  // ═══════════════════════════════════════════════════════════════
  //  NOTAS DE VOZ
  // ═══════════════════════════════════════════════════════════════

  static const String voiceNotes = 'v1/voice-notes';
  static const String voiceNoteUpload = 'v1/voice-notes/upload';
}