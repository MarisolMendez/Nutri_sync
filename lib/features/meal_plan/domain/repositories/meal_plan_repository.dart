import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meal_plan_entities.dart';

abstract class MealPlanRepository {
  /// Trae el plan de la semana actual del usuario
  Future<Either<Failure, WeeklyPlanEntity?>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  });

  /// Marca una comida como consumida o no consumida
  Future<Either<Failure, void>> updateMealConsumed({
    required int mealId,
    required bool consumed,
    String? substituteNote,
    String? voiceNotePath,
  });

  /// Guarda la nota sustituta (texto + voz) de una comida
  Future<Either<Failure, void>> saveSubstituteNote({
    required int mealId,
    String? note,
    String? voiceNotePath,
  });

  /// Trae el detalle de una receta por meal
  Future<Either<Failure, RecipeEntity?>> getRecipeByMeal({
    required int mealId,
  });
}