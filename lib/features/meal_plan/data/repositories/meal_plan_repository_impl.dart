import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_local_datasource.dart';
import '../datasources/meal_plan_remote_datasource.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final MealPlanLocalDatasource localDatasource;
  final MealPlanRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  MealPlanRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeeklyPlanEntity?>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  }) async {
    try {
      final plan = await localDatasource.getWeeklyPlan(userId, weekStart);
      return Right(plan);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener plan semanal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMealConsumed({
    required int mealId,
    required bool consumed,
    String? substituteNote,
    String? voiceNotePath,
  }) async {
    try {
      await localDatasource.markMealConsumed(mealId, consumed);
      if (substituteNote != null || voiceNotePath != null) {
        await localDatasource.saveSubstituteNote(
          mealId: mealId,
          note: substituteNote,
          voiceNotePath: voiceNotePath,
        );
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSubstituteNote({
    required int mealId,
    String? note,
    String? voiceNotePath,
  }) async {
    try {
      await localDatasource.saveSubstituteNote(
        mealId: mealId,
        note: note,
        voiceNotePath: voiceNotePath,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Error al guardar nota sustituta: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity?>> getRecipeByMeal({
    required int mealId,
  }) async {
    try {
      final recipe = await localDatasource.getRecipeByMealId(mealId);
      return Right(recipe);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener receta: $e'));
    }
  }
}