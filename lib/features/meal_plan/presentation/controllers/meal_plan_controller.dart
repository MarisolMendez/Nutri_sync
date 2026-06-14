import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/usecases/get_weekly_plan_usecase.dart';
import '../../domain/usecases/update_meal_usecase.dart';
import 'meal_plan_state.dart';

final mealPlanControllerProvider =
    NotifierProvider<MealPlanController, MealPlanState>(
  MealPlanController.new,
);

/// Provider for recipe detail state based on a meal entity
final recipeDetailStateProvider =
    Provider.family<RecipeDetailState, MealEntity>(
  (ref, meal) {
    if (meal.recipe == null) {
      return const RecipeDetailError('No hay receta disponible');
    }
    return RecipeDetailLoaded(
      meal: meal,
      recipe: meal.recipe!,
      ingredients: meal.recipe!.ingredients,
    );
  },
);

class MealPlanController extends Notifier<MealPlanState> {
  late final GetWeeklyPlanUseCase _getWeeklyPlan;
  late final UpdateMealUseCase _updateMeal;

  static const _tempUserId = 'user_1';

  @override
  MealPlanState build() {
    _getWeeklyPlan = sl();
    _updateMeal = sl();
    return const MealPlanInitial();
  }

  Future<void> load() async {
    state = const MealPlanLoading();

    // Lunes de la semana actual
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    final result = await _getWeeklyPlan(
      WeeklyPlanParams(userId: _tempUserId, weekStart: weekStart),
    );

    result.fold(
      (failure) => state = MealPlanError(failure.message),
      (plan) {
        if (plan == null) {
          state = const MealPlanEmpty();
        } else {
          state = MealPlanLoaded(
            plan: plan,
            selectedDay: now.weekday, // Día actual seleccionado
          );
        }
      },
    );
  }

  void selectDay(int dayOfWeek) {
    if (state is MealPlanLoaded) {
      state = (state as MealPlanLoaded).copyWith(selectedDay: dayOfWeek);
    }
  }

  Future<void> toggleMealConsumed(MealEntity meal) async {
    final result = await _updateMeal(
      UpdateMealParams(
        mealId: meal.id,
        consumed: !meal.isConsumed,
      ),
    );
    result.fold(
      (failure) => state = MealPlanError(failure.message),
      (_) => load(),
    );
  }
}