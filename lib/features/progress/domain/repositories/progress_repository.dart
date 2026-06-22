import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  /// Calcula el resumen de progreso para la semana que contiene [referenceDate]
  Future<Either<Failure, WeeklyProgressEntity>> getWeeklyProgress({
    required String userId,
    required DateTime referenceDate,
  });
}