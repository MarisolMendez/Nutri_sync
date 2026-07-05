/// Configuración central de la aplicación.
///
/// # Feature Flag: USE_FIREBASE
///
/// - `true`  → Usa Firebase (actual, temporal)
/// - `false` → Usa backend propio (cuando esté listo)
///
/// Para cambiar, solo modifica esta constante.
/// El resto de la app se adapta automáticamente.
///
/// ## Migración futura
/// Cuando el backend propio esté listo:
/// 1. Cambia [useFirebase] a `false`
/// 2. Implementa [apiBaseUrl] con la URL de tu backend
/// 3. Crea las implementaciones reales de los datasources remotos
///    (usando Dio/ApiClient en lugar de Firebase SDK)
class AppConfig {
  AppConfig._();

  // ═══════════════════════════════════════════════════════════════
  //  FEATURE FLAG PRINCIPAL
  // ═══════════════════════════════════════════════════════════════

  /// [true]  = Usa Firebase (FirebaseAuth, Firestore, FCM)
  /// [false] = Usa backend propio (ApiClient con Dio)
  ///
  /// ⚠️  Cambia esto cuando el backend esté listo.
  static const bool useFirebase = true;

  // ═══════════════════════════════════════════════════════════════
  //  BACKEND (solo cuando useFirebase = false)
  // ═══════════════════════════════════════════════════════════════

  /// URL base de la API propia (Dio > ApiClient).
  /// Se ignora mientras [useFirebase] sea `true`.
  static const String apiBaseUrl = 'https://api.nutrisync.com/v1';

  // ═══════════════════════════════════════════════════════════════
  //  FIREBASE (solo cuando useFirebase = true)
  // ═══════════════════════════════════════════════════════════════

  /// Project ID de Firebase — se usa para identificar la instancia.
  static const String firebaseProjectId = 'nutrisync-2def4';

  // ═══════════════════════════════════════════════════════════════
  //  OFFLINE / SYNC
  // ═══════════════════════════════════════════════════════════════

  /// Máximo de reintentos para operaciones en cola de sync.
  static const int maxSyncRetries = 3;

  /// Intervalo entre recordatorios de hidratación (horas).
  static const int hydrationReminderIntervalHours = 2;

  // ═══════════════════════════════════════════════════════════════
  //  MÉTODO DE AYUDA: SABER QUÉ MÓDULOS ESTÁN ACTIVOS
  // ═══════════════════════════════════════════════════════════════

  /// ¿Está habilitada la autenticación con Firebase?
  static bool get useFirebaseAuth => useFirebase;

  /// ¿Está habilitada la sincronización con Firestore?
  static bool get useFirestoreSync => useFirebase;

  /// ¿Está habilitado Firebase Cloud Messaging?
  static bool get useFirebaseMessaging => useFirebase;

  /// ¿Está habilitado el backend propio?
  static bool get useBackend => !useFirebase;
}