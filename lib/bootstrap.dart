import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/di/providers.dart';
import 'core/database/app_database.dart';
import 'core/database/seed_data.dart';
import 'core/network/auth_interceptor.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_manager.dart';
import 'core/theme/app_theme.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  // Firebase desactivado — usando backend propio
  // (ver AppConfig.useFirebase)

  await initDependencies();

  // Datos de ejemplo — comidas para visualizar el plan
  await seedSampleData(sl<AppDatabase>());

  // Notificaciones — siempre (funciona sin Firebase)
  await sl<NotificationService>().init();

  // SyncManager — solo con Firebase
  if (AppConfig.useFirebase) {
    sl<SyncManager>().init();
    unawaited(sl<NotificationService>().sendTestNotification());
    unawaited(sl<NotificationService>().scheduleHydrationReminders(intervalHours: 2));
  }

  runApp(
    const ProviderScope(
      child: NutriSyncApp(),
    ),
  );
}

class NutriSyncApp extends StatefulWidget {
  const NutriSyncApp({super.key});

  @override
  State<NutriSyncApp> createState() => _NutriSyncAppState();
}

class _NutriSyncAppState extends State<NutriSyncApp>
    with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Redirigir automáticamente al login cuando el backend responda 401 (token expirado/inválido)
    AuthInterceptor.onSessionExpired = () {
      AppRouter.router.go('/login');
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkSessionOnResume();
    }
  }

  Future<void> _checkSessionOnResume() async {
    final hasToken = await AuthInterceptor.hasValidToken();
    if (!hasToken && mounted) {
      // Navegar a login solo si volvió de background y no hay sesión
      final router = GoRouter.of(context);
      router.go('/auth/login');
    }
  }

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
