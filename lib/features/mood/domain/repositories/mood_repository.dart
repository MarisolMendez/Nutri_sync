import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mood_entity.dart';

abstract class MoodRepository {
  Future<Either<Failure, void>> logMood({
    required String userId,
    required MoodValue mood,
    String? note,
  });

  Future<Either<Failure, MoodEntity?>> getTodayMood({
    required String userId,
  });

  Future<Either<Failure, WeekMoodSummary>> getWeekSummary({
    required String userId,
  });
}