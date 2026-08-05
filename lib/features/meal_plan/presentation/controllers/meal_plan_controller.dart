import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/usecases/get_weekly_plan_usecase.dart';
import '../../domain/usecases/update_meal_usecase.dart';
import '../../domain/usecases/save_substitute_note_usecase.dart';
import 'meal_plan_state.dart';

final mealPlanControllerProvider =
    NotifierProvider<MealPlanController, MealPlanState>(
  MealPlanController.new,
);

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
  late final SaveSubstituteNoteUseCase _saveSubstituteNote;

  static const _tempUserId = 'user_1';

  @override
  MealPlanState build() {
    _getWeeklyPlan = sl();
    _updateMeal = sl();
    _saveSubstituteNote = sl();
    return const MealPlanInitial();
  }

  Future<void> load() async {
    final previousState = state is MealPlanLoaded ? state as MealPlanLoaded : null;
    final previousDay = previousState?.selectedDay ?? DateTime.now().weekday;

    state = const MealPlanLoading();

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
          var finalPlan = plan;
          if (previousState != null) {
            final mergedMeals = plan.meals.map((newMeal) {
              final oldMeal = previousState.plan.meals
                  .where((m) => m.id == newMeal.id)
                  .firstOrNull;
              if (oldMeal != null && oldMeal.isConsumed) {
                return newMeal.copyWith(isConsumed: true);
              }
              return newMeal;
            }).toList();
            finalPlan = plan.copyWith(meals: mergedMeals);
          }

          state = MealPlanLoaded(
            plan: finalPlan,
            selectedDay: previousDay,
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
      (failure) {
        if (state is MealPlanLoaded) {
          state = (state as MealPlanLoaded).copyWith(
            errorMessage: failure.message,
          );
        } else {
          state = MealPlanError(failure.message);
        }
      },
      (_) => _markMealLocally(meal.id, consumed: !meal.isConsumed),
    );
  }

  Future<void> saveSubstituteNote({
    required String mealId,
    String? note,
    String? voiceNotePath,
  }) async {
    final result = await _saveSubstituteNote(
      SaveSubstituteNoteParams(
        mealId: mealId,
        consumed: true,
        note: note,
        voiceNotePath: voiceNotePath,
      ),
    );
    result.fold(
      (failure) => state = MealPlanError(failure.message),
      (_) => _markMealLocally(mealId, consumed: true, note: note),
    );
  }

  void _markMealLocally(String mealId, {bool consumed = true, String? note}) {
    if (state is! MealPlanLoaded) return;
    final loaded = state as MealPlanLoaded;
    final updatedMeals = loaded.plan.meals.map((m) {
      if (m.id == mealId) {
        return m.copyWith(
          isConsumed: consumed,
          substituteNote: note ?? m.substituteNote,
        );
      }
      return m;
    }).toList();
    state = loaded.copyWith(
      plan: loaded.plan.copyWith(meals: updatedMeals),
    );
  }
}