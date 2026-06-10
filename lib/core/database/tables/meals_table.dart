import 'package:drift/drift.dart';
import 'weekly_plans_table.dart';

/// Una comida específica dentro de un día del plan semanal.
/// dayOfWeek: 1=Lunes ... 7=Domingo
/// mealType: breakfast, lunch, dinner, snack
class MealsTable extends Table {
  @override
  String get tableName => 'meals';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get weeklyPlanId => integer().references(WeeklyPlansTable, #id)();
  IntColumn get dayOfWeek => integer()(); // 1-7
  TextColumn get mealType => text()(); // breakfast | lunch | dinner | snack
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get calories => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  BoolColumn get isConsumed => boolean().withDefault(const Constant(false))();
  TextColumn get substituteNote => text().nullable()(); // "No lo voy a comer, ¿Qué comiste?"
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}