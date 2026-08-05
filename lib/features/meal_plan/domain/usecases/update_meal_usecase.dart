import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/meal_plan_repository.dart';

class UpdateMealUseCase implements UseCase<void, UpdateMealParams> {
  final MealPlanRepository repository;
  const UpdateMealUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateMealParams params) {
    return repository.updateMealConsumed(
      mealId: params.mealId,
      consumed: params.consumed,
      substituteNote: params.substituteNote,
      voiceNotePath: params.voiceNotePath,
    );
  }
}

class UpdateMealParams extends Equatable {
  final String mealId;
  final bool consumed;
  final String? substituteNote;
  final String? voiceNotePath;

  const UpdateMealParams({
    required this.mealId,
    required this.consumed,
    this.substituteNote,
    this.voiceNotePath,
  });

  @override
  List<Object?> get props => [mealId, consumed, substituteNote, voiceNotePath];
}