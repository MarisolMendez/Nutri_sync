import 'package:equatable/equatable.dart';

// ── Ingrediente ───────────────────────────────────────────────────────────────
class IngredientEntity extends Equatable {
  final String name;
  final bool isChecked;

  const IngredientEntity({required this.name, this.isChecked = false});

  IngredientEntity copyWith({bool? isChecked}) =>
      IngredientEntity(name: name, isChecked: isChecked ?? this.isChecked);

  @override
  List<Object?> get props => [name, isChecked];
}

// ── Receta ────────────────────────────────────────────────────────────────────
class RecipeEntity extends Equatable {
  final String id;
  final String mealId;
  final String title;
  final String? imageUrl;
  final String? mealTime;
  final List<IngredientEntity> ingredients;
  final List<String> steps;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? sodiumMg;
  final String? observations;

  const RecipeEntity({
    required this.id,
    required this.mealId,
    required this.title,
    this.imageUrl,
    this.mealTime,
    required this.ingredients,
    required this.steps,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.sodiumMg,
    this.observations,
  });

  @override
  List<Object?> get props => [id, mealId, title];
}

// ── Comida del plan ───────────────────────────────────────────────────────────
class MealEntity extends Equatable {
  final String id;
  final String weeklyPlanId;
  final int dayOfWeek;
  final String mealType;
  final String name;
  final String? imageUrl;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final bool isConsumed;
  final String? substituteNote;
  final String? note;
  final RecipeEntity? recipe;

  const MealEntity({
    required this.id,
    required this.weeklyPlanId,
    required this.dayOfWeek,
    required this.mealType,
    required this.name,
    this.imageUrl,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.isConsumed = false,
    this.substituteNote,
    this.note,
    this.recipe,
  });

  MealEntity copyWith({bool? isConsumed, String? substituteNote}) =>
      MealEntity(
        id: id,
        weeklyPlanId: weeklyPlanId,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        name: name,
        imageUrl: imageUrl,
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
        isConsumed: isConsumed ?? this.isConsumed,
        substituteNote: substituteNote ?? this.substituteNote,
        note: note,
        recipe: recipe,
      );

  @override
  List<Object?> get props => [id, dayOfWeek, mealType, isConsumed];
}

// ── Plan semanal ──────────────────────────────────────────────────────────────
class WeeklyPlanEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime weekStartDate;
  final String? nutritionistNotes;
  final List<MealEntity> meals;

  const WeeklyPlanEntity({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    this.nutritionistNotes,
    required this.meals,
  });

  WeeklyPlanEntity copyWith({List<MealEntity>? meals, String? nutritionistNotes}) =>
      WeeklyPlanEntity(
        id: id,
        userId: userId,
        weekStartDate: weekStartDate,
        nutritionistNotes: nutritionistNotes ?? this.nutritionistNotes,
        meals: meals ?? this.meals,
      );

  List<MealEntity> mealsForDay(int dayOfWeek) =>
      meals.where((m) => m.dayOfWeek == dayOfWeek).toList();

  @override
  List<Object?> get props => [id, userId, weekStartDate, meals, nutritionistNotes];
}