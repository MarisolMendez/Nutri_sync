import '../../../../core/database/daos/meal_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../models/meal_plan_models.dart';

abstract class MealPlanLocalDatasource {
  Future<WeeklyPlanModel?> getWeeklyPlan(String userId, DateTime weekStart);
  Future<void> markMealConsumed(int mealId, bool consumed);
  Future<RecipeModel?> getRecipeByMealId(int mealId);
}

class MealPlanLocalDatasourceImpl implements MealPlanLocalDatasource {
  final MealDao mealDao;
  const MealPlanLocalDatasourceImpl({required this.mealDao});

  @override
  Future<WeeklyPlanModel?> getWeeklyPlan(
      String userId, DateTime weekStart) async {
    try {
      final plan = await mealDao.getWeeklyPlan(userId, weekStart);
      if (plan == null) return null;

      final mealsData = await mealDao.getMealsByPlan(plan.id);
      final meals = await Future.wait(mealsData.map((m) async {
        final recipe = await mealDao.getRecipeByMealId(m.id);
        return MealModel.fromLocal(
          m,
          recipe: recipe != null ? RecipeModel.fromLocal(recipe) : null,
        );
      }));

      return WeeklyPlanModel.fromLocal(plan, meals);
    } catch (e) {
      throw DatabaseException('Error al leer plan semanal: $e');
    }
  }

  @override
  Future<void> markMealConsumed(int mealId, bool consumed) async {
    try {
      await mealDao.markMealConsumed(mealId, consumed);
    } catch (e) {
      throw DatabaseException('Error al actualizar comida: $e');
    }
  }

  @override
  Future<RecipeModel?> getRecipeByMealId(int mealId) async {
    try {
      final data = await mealDao.getRecipeByMealId(mealId);
      if (data == null) return null;
      return RecipeModel.fromLocal(data);
    } catch (e) {
      throw DatabaseException('Error al leer receta: $e');
    }
  }
}