import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';

/// Maneja push notifications cuando la app está cerrada o en background.
/// DEBE ser una función top-level (no un método de clase) y DEBE tener
/// la anotación @pragma para que el compilador no la elimine en release.
///
/// Android ejecuta esto en un isolate separado del main — por eso
/// necesita su propio Firebase.initializeApp().
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // El sistema operativo ya muestra la notificación automáticamente
  // en background/terminated — aquí solo procesamos data si la necesitamos
  // (ej. actualizar un badge, loggear analytics, etc).
}