/// Configuración central de la aplicación.
///
/// # Feature Flag: USE_FIREBASE
///
/// - `true`  → Usa Firebase (autenticación mock)
/// - `false` → Usa backend propio (API REST real)
///
/// Cuando se usa backend propio, el nutriólogo crea pacientes desde el panel web,
/// y el paciente solo inicia sesión (no se registra por su cuenta).
class AppConfig {
  AppConfig._();

  // ═══════════════════════════════════════════════════════════════
  //  FEATURE FLAG PRINCIPAL
  // ═══════════════════════════════════════════════════════════════

  /// `true` = Firebase, `false` = backend propio
  static const bool useFirebase = false;

  // ═══════════════════════════════════════════════════════════════
  //  BACKEND
  // ═══════════════════════════════════════════════════════════════

  /// URL base de la API.
  /// - `10.0.2.2` = localhost desde emulador Android
  /// - `localhost` = emulador iOS
  /// - IP real = dispositivo físico en misma red
  static const String apiBaseUrl = 'https://backend-nutrisync-5efv.onrender.com';

  // ═══════════════════════════════════════════════════════════════
  //  OFFLINE / SYNC
  // ═══════════════════════════════════════════════════════════════

  static const int maxSyncRetries = 3;
  static const int hydrationReminderIntervalHours = 2;

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  static bool get useBackend => !useFirebase;
}