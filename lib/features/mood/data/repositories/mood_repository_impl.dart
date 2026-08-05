import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mood_entity.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';
import '../datasources/mood_remote_datasource.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodLocalDatasource localDatasource;
  final MoodRemoteDatasource remoteDatasource;
  const MoodRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, void>> logMood({
    required String userId,
    required MoodValue mood,
    String? note,
  }) async {
    try {
      await localDatasource.saveMood(userId, mood, note);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }

    // Sincronizar con backend
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      await remoteDatasource.logMood(mood.dbValue, today, note: note);
    } catch (_) {
      // Error silencioso: los datos ya están guardados localmente
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, MoodEntity?>> getTodayMood({
    required String userId,
  }) async {
    try {
      final mood = await localDatasource.getTodayMood(userId);
      return Right(mood);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeekMoodSummary>> getWeekSummary({
    required String userId,
  }) async {
    try {
      final logs = await localDatasource.getWeekMoods(userId);

      // Construye lista de 7 días — Lun a Dom de la semana actual
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final List<MoodEntity?> days = List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        try {
          return logs.firstWhere(
            (l) =>
                l.loggedAt.year == day.year &&
                l.loggedAt.month == day.month &&
                l.loggedAt.day == day.day,
          );
        } catch (_) {
          return null;
        }
      });

      return Right(WeekMoodSummary(days: days));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}