
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../database/daos/hydration_dao.dart';
import '../database/daos/meal_dao.dart';
import '../database/daos/medication_dao.dart';
import '../database/daos/mood_dao.dart';
import '../network/network_info.dart';

// ── Features ──────────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

// Comentados: features no completadas
import '../../features/hydration/data/datasources/hydration_local_datasource.dart';
import '../../features/hydration/data/repositories/hydration_repository_impl.dart';
import '../../features/hydration/domain/repositories/hydration_repository.dart';
import '../../features/hydration/domain/usecases/log_water_usecase.dart';
import '../../features/hydration/domain/usecases/get_daily_hydration_usecase.dart';

import '../../features/mood/data/datasources/mood_local_datasource.dart';
import '../../features/mood/data/repositories/mood_repository_impl.dart';
import '../../features/mood/domain/repositories/mood_repository.dart';
import '../../features/mood/domain/usecases/log_mood_usecase.dart';
import '../../features/mood/domain/usecases/get_mood_history_usecase.dart';

import '../../features/meal_plan/data/datasources/meal_plan_local_datasource.dart';
import '../../features/meal_plan/data/datasources/meal_plan_remote_datasource.dart';
import '../../features/meal_plan/data/repositories/meal_plan_repository_impl.dart';
import '../../features/meal_plan/domain/repositories/meal_plan_repository.dart';
import '../../features/meal_plan/domain/usecases/get_weekly_plan_usecase.dart';
import '../../features/meal_plan/domain/usecases/update_meal_usecase.dart';
import '../../features/meal_plan/domain/usecases/sync_meal_plans_usecase.dart';

import '../../features/medication/data/datasources/medication_local_datasource.dart';
import '../../features/medication/data/repositories/medication_repository_impl.dart';
import '../../features/medication/domain/repositories/medication_repository.dart';
import '../../features/medication/domain/usecases/log_medication_usecase.dart';
import '../../features/medication/domain/usecases/get_medication_schedule_usecase.dart';
/// Instancia global de GetIt — se accede con sl ´Tipo´() desde cualquier parte.
/// "sl" = service locator
final sl = GetIt.instance;

/// Registra todas las dependencias de la app.
/// Se llama UNA SOLA VEZ en bootstrap.dart antes de runApp().
Future<void> initDependencies() async {
  await _initCore();
  await _initAuth();
  await _initHydration();
  await _initMood();
  await _initMealPlan();
  await _initMedication();
}

// ── CORE ──────────────────────────────────────────────────────────────────────
Future<void> _initCore() async {
  // Firebase — singletons del SDK
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());

  // NetworkInfo
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Base de datos Drift
  sl.registerLazySingleton(() => AppDatabase());

  // DAOs — dependen de AppDatabase
  // sl.registerLazySingleton(() => UserDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => MealDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => HydrationDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => MoodDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => MedicationDao(sl<AppDatabase>()));
  // sl.registerLazySingleton(() => SyncQueueDao(sl<AppDatabase>()));

  // ApiClient — Dio configurado con interceptores
  // sl.registerLazySingleton(
  //   () => ApiClient(baseUrl: 'https://api.nutrisync.com/v1'),
  // );

  // SyncManager — se inicia en bootstrap.dart
  // sl.registerLazySingleton(
  //   () => SyncManager(
  //     syncQueueDao: sl(),
  //     firestore: sl(),
  //     connectivity: sl(),
  //   ),
  // );
}

// ── AUTH ──────────────────────────────────────────────────────────────────────
Future<void> _initAuth() async {
  // Datasources
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDatasource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
}

// ── HYDRATION ─────────────────────────────────────────────────────────────────
Future<void> _initHydration() async {
  sl.registerLazySingleton<HydrationLocalDatasource>(
    () => HydrationLocalDatasourceImpl(hydrationDao: sl()),
  );
  sl.registerLazySingleton<HydrationRepository>(
    () => HydrationRepositoryImpl(
      localDatasource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LogWaterUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyHydrationUseCase(sl()));
}

// ── MEAL PLAN ─────────────────────────────────────────────────────────────────
Future<void> _initMealPlan() async {
  sl.registerLazySingleton<MealPlanLocalDatasource>(
    () => MealPlanLocalDatasourceImpl(mealDao: sl()),
  );
  sl.registerLazySingleton<MealPlanRemoteDatasource>(
    () => const MealPlanRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<MealPlanRepository>(
    () => MealPlanRepositoryImpl(
      localDatasource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetWeeklyPlanUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMealUseCase(sl()));
  sl.registerLazySingleton(() => SyncMealPlansUseCase(sl()));
}

// ── MOOD ──────────────────────────────────────────────────────────────────────
Future<void> _initMood() async {
  sl.registerLazySingleton<MoodLocalDatasource>(
    () => MoodLocalDatasourceImpl(moodDao: sl()),
  );
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(localDatasource: sl()),
  );
  sl.registerLazySingleton(() => LogMoodUseCase(sl()));
  sl.registerLazySingleton(() => GetMoodHistoryUseCase(sl()));
}

// ── MEDICATION ────────────────────────────────────────────────────────────────
Future<void> _initMedication() async {
  sl.registerLazySingleton<MedicationLocalDatasource>(
    () => MedicationLocalDatasourceImpl(medicationDao: sl()),
  );
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(
      localDatasource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LogMedicationUseCase(sl()));
  sl.registerLazySingleton(() => GetMedicationScheduleUseCase(sl()));
}
