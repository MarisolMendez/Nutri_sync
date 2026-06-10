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

  Future<void> deleteUser(String id) =>
      (delete(usersTable)..where((u) => u.id.equals(id))).go();
}