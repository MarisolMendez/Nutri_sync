import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/meal_plan_repository.dart';

/// Sincroniza el plan semanal cuando vuelve internet.
/// Por ahora es un placeholder — se conectará al backend del nutriólogo.
class SyncMealPlansUseCase implements UseCase<void, NoParams> {
  final MealPlanRepository repository;
  const SyncMealPlansUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // TODO: conectar con API del nutriólogo cuando esté disponible
    return const Right(null);
  }
}