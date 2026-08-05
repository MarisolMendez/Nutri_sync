import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_plan_entities.dart';

abstract class MealPlanState extends Equatable {
  const MealPlanState();
  @override
  List<Object?> get props => [];
}

class MealPlanInitial extends MealPlanState {
  const MealPlanInitial();
}

class MealPlanLoading extends MealPlanState {
  const MealPlanLoading();
}

class MealPlanLoaded extends MealPlanState {
  final WeeklyPlanEntity plan;
  final int selectedDay; // 1=Lun ... 7=Dom
  final String? errorMessage;

  const MealPlanLoaded({
    required this.plan,
    required this.selectedDay,
    this.errorMessage,
  });

  List<MealEntity> get mealsForSelectedDay =>
      plan.mealsForDay(selectedDay);

  MealPlanLoaded copyWith({
    WeeklyPlanEntity? plan,
    int? selectedDay,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MealPlanLoaded(
      plan: plan ?? this.plan,
      selectedDay: selectedDay ?? this.selectedDay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [plan, selectedDay, errorMessage];
}

class MealPlanEmpty extends MealPlanState {
  const MealPlanEmpty();
}

class MealPlanError extends MealPlanState {
  final String message;
  const MealPlanError(this.message);
  @override
  List<Object?> get props => [message];
}

// Estado del detalle de receta
abstract class RecipeDetailState extends Equatable {
  const RecipeDetailState();
  @override
  List<Object?> get props => [];
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailLoaded extends RecipeDetailState {
  final MealEntity meal;
  final RecipeEntity recipe;
  final List<IngredientEntity> ingredients;

  const RecipeDetailLoaded({
    required this.meal,
    required this.recipe,
    required this.ingredients,
  });

  RecipeDetailLoaded toggleIngredient(int index) {
    final updated = List<IngredientEntity>.from(ingredients);
    updated[index] = updated[index].copyWith(
      isChecked: !updated[index].isChecked,
    );
    return RecipeDetailLoaded(
      meal: meal,
      recipe: recipe,
      ingredients: updated,
    );
  }

  @override
  List<Object?> get props => [meal, recipe, ingredients];
}

class RecipeDetailError extends RecipeDetailState {
  final String message;
  const RecipeDetailError(this.message);
  @override
  List<Object?> get props => [message];
}