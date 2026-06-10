import 'package:drift/drift.dart';
import 'users_table.dart';

/// Medicamento o suplemento configurado por el usuario.
/// daysJson: lista de días activos ej. ["L","M","X"]
/// timesJson: lista de horas ej. ["08:00","16:00","22:00"]
class MedicationsTable extends Table {
  @override
  String get tableName => 'medications';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get userId => text().references(UsersTable, #id)();
  TextColumn get name => text()(); // "Vitamin D3"
  TextColumn get dosage => text()(); // "1 Cápsula"
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get timesJson => text().withDefault(const Constant('[]'))();
  TextColumn get daysJson => text().withDefault(const Constant('[]'))();
  IntColumn get intervalHours => integer().nullable()(); // "Cada: 8 horas"
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Registro de toma de medicamento — cuándo el usuario marcó como tomado.
class MedicationLogsTable extends Table {
  @override
  String get tableName => 'medication_logs';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get medicationId => integer().references(MedicationsTable, #id)();
  DateTimeColumn get takenAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isTaken => boolean().withDefault(const Constant(true))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}