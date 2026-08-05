import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/hydration_entity.dart';
import '../../domain/repositories/hydration_repository.dart';
import '../datasources/hydration_local_datasource.dart';
import '../datasources/hydration_remote_datasource.dart';

class HydrationRepositoryImpl implements HydrationRepository {
  final HydrationLocalDatasource localDatasource;
  final HydrationRemoteDatasource remoteDatasource;

  const HydrationRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, HydrationSummary>> getDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final logs = await localDatasource.getDayLogs(userId, date);
      var localTotalMl = await localDatasource.getDayTotalMl(userId, date);
      final streak = await getStreakDays(userId: userId);
      final streakDays = streak.fold((_) => 0, (s) => s);

      // Obtener total remoto y combinarlo con local
      var remoteTotalMl = 0;
      try {
        final todayStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        remoteTotalMl = await remoteDatasource.getDailyTotalMl(todayStr);
      } catch (_) {
        // Si falla la red, usar solo datos locales
      }

      // El total real es el mayor entre local y remoto
      final totalMl = localTotalMl > remoteTotalMl ? localTotalMl : remoteTotalMl;

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
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }

    // Sincronizar con backend
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      await remoteDatasource.logWater(today, amountMl);
    } catch (_) {
      // Error silencioso: los datos ya están guardados localmente
    }

    return const Right(null);
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