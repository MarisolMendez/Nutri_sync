// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $MedicationsTableTable get medicationsTable =>
      attachedDatabase.medicationsTable;
  $MedicationLogsTableTable get medicationLogsTable =>
      attachedDatabase.medicationLogsTable;
  MedicationDaoManager get managers => MedicationDaoManager(this);
}

class MedicationDaoManager {
  final _$MedicationDaoMixin _db;
  MedicationDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$MedicationsTableTableTableManager get medicationsTable =>
      $$MedicationsTableTableTableManager(
          _db.attachedDatabase, _db.medicationsTable);
  $$MedicationLogsTableTableTableManager get medicationLogsTable =>
      $$MedicationLogsTableTableTableManager(
          _db.attachedDatabase, _db.medicationLogsTable);
}
