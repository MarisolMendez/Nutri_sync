import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/meals_table.dart';
import '../tables/weekly_plans_table.dart';
import '../tables/recipes_table.dart';

part 'meal_dao.g.dart';

@DriftAccessor(tables: [MealsTable, WeeklyPlansTable, RecipesTable])
class MealDao extends DatabaseAccessor<AppDatabase> with _$MealDaoMixin {
  MealDao(super.db);

  /// Trae el plan de la semana que contiene la fecha dada
  Future<WeeklyPlansTableData?> getWeeklyPlan(String userId, DateTime weekStart) =>
      (select(weeklyPlansTable)
            ..where((p) => p.userId.equals(userId) &
                p.weekStartDate.equals(weekStart)))
          .getSingleOrNull();

  /// Todas las comidas de un plan semanal
  Future<List<MealsTableData>> getMealsByPlan(int weeklyPlanId) =>
      (select(mealsTable)
            ..where((m) => m.weeklyPlanId.equals(weeklyPlanId))
            ..orderBy([(m) => OrderingTerm.asc(m.dayOfWeek)]))
          .get();

  /// Comidas de un día específico dentro del plan
  Future<List<MealsTableData>> getMealsByDay(int weeklyPlanId, int dayOfWeek) =>
      (select(mealsTable)
            ..where((m) =>
                m.weeklyPlanId.equals(weeklyPlanId) &
                m.dayOfWeek.equals(dayOfWeek)))
          .get();

  Future<void> upsertWeeklyPlan(WeeklyPlansTableCompanion plan) =>
      into(weeklyPlansTable).insertOnConflictUpdate(plan);

  Future<void> upsertMeal(MealsTableCompanion meal) =>
      into(mealsTable).insertOnConflictUpdate(meal);

  /// Marca una comida como consumida
  Future<void> markMealConsumed(int mealId, bool consumed) =>
      (update(mealsTable)..where((m) => m.id.equals(mealId)))
          .write(MealsTableCompanion(isConsumed: Value(consumed)));

  Future<void> saveSubstituteNote({
    required int mealId,
    String? note,
    String? voiceNotePath,
  }) =>
      (update(mealsTable)..where((m) => m.id.equals(mealId))).write(
        MealsTableCompanion(
          substituteNote: Value(note),
          voiceNotePath: Value(voiceNotePath),
          isSynced: const Value(false),
        ),
      );

  Future<RecipesTableData?> getRecipeByMealId(int mealId) =>
      (select(recipesTable)..where((r) => r.mealId.equals(mealId)))
          .getSingleOrNull();

  Future<void> upsertRecipe(RecipesTableCompanion recipe) =>
      into(recipesTable).insertOnConflictUpdate(recipe);

  /// Trae todas las comidas sin sincronizar — para el sync_manager
  Future<List<MealsTableData>> getUnsyncedMeals() =>
      (select(mealsTable)..where((m) => m.isSynced.equals(false))).get();

  Future<void> markMealSynced(int mealId) =>
      (update(mealsTable)..where((m) => m.id.equals(mealId)))
          .write(const MealsTableCompanion(isSynced: Value(true)));
}