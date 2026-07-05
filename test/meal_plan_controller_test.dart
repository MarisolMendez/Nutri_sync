import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nutri_sync/core/error/failures.dart';
import 'package:nutri_sync/features/meal_plan/domain/entities/meal_plan_entities.dart';
import 'package:nutri_sync/features/meal_plan/domain/repositories/meal_plan_repository.dart';
import 'package:nutri_sync/features/meal_plan/domain/usecases/get_weekly_plan_usecase.dart';
import 'package:nutri_sync/features/meal_plan/domain/usecases/save_substitute_note_usecase.dart';
import 'package:nutri_sync/features/meal_plan/domain/usecases/update_meal_usecase.dart';
import 'package:nutri_sync/features/meal_plan/presentation/controllers/meal_plan_controller.dart';
import 'package:nutri_sync/features/meal_plan/presentation/controllers/meal_plan_state.dart';

void main() {
  late GetIt sl;

  setUp(() {
    sl = GetIt.instance;
    sl.reset();

    sl.registerLazySingleton<MealPlanRepository>(() => _FakeMealPlanRepository());
    sl.registerLazySingleton<GetWeeklyPlanUseCase>(
      () => _FakeGetWeeklyPlanUseCase(),
    );
    sl.registerLazySingleton<UpdateMealUseCase>(
      () => _FakeUpdateMealUseCase(),
    );
    sl.registerLazySingleton<SaveSubstituteNoteUseCase>(
      () => _FakeSaveSubstituteNoteUseCase(),
    );
  });

  test('toggleMealConsumed inverts isConsumed and persists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(mealPlanControllerProvider.notifier);

    final meal = MealEntity(
      id: 7,
      weeklyPlanId: 1,
      dayOfWeek: 1,
      mealType: 'breakfast',
      name: 'Avena',
      isConsumed: false,
    );

    container.read(mealPlanControllerProvider.notifier).state = MealPlanLoaded(
      plan: WeeklyPlanEntity(
        id: 1,
        userId: 'user_1',
        weekStartDate: DateTime(2026, 7, 1),
        meals: [meal],
      ),
      selectedDay: 1,
    );

    await controller.toggleMealConsumed(meal);

    // Debe invertir: meal.isConsumed=false → consumed=true
    expect(_FakeUpdateMealUseCase.lastConsumed, isTrue);
    expect(container.read(mealPlanControllerProvider), isA<MealPlanLoading>());
  });
}

class _FakeMealPlanRepository implements MealPlanRepository {
  @override
  Future<Either<Failure, void>> updateMealConsumed({
    required int mealId,
    required bool consumed,
    String? substituteNote,
    String? voiceNotePath,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveSubstituteNote({
    required int mealId,
    String? note,
    String? voiceNotePath,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, RecipeEntity?>> getRecipeByMeal({
    required int mealId,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, WeeklyPlanEntity?>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  }) async {
    return const Right(null);
  }
}

class _FakeGetWeeklyPlanUseCase extends GetWeeklyPlanUseCase {
  _FakeGetWeeklyPlanUseCase() : super(_FakeMealPlanRepository());
}

class _FakeUpdateMealUseCase extends UpdateMealUseCase {
  static bool? lastConsumed;

  _FakeUpdateMealUseCase() : super(_FakeMealPlanRepository());

  @override
  Future<Either<Failure, void>> call(UpdateMealParams params) async {
    lastConsumed = params.consumed;
    return const Right(null);
  }
}

class _FakeSaveSubstituteNoteUseCase extends SaveSubstituteNoteUseCase {
  _FakeSaveSubstituteNoteUseCase() : super(_FakeMealPlanRepository());
}
