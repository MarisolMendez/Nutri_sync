// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_dao.dart';

// ignore_for_file: type=lint
mixin _$MoodDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $MoodTableTable get moodTable => attachedDatabase.moodTable;
  MoodDaoManager get managers => MoodDaoManager(this);
}

class MoodDaoManager {
  final _$MoodDaoMixin _db;
  MoodDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$MoodTableTableTableManager get moodTable =>
      $$MoodTableTableTableManager(_db.attachedDatabase, _db.moodTable);
}
