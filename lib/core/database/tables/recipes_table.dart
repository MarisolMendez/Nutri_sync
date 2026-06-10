import 'package:drift/drift.dart';
import 'meals_table.dart';

/// Detalle completo de una receta — ingredientes, preparación, info nutricional.
/// Se guarda local para que el detalle de receta funcione offline.
class RecipesTable extends Table {
  @override
  String get tableName => 'recipes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get mealId => integer().references(MealsTable, #id)();
  TextColumn get title => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get mealTime => text().nullable()(); // "Desayuno • 08:30 AM"
  // Ingredientes y pasos guardados como JSON string
  TextColumn get ingredientsJson => text().withDefault(const Constant('[]'))();
  TextColumn get stepsJson => text().withDefault(const Constant('[]'))();
  IntColumn get calories => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  RealColumn get fiberG => real().nullable()();
  RealColumn get sodiumMg => real().nullable()();
  TextColumn get observations => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}