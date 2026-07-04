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
  final int id;
  final int mealId;
  final String title;
  final String? imageUrl;
  final String? mealTime; // "Desayuno • 08:30 AM"
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
  final int id;
  final int weeklyPlanId;
  final int dayOfWeek; // 1=Lun ... 7=Dom
  final String mealType; // breakfast|lunch|dinner|snack
  final String name;
  final String? imageUrl;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final bool isConsumed;
  final String? substituteNote;
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
        recipe: recipe,
      );

  @override
  List<Object?> get props => [id, dayOfWeek, mealType, isConsumed];
}

// ── Plan semanal ──────────────────────────────────────────────────────────────
class WeeklyPlanEntity extends Equatable {
  final int id;
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

  /// Comidas filtradas por día
  List<MealEntity> mealsForDay(int dayOfWeek) =>
      meals.where((m) => m.dayOfWeek == dayOfWeek).toList();

  WeeklyPlanEntity copyWith({
    int? id,
    String? userId,
    DateTime? weekStartDate,
    String? nutritionistNotes,
    List<MealEntity>? meals,
  }) =>
      WeeklyPlanEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        weekStartDate: weekStartDate ?? this.weekStartDate,
        nutritionistNotes: nutritionistNotes ?? this.nutritionistNotes,
        meals: meals ?? this.meals,
      );

  @override
  List<Object?> get props => [id, userId, weekStartDate];
}