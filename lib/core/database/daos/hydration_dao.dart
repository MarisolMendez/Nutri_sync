import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/hydration_table.dart';

part 'hydration_dao.g.dart';

@DriftAccessor(tables: [HydrationTable])
class HydrationDao extends DatabaseAccessor<AppDatabase>
    with _$HydrationDaoMixin {
  HydrationDao(super.db);

  /// Todos los registros de agua de un día específico
  Future<List<HydrationTableData>> getDayLogs(String userId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(hydrationTable)
          ..where((h) =>
              h.userId.equals(userId) &
              h.loggedAt.isBiggerOrEqualValue(start) &
              h.loggedAt.isSmallerThanValue(end)))
        .get();
  }

  /// Total de ml bebidos en el día
  Future<int> getDayTotalMl(String userId, DateTime day) async {
    final logs = await getDayLogs(userId, day);
    return logs.fold<int>(0, (sum, log) => sum + log.amountMl);
  }

  Future<void> insertLog(HydrationTableCompanion log) =>
      into(hydrationTable).insert(log);

  Future<void> deleteLog(int id) =>
      (delete(hydrationTable)..where((h) => h.id.equals(id))).go();

  /// Registros de los últimos N días — para calcular racha
  Future<List<HydrationTableData>> getRecentLogs(String userId, int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    return (select(hydrationTable)
          ..where((h) =>
              h.userId.equals(userId) &
              h.loggedAt.isBiggerOrEqualValue(since))
          ..orderBy([(h) => OrderingTerm.desc(h.loggedAt)]))
        .get();
  }

  Future<List<HydrationTableData>> getUnsyncedLogs() =>
      (select(hydrationTable)..where((h) => h.isSynced.equals(false))).get();

  Future<void> markSynced(int id) =>
      (update(hydrationTable)..where((h) => h.id.equals(id)))
          .write(const HydrationTableCompanion(isSynced: Value(true)));
}