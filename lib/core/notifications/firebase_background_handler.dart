import 'package:firebase_messaging/firebase_messaging.dart';

/// No-op handler — Firebase desactivado en favor del backend propio.
/// Se mantiene la firma para compatibilidad con FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase está desactivado — no se procesan push notifications en background
}
