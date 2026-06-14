import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal_plan_entities.dart';
import '../repositories/meal_plan_repository.dart';

class GetWeeklyPlanUseCase
    implements UseCase<WeeklyPlanEntity?, WeeklyPlanParams> {
  final MealPlanRepository repository;
  const GetWeeklyPlanUseCase(this.repository);

  @override
  Future<Either<Failure, WeeklyPlanEntity?>> call(WeeklyPlanParams params) {
    return repository.getWeeklyPlan(
      userId: params.userId,
      weekStart: params.weekStart,
    );
  }
}

class WeeklyPlanParams extends Equatable {
  final String userId;
  final DateTime weekStart;

  const WeeklyPlanParams({required this.userId, required this.weekStart});

  @override
  List<Object> get props => [userId, weekStart];
}