// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_dao.dart';

// ignore_for_file: type=lint
mixin _$MealDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $WeeklyPlansTableTable get weeklyPlansTable =>
      attachedDatabase.weeklyPlansTable;
  $MealsTableTable get mealsTable => attachedDatabase.mealsTable;
  $RecipesTableTable get recipesTable => attachedDatabase.recipesTable;
  MealDaoManager get managers => MealDaoManager(this);
}

class MealDaoManager {
  final _$MealDaoMixin _db;
  MealDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$WeeklyPlansTableTableTableManager get weeklyPlansTable =>
      $$WeeklyPlansTableTableTableManager(
          _db.attachedDatabase, _db.weeklyPlansTable);
  $$MealsTableTableTableManager get mealsTable =>
      $$MealsTableTableTableManager(_db.attachedDatabase, _db.mealsTable);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db.attachedDatabase, _db.recipesTable);
}
