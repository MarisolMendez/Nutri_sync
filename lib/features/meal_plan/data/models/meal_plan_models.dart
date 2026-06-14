import 'dart:convert';
import '../../domain/entities/meal_plan_entities.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.mealId,
    required super.title,
    super.imageUrl,
    super.mealTime,
    required super.ingredients,
    required super.steps,
    super.calories,
    super.proteinG,
    super.carbsG,
    super.fatG,
    super.fiberG,
    super.sodiumMg,
    super.observations,
  });

  factory RecipeModel.fromLocal(dynamic data) {
    final ingredientsRaw =
        jsonDecode(data.ingredientsJson as String) as List;
    final stepsRaw = jsonDecode(data.stepsJson as String) as List;

    return RecipeModel(
      id: data.id as int,
      mealId: data.mealId as int,
      title: data.title as String,
      imageUrl: data.imageUrl as String?,
      mealTime: data.mealTime as String?,
      ingredients: ingredientsRaw
          .map((i) => IngredientEntity(name: i.toString()))
          .toList(),
      steps: stepsRaw.map((s) => s.toString()).toList(),
      calories: data.calories as int?,
      proteinG: data.proteinG as double?,
      carbsG: data.carbsG as double?,
      fatG: data.fatG as double?,
      fiberG: data.fiberG as double?,
      sodiumMg: data.sodiumMg as double?,
      observations: data.observations as String?,
    );
  }
}

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.weeklyPlanId,
    required super.dayOfWeek,
    required super.mealType,
    required super.name,
    super.imageUrl,
    super.calories,
    super.proteinG,
    super.carbsG,
    super.fatG,
    super.isConsumed,
    super.substituteNote,
    super.recipe,
  });

  factory MealModel.fromLocal(dynamic data, {RecipeModel? recipe}) {
    return MealModel(
      id: data.id as int,
      weeklyPlanId: data.weeklyPlanId as int,
      dayOfWeek: data.dayOfWeek as int,
      mealType: data.mealType as String,
      name: data.name as String,
      imageUrl: data.imageUrl as String?,
      calories: data.calories as int?,
      proteinG: data.proteinG as double?,
      carbsG: data.carbsG as double?,
      fatG: data.fatG as double?,
      isConsumed: data.isConsumed as bool,
      substituteNote: data.substituteNote as String?,
      recipe: recipe,
    );
  }
}

class WeeklyPlanModel extends WeeklyPlanEntity {
  const WeeklyPlanModel({
    required super.id,
    required super.userId,
    required super.weekStartDate,
    super.nutritionistNotes,
    required super.meals,
  });

  factory WeeklyPlanModel.fromLocal(dynamic data, List<MealModel> meals) {
    return WeeklyPlanModel(
      id: data.id as int,
      userId: data.userId as String,
      weekStartDate: data.weekStartDate as DateTime,
      nutritionistNotes: data.nutritionistNotes as String?,
      meals: meals,
    );
  }
}