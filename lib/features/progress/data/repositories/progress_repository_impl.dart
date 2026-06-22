import 'package:dartz/dartz.dart';
import '../../../../core/database/daos/hydration_dao.dart';
import '../../../../core/database/daos/meal_dao.dart';
import '../../../../core/database/daos/medication_dao.dart';
import '../../../../core/database/daos/mood_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';

/// Este repositorio es distinto a los demás — no tiene su propio datasource.
/// En vez de eso, lee directamente de los DAOs de otros features
/// (meal, hydration, mood, medication) porque su única responsabilidad
/// es cruzar y agregar datos que ya existen, no poseer datos propios.
class ProgressRepositoryImpl implements ProgressRepository {
  final MealDao mealDao;
  final HydrationDao hydrationDao;
  final MoodDao moodDao;
  final MedicationDao medicationDao;

  const ProgressRepositoryImpl({
    required this.mealDao,
    required this.hydrationDao,
    required this.moodDao,
    required this.medicationDao,
  });

  @override
  Future<Either<Failure, WeeklyProgressEntity>> getWeeklyProgress({
    required String userId,
    required DateTime referenceDate,
  }) async {
    try {
      final monday = referenceDate
          .subtract(Duration(days: referenceDate.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      final weekEnd = weekStart.add(const Duration(days: 6));

      // ── Comidas de la semana ────────────────────────────────────
      final plan = await mealDao.getWeeklyPlan(userId, weekStart);

      final mealsConsumedByDay = List<int>.filled(7, 0);
      final mealsTotalByDay = List<int>.filled(7, 0);
      int totalConsumed = 0;
      int totalMeals = 0;

      if (plan != null) {
        final meals = await mealDao.getMealsByPlan(plan.id);
        for (final meal in meals) {
          final dayIndex = meal.dayOfWeek - 1; // 1-7 -> 0-6
          if (dayIndex >= 0 && dayIndex < 7) {
            mealsTotalByDay[dayIndex]++;
            totalMeals++;
            if (meal.isConsumed) {
              mealsConsumedByDay[dayIndex]++;
              totalConsumed++;
            }
          }
        }
      }

      // ── Hidratación promedio de la semana ───────────────────────
      double hydrationSum = 0;
      int daysWithData = 0;
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        if (day.isAfter(DateTime.now())) break;
        final totalMl = await hydrationDao.getDayTotalMl(userId, day);
        if (totalMl > 0) {
          hydrationSum += (totalMl / 2000).clamp(0.0, 1.0);
          daysWithData++;
        }
      }
      final avgHydration =
          daysWithData == 0 ? 0.0 : hydrationSum / daysWithData;

      // ── Estado de ánimo por día ──────────────────────────────────
      final weekMoods = await moodDao.getWeekMoods(userId);
      final moodByDay = List<String?>.filled(7, null);
      for (final mood in weekMoods) {
        final dayIndex = mood.loggedAt.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          moodByDay[dayIndex] = mood.moodValue;
        }
      }

      // ── Medicación de la semana ───────────────────────────────────
      final medications = await medicationDao.getMedications(userId);
      String? mainMedName;
      int daysTaken = 0;
      int daysScheduled = 0;

      if (medications.isNotEmpty) {
        final mainMed = medications.first;
        mainMedName = mainMed.name;
        for (int i = 0; i < 7; i++) {
          final day = weekStart.add(Duration(days: i));
          if (day.isAfter(DateTime.now())) break;
          daysScheduled++;
          final logs = await medicationDao.getTodayLogs(mainMed.id);
          if (logs.isNotEmpty) daysTaken++;
        }
      }

      return Right(
        WeeklyProgressEntity(
          weekStart: weekStart,
          weekEnd: weekEnd,
          mealsConsumed: totalConsumed,
          mealsTotal: totalMeals,
          avgHydrationPercent: avgHydration,
          mealsConsumedByDay: mealsConsumedByDay,
          mealsTotalByDay: mealsTotalByDay,
          moodByDay: moodByDay,
          mainMedicationName: mainMedName,
          medicationDaysTaken: daysTaken,
          medicationDaysScheduled: daysScheduled,
          // TODO: calcular cambio vs semana anterior cuando haya histórico suficiente
          adherenceChangePercent: null,
        ),
      );
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}