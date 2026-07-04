import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Contrato base que todo use case debe implementar.
///
/// [ResultType] = tipo de dato que retorna en éxito
/// [Params] = parámetros que recibe
///
/// Retorna [Either<Failure, ResultType>]:
///   - Left(Failure) → algo salió mal
///   - Right(Type)   → éxito con el dato
///
/// Ejemplo de uso:
/// ```dart
/// class GetWeeklyPlanUseCase implements UseCase<WeeklyPlanEntity, WeeklyPlanParams> {
///   @override
///   Future<Either<Failure, WeeklyPlanEntity>> call(WeeklyPlanParams params) async {
///     return await repository.getWeeklyPlan(params.userId, params.weekDate);
///   }
/// }
/// ```
abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

/// Usar cuando el use case no necesita parámetros.
///
/// Ejemplo:
/// ```dart
/// class GetCurrentUserUseCase implements UseCase<UserEntity, NoParams> { ... }
/// final result = await getCurrentUser(NoParams());
/// ```
class NoParams {
  const NoParams();
}