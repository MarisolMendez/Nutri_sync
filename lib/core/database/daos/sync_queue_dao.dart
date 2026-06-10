import 'package:drift/drift.dart';
import '../app_database.dart';
import '../sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Toda la cola pendiente, ordenada por fecha de creación (FIFO)
  Future<List<SyncQueueTableData>> getPendingOperations() =>
      (select(syncQueueTable)
            ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
          .get();

  /// Encola una operación nueva
  Future<void> enqueue(SyncQueueTableCompanion operation) =>
      into(syncQueueTable).insert(operation);

  /// Elimina una operación ya procesada exitosamente
  Future<void> dequeue(int id) =>
      (delete(syncQueueTable)..where((s) => s.id.equals(id))).go();

  /// Incrementa el contador de reintentos — si llega a 3, se descarta
  Future<void> incrementRetry(int id) async {
    final op = await (select(syncQueueTable)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (op == null) return;
    await (update(syncQueueTable)..where((s) => s.id.equals(id))).write(
      SyncQueueTableCompanion(retryCount: Value(op.retryCount + 1)),
    );
  }

  /// Limpia operaciones con demasiados reintentos fallidos
  Future<void> clearFailedOperations({int maxRetries = 3}) =>
      (delete(syncQueueTable)
            ..where((s) => s.retryCount.isBiggerOrEqualValue(maxRetries)))
          .go();
}