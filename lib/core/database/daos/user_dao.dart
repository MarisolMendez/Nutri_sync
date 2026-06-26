import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  /// Trae el usuario activo (solo debería haber uno en local)
  Future<UsersTableData?> getUser(String id) =>
      (select(usersTable)..where((u) => u.id.equals(id))).getSingleOrNull();

  /// Inserta o actualiza — si el usuario ya existe lo reemplaza
  Future<void> upsertUser(UsersTableCompanion user) =>
      into(usersTable).insertOnConflictUpdate(user);

  /// Versión simplificada para crear/actualizar desde fuera del DAO
  /// sin necesidad de importar drift.
  Future<void> createOrUpdate({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
    double? weightKg,
    double? heightCm,
    int? dailyWaterGoalMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      upsertUser(
        UsersTableCompanion(
          id: Value(id),
          email: Value(email),
          name: Value(name),
          photoUrl: Value(photoUrl),
          weightKg: Value(weightKg),
          heightCm: Value(heightCm),
          dailyWaterGoalMl: Value(dailyWaterGoalMl ?? 2000),
          createdAt: Value(createdAt ?? DateTime.now()),
          updatedAt: Value(updatedAt ?? DateTime.now()),
        ),
      );

  Future<void> deleteUser(String id) =>
      (delete(usersTable)..where((u) => u.id.equals(id))).go();
}