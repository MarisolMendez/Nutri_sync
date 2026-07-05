import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../hydration/domain/entities/hydration_entity.dart';
import '../../../hydration/domain/usecases/get_daily_hydration_usecase.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../meal_plan/domain/usecases/get_weekly_plan_usecase.dart';
import '../../../meal_plan/domain/usecases/update_meal_usecase.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../../medication/domain/usecases/delete_medication_usecase.dart';
import '../../../medication/domain/usecases/get_medication_schedule_usecase.dart';
import '../../../medication/domain/repositories/medication_repository.dart';
import '../../../medication/domain/usecases/log_medication_taken_usecase.dart';
import '../../../mood/domain/entities/mood_entity.dart';
import '../../../mood/domain/repositories/mood_repository.dart';
import '../../../mood/domain/usecases/log_mood_usecase.dart';
import 'dashboard_state.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  late final GetDailyHydrationUseCase _getDailyHydration;
  late final GetWeeklyPlanUseCase _getWeeklyPlan;
  late final GetMedicationScheduleUseCase _getMedicationSchedule;
  late final LogMoodUseCase _logMood;
  late final UpdateMealUseCase _updateMeal;
  late final LogMedicationTakenUseCase _logMedicationTaken;
  late final DeleteMedicationUseCase _deleteMedication;
  late final MoodRepository _moodRepository;

  static const _tempUserId = 'user_1';

  @override
  DashboardState build() {
    _getDailyHydration = sl();
    _getWeeklyPlan = sl();
    _getMedicationSchedule = sl();
    _logMood = sl();
    _updateMeal = sl();
    _logMedicationTaken = sl();
    _deleteMedication = sl();
    _moodRepository = sl();
    return const DashboardInitial();
  }

  Future<void> load() async {
    state = const DashboardLoading();

    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);

      // Carga todo en paralelo
      final results = await Future.wait([
        _getDailyHydration(HydrationParams(userId: _tempUserId, date: now)),
        _getWeeklyPlan(WeeklyPlanParams(userId: _tempUserId, weekStart: weekStart)),
        _getMedicationSchedule(const MedicationParams(userId: _tempUserId)),
      ]);

      final hydrationResult = results[0];
      final planResult = results[1];
      final medicationResult = results[2];

      // Si alguno falla usamos valores vacíos en vez de mostrar error
      final hydration = hydrationResult.fold(
        (_) => const HydrationSummary(
          totalMl: 0, goalMl: 2000,
          totalGlasses: 0, goalGlasses: 8,
          streakDays: 0, logs: [],
        ),
        (h) => h as HydrationSummary,
      );

      final todayMeals = planResult.fold(
        (_) => <MealEntity>[],
        (plan) {
          if (plan == null) return <MealEntity>[];
          return (plan as WeeklyPlanEntity).mealsForDay(now.weekday);
        },
      );

      final medications = medicationResult.fold(
        (_) => <MedicationEntity>[],
        (meds) => meds as List<MedicationEntity>,
      );

      // Obtener IDs de medicamentos ya tomados hoy
      final takenIdsResult = await sl<MedicationRepository>().getTodayTakenIds();

      // Obtener el estado de ánimo de hoy
      final todayMoodResult = await _moodRepository.getTodayMood(
        userId: _tempUserId,
      );
      final todayMood = todayMoodResult.getOrElse(() => null);

      state = DashboardLoaded(
        hydration: hydration,
        todayMeals: todayMeals,
        medications: medications,
        takenMedicationIds: takenIdsResult.getOrElse(() => const {}),
        todayMood: todayMood,
        date: now,
      );
    } catch (e) {
      state = DashboardError('Error al cargar el dashboard: $e');
    }
  }

  Future<void> toggleMealConsumed(MealEntity meal) async {
    // 1. Guarda en Drift inmediatamente con el valor INVERTIDO
    final result = await _updateMeal(
      UpdateMealParams(
        mealId: meal.id,
        consumed: !meal.isConsumed, // ← CRÍTICO: invertir el estado actual
      ),
    );

    // 2. Solo recarga si el guardado fue exitoso
    result.fold(
      (failure) => state = DashboardError(failure.message),
      (_) => load(), // recarga el dashboard desde Drift para reflejar el cambio
    );
  }

  Future<void> toggleMedicationTaken(int medicationId) async {
    await _logMedicationTaken(
      LogMedicationTakenParams(medicationId: medicationId),
    );
    await load();
  }

  Future<void> saveMood(MoodValue mood) async {
    await _logMood(LogMoodParams(userId: _tempUserId, mood: mood));
    await load();
  }

  Future<void> deleteMedication(int id) async {
    await _deleteMedication(DeleteMedicationParams(id: id));
    await load();
  }
}
