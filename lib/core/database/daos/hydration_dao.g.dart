// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hydration_dao.dart';

// ignore_for_file: type=lint
mixin _$HydrationDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $HydrationTableTable get hydrationTable => attachedDatabase.hydrationTable;
  HydrationDaoManager get managers => HydrationDaoManager(this);
}

class HydrationDaoManager {
  final _$HydrationDaoMixin _db;
  HydrationDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$HydrationTableTableTableManager get hydrationTable =>
      $$HydrationTableTableTableManager(
          _db.attachedDatabase, _db.hydrationTable);
}
