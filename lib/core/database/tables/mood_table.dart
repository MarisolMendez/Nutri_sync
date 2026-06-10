import 'package:drift/drift.dart';
import 'users_table.dart';

/// Un registro diario de estado de ánimo.
/// moodValue: excellent | good | neutral | bad
/// Solo se permite un registro por día por usuario.
class MoodTable extends Table {
  @override
  String get tableName => 'mood';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text().references(UsersTable, #id)();
  TextColumn get moodValue => text()(); // excellent | good | neutral | bad
  TextColumn get note => text().nullable()(); // "¿Algo que quieras compartir?"
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}