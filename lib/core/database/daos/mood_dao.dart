import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/mood_table.dart';

part 'mood_dao.g.dart';

@DriftAccessor(tables: [MoodTable])
class MoodDao extends DatabaseAccessor<AppDatabase> with _$MoodDaoMixin {
  MoodDao(super.db);

  /// El registro de hoy — solo debe existir uno por día
  Future<MoodTableData?> getTodayMood(String userId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(moodTable)
          ..where((m) =>
              m.userId.equals(userId) &
              m.loggedAt.isBiggerOrEqualValue(start) &
              m.loggedAt.isSmallerThanValue(end)))
        .getSingleOrNull();
  }

  /// Últimos 7 días — para el historial semanal de la pantalla de bienestar
  Future<List<MoodTableData>> getWeekMoods(String userId) {
    final since = DateTime.now().subtract(const Duration(days: 7));
    return (select(moodTable)
          ..where((m) =>
              m.userId.equals(userId) &
              m.loggedAt.isBiggerOrEqualValue(since))
          ..orderBy([(m) => OrderingTerm.asc(m.loggedAt)]))
        .get();
  }

  Future<void> upsertMood(MoodTableCompanion mood) =>
      into(moodTable).insertOnConflictUpdate(mood);

  Future<List<MoodTableData>> getUnsyncedMoods() =>
      (select(moodTable)..where((m) => m.isSynced.equals(false))).get();

  Future<void> markSynced(int id) =>
      (update(moodTable)..where((m) => m.id.equals(id)))
          .write(const MoodTableCompanion(isSynced: Value(true)));
}