import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies();

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies();

  // sl<SyncManager>().init();  // 

  runApp(
    const ProviderScope(
      child: NutriSyncApp(),
    ),
  );
}
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