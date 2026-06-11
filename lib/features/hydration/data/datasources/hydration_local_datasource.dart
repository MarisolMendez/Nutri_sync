import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/hydration_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../models/hydration_model.dart';

abstract class HydrationLocalDatasource {
  Future<List<HydrationModel>> getDayLogs(String userId, DateTime day);
  Future<int> getDayTotalMl(String userId, DateTime day);
  Future<void> insertLog(String userId, int amountMl);
  Future<void> deleteLog(int id);
  Future<List<HydrationModel>> getRecentLogs(String userId, int days);
}

class HydrationLocalDatasourceImpl implements HydrationLocalDatasource {
  final HydrationDao hydrationDao;
  const HydrationLocalDatasourceImpl({required this.hydrationDao});

  @override
  Future<List<HydrationModel>> getDayLogs(String userId, DateTime day) async {
    try {
      final logs = await hydrationDao.getDayLogs(userId, day);
      return logs.map((l) => HydrationModel.fromLocal(l)).toList();
    } catch (e) {
      throw DatabaseException('Error al leer logs de hidratación: $e');
    }
  }

  @override
  Future<int> getDayTotalMl(String userId, DateTime day) async {
    try {
      return await hydrationDao.getDayTotalMl(userId, day);
    } catch (e) {
      throw DatabaseException('Error al calcular total de hidratación: $e');
    }
  }

  @override
  Future<void> insertLog(String userId, int amountMl) async {
    try {
      await hydrationDao.insertLog(
        HydrationTableCompanion.insert(
          userId: userId,
          amountMl: amountMl,
        ),
      );
    } catch (e) {
      throw DatabaseException('Error al registrar agua: $e');
    }
  }

  @override
  Future<void> deleteLog(int id) async {
    try {
      await hydrationDao.deleteLog(id);
    } catch (e) {
      throw DatabaseException('Error al eliminar log: $e');
    }
  }

  @override
  Future<List<HydrationModel>> getRecentLogs(String userId, int days) async {
    try {
      final logs = await hydrationDao.getRecentLogs(userId, days);
      return logs.map((l) => HydrationModel.fromLocal(l)).toList();
    } catch (e) {
      throw DatabaseException('Error al leer logs recientes: $e');
    }
  }
}