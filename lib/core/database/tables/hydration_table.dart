import 'package:drift/drift.dart';
import 'users_table.dart';

/// Cada registro es un vaso/botella de agua que el usuario agregó.
/// Para calcular el total del día se suman todos los registros de ese día.
class HydrationTable extends Table {
  @override
  String get tableName => 'hydration';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text().references(UsersTable, #id)();
  IntColumn get amountMl => integer()(); // 250 | 500 | 1000 | personalizado
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}