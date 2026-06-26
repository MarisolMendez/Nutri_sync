import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/providers.dart';
import 'core/database/app_database.dart';
import 'core/database/seed_data.dart';
import 'core/notifications/firebase_background_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registra el handler de background ANTES de cualquier otra cosa de FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initDependencies();

  // Datos de ejemplo — comidas para visualizar el plan
  await seedSampleData(sl<AppDatabase>());

  // Notificaciones — inicializa canales y pide permisos
  await sl<NotificationService>().init();

  // SyncManager — empieza a escuchar conectividad
  sl<SyncManager>().init();

  // Notificación de prueba inmediata para verificar permisos
  unawaited(sl<NotificationService>().sendTestNotification());

  // Recordatorios de hidratación cada 2h entre 8am y 10pm
  unawaited(sl<NotificationService>().scheduleHydrationReminders(intervalHours: 2));

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