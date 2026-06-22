import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/medications_table.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [MedicationsTable, MedicationLogsTable])
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  /// Todos los medicamentos del usuario
  Future<List<MedicationsTableData>> getMedications(String userId) =>
      (select(medicationsTable)
            ..where((m) => m.userId.equals(userId)))
          .get();

  Future<void> upsertMedication(MedicationsTableCompanion medication) =>
      into(medicationsTable).insertOnConflictUpdate(medication);

  Future<void> deleteMedication(int id) =>
      (delete(medicationsTable)..where((m) => m.id.equals(id))).go();

  /// Logs de hoy — para saber qué ya tomó el usuario
  Future<List<MedicationLogsTableData>> getTodayLogs(int medicationId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(medicationLogsTable)
          ..where((l) =>
              l.medicationId.equals(medicationId) &
              l.takenAt.isBiggerOrEqualValue(start) &
              l.takenAt.isSmallerThanValue(end)))
        .get();
  }

  /// IDs de medicamentos ya marcados como tomados hoy
  Future<Set<int>> getTodayTakenIds() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final logs = await (select(medicationLogsTable)
          ..where((l) =>
              l.takenAt.isBiggerOrEqualValue(start) &
              l.takenAt.isSmallerThanValue(end)))
        .get();
    return logs.map((l) => l.medicationId).toSet();
  }

  Future<void> insertLog(MedicationLogsTableCompanion log) =>
      into(medicationLogsTable).insert(log);

  Future<List<MedicationsTableData>> getUnsyncedMedications() =>
      (select(medicationsTable)
            ..where((m) => m.isSynced.equals(false)))
          .get();

  Future<void> markSynced(int id) =>
      (update(medicationsTable)..where((m) => m.id.equals(id)))
          .write(const MedicationsTableCompanion(isSynced: Value(true)));
}