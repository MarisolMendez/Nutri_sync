import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/hydration_entity.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_local_datasource.dart';

class HydrationRepositoryImpl implements HydrationRepository {
  final HydrationLocalDatasource localDatasource;

  const HydrationRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, HydrationSummary>> getDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final logs = await localDatasource.getDayLogs(userId, date);
      final totalMl = await localDatasource.getDayTotalMl(userId, date);
      final streak = await getStreakDays(userId: userId);
      final streakDays = streak.fold((_) => 0, (s) => s);

      // Meta por defecto 2000ml — se actualizará desde el perfil del usuario
      const goalMl = 2000;
      const goalGlasses = 8;
      final totalGlasses = (totalMl / 250).floor();

      return Right(
        HydrationSummary(
          totalMl: totalMl,
          goalMl: goalMl,
          totalGlasses: totalGlasses,
          goalGlasses: goalGlasses,
          streakDays: streakDays,
          logs: logs,
        ),
      );
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logWater({
    required String userId,
    required int amountMl,
  }) async {
    try {
      await localDatasource.insertLog(userId, amountMl);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLog({required int logId}) async {
    try {
      await localDatasource.deleteLog(logId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getStreakDays({required String userId}) async {
    try {
      final recentLogs = await localDatasource.getRecentLogs(userId, 30);

      if (recentLogs.isEmpty) return const Right(0);

      // Agrupa logs por día y cuenta días consecutivos con meta cumplida
      final Map<String, int> dailyTotals = {};
      for (final log in recentLogs) {
        final key =
            '${log.loggedAt.year}-${log.loggedAt.month}-${log.loggedAt.day}';
        dailyTotals[key] = (dailyTotals[key] ?? 0) + log.amountMl;
      }

      int streak = 0;
      DateTime day = DateTime.now();

      while (true) {
        final key = '${day.year}-${day.month}-${day.day}';
        final total = dailyTotals[key] ?? 0;
        if (total >= 2000) {
          streak++;
          day = day.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return Right(streak);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}