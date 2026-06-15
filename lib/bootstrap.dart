import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/database/app_database.dart';
import 'core/database/seed_data.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies();

  // Insertar datos de ejemplo para el plan de comidas (sin backend)
  await seedSampleData(sl<AppDatabase>());

  runApp(
    const ProviderScope(
      child: NutriSyncApp(),
    ),
  );
}


class NutriSyncApp extends StatelessWidget {
  const NutriSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NutriSync',
      debugShowCheckedModeBanner: false,
      theme: NutriTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}