import 'package:drift/drift.dart';

/// Tabla local de usuarios.
/// Solo guardamos lo esencial — el perfil completo vive en Firestore.
/// Esta tabla existe para que la app funcione offline con los datos del usuario activo.
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  /// ID de Firebase Auth — es el identificador principal, no un autoincrement
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  IntColumn get dailyWaterGoalMl => integer().withDefault(const Constant(2000))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}