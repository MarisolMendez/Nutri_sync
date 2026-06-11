import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hydration_entity.dart';

abstract class HydrationRepository {
  Future<Either<Failure, HydrationSummary>> getDailySummary({
    required String userId,
    required DateTime date,
  });

  Future<Either<Failure, void>> logWater({
    required String userId,
    required int amountMl,
  });

  Future<Either<Failure, void>> deleteLog({
    required int logId,
  });

  Future<Either<Failure, int>> getStreakDays({
    required String userId,
  });
}