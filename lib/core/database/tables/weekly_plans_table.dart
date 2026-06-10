import 'package:drift/drift.dart';
import 'users_table.dart';

/// Un plan semanal asignado por la nutrióloga al paciente.
/// Cada plan tiene 7 días, cada día tiene comidas asignadas.
class WeeklyPlansTable extends Table {
  @override
  String get tableName => 'weekly_plans';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()(); // ID en Firestore
  TextColumn get userId => text().references(UsersTable, #id)();
  DateTimeColumn get weekStartDate => dateTime()();
  TextColumn get nutritionistNotes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}