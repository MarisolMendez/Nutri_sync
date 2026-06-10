import 'package:drift/drift.dart';

/// Cola de operaciones pendientes de sincronizar con Firestore.
/// Cuando el usuario hace algo sin internet, la operación se encola aquí.
/// Cuando vuelve la conexión, sync_manager procesa la cola en orden.
///
/// entity: users | meals | hydration | mood | medications
/// operation: create | update | delete
/// payload: JSON con los datos a sincronizar
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get operation => text()(); // create | update | delete
  TextColumn get localId => text()(); // ID local del registro
  TextColumn get payload => text()(); // JSON con los datos
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}