import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ApiClient apiClient;

  const ProgressRepositoryImpl({
    required this.apiClient,
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

      // ── Paralelo: summary + plan + moods + hydrations ─────────
      final today = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
      final results = await Future.wait([
        _fetchMySummary(),
        _fetchMyPlan(),
        _fetchMoods(),
        _fetchHydrations(today),
      ], eagerError: false);

      final summaryData = results[0] as Map<String, dynamic>?;
      final planData = results[1] as Map<String, dynamic>?;
      final moodsData = results[2] as List<dynamic>?;
      final hydrationsData = results[3] as List<dynamic>?;

      // ── Adherencia desde summary ──────────────────────────────
      double adherenceRate = 0;
      int mealsCompleted = 0;
      int mealsExpected = 0;
      if (summaryData != null) {
        adherenceRate = (summaryData['adherenceRate'] as num?)?.toDouble() ?? 0;
        mealsCompleted = (summaryData['mealsCompleted'] as num?)?.toInt() ?? 0;
        mealsExpected = (summaryData['expectedMeals'] as num?)?.toInt() ?? 0;
      }

      // ── Comidas por día desde plan ────────────────────────────
      final mealsConsumedByDay = List<int>.filled(7, 0);
      final mealsTotalByDay = List<int>.filled(7, 0);

      if (planData != null) {
        final days = planData['days'] as List<dynamic>? ?? [];
        for (final d in days) {
          if (d is! Map<String, dynamic>) continue;
          final dayNumber = (d['dayNumber'] as num?)?.toInt() ?? 0;
          if (dayNumber < 1 || dayNumber > 7) continue;
          final meals = d['meals'] as List<dynamic>? ?? [];
          for (final m in meals) {
            if (m is! Map<String, dynamic>) continue;
            final isConsumed = m['isConsumed'] == true;
            final dayIndex = dayNumber - 1;
            mealsTotalByDay[dayIndex]++;
            if (isConsumed) mealsConsumedByDay[dayIndex]++;
          }
        }
        // Si no hay datos de summary, usar conteo del plan como fallback
        if (mealsExpected == 0) {
          mealsExpected = 21; // 7 días × 3 comidas
          mealsCompleted = mealsConsumedByDay.fold(0, (a, b) => a + b);
        }
      }

      // ── Hidratación de hoy (desde endpoint de hydration filtrado por fecha) ─
      int hydrationMl = 0;
      if (hydrationsData != null) {
        for (final h in hydrationsData) {
          if (h is Map<String, dynamic>) {
            hydrationMl += (h['amountMl'] as num?)?.toInt() ?? 0;
          }
        }
      }
      final avgHydration = (hydrationMl / 2000.0).clamp(0.0, 1.0);

      // ── Moods (solo de la semana actual, comparando por fecha) ─
      final moodByDay = List<String?>.filled(7, null);
      if (moodsData != null) {
        for (final m in moodsData) {
          if (m is! Map<String, dynamic>) continue;
          final loggedAtRaw = m['loggedAt'] ?? m['date'];
          if (loggedAtRaw == null) continue;
          final loggedAt = DateTime.tryParse(loggedAtRaw.toString());
          if (loggedAt == null) continue;
          // Comparar solo por fecha (ignorar hora/timezone)
          final logDate = DateTime(loggedAt.year, loggedAt.month, loggedAt.day);
          if (logDate.isBefore(weekStart) || logDate.isAfter(weekEnd)) continue;
          final dayIndex = logDate.weekday - 1;
          if (dayIndex >= 0 && dayIndex < 7) {
            moodByDay[dayIndex] = m['mood']?.toString();
          }
        }
      }

      // La adherencia total usa expectedMeals como denominador
      final totalConsumed = mealsCompleted;
      final totalExpected = mealsExpected > 0 ? mealsExpected : 21;

      return Right(
        WeeklyProgressEntity(
          weekStart: weekStart,
          weekEnd: weekEnd,
          mealsConsumed: totalConsumed,
          mealsTotal: totalExpected,
          avgHydrationPercent: avgHydration,
          mealsConsumedByDay: mealsConsumedByDay,
          mealsTotalByDay: mealsTotalByDay,
          moodByDay: moodByDay,
          adherenceChangePercent: null,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Error al obtener progreso: $e'));
    }
  }

  Future<Map<String, dynamic>?> _fetchMySummary() async {
    try {
      final response = await apiClient.get(ApiEndpoints.mySummary);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['data'] ?? data) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchMyPlan() async {
    try {
      final response = await apiClient.get(ApiEndpoints.myPlan);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['data'] ?? data) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>?> _fetchHydrations(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await apiClient.get('${ApiEndpoints.hydration}?date=$dateStr');
      final data = response.data;
      final list = (data is Map ? (data['data'] ?? data) : data);
      if (list is List) return list;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>?> _fetchMoods() async {
    try {
      final response = await apiClient.get(ApiEndpoints.mood);
      final data = response.data;
      final list = (data is Map ? (data['data'] ?? data) : data);
      if (list is List) return list;
      return null;
    } catch (_) {
      return null;
    }
  }
}