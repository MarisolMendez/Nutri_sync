import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/users_table.dart';
import 'tables/weekly_plans_table.dart';
import 'tables/meals_table.dart';
import 'tables/recipes_table.dart';
import 'tables/hydration_table.dart';
import 'tables/mood_table.dart';
import 'tables/medications_table.dart';
import 'sync_queue_table.dart';

import 'daos/user_dao.dart';
import 'daos/meal_dao.dart';
import 'daos/hydration_dao.dart';
import 'daos/mood_dao.dart';
import 'daos/medication_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

/// Base de datos local de NutriSync.
/// Drift genera app_database.g.dart con todo el código SQL automáticamente.
/// Para regenerar: flutter pub run build_runner build --delete-conflicting-outputs
@DriftDatabase(
  tables: [
    UsersTable,
    WeeklyPlansTable,
    MealsTable,
    RecipesTable,
    HydrationTable,
    MoodTable,
    MedicationsTable,
    MedicationLogsTable,
    SyncQueueTable,
  ],
  daos: [
    UserDao,
    MealDao,
    HydrationDao,
    MoodDao,
    MedicationDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Versión del schema — incrementar cuando se modifiquen tablas
  @override
  int get schemaVersion => 1;

  /// Migraciones — cuando schemaVersion sube, Drift llama esto
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Aquí irán las migraciones futuras
          // Ejemplo: if (from < 2) await m.addColumn(table, column);
        },
      );
}

/// Abre la conexión a SQLite en el directorio de documentos del dispositivo.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'nutrisync.db'));
    return NativeDatabase.createInBackground(file);
  });
}