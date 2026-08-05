import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal_plan_entities.dart';

abstract class MealPlanRepository {
  Future<Either<Failure, WeeklyPlanEntity?>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  });

  Future<Either<Failure, void>> updateMealConsumed({
    required String mealId,
    required bool consumed,
    String? substituteNote,
    String? voiceNotePath,
  });

  Future<Either<Failure, void>> saveSubstituteNote({
    required String mealId,
    String? note,
    String? voiceNotePath,
  });

  Future<Either<Failure, RecipeEntity?>> getRecipeByMeal({
    required String mealId,
  });
}