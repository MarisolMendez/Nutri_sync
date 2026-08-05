import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final bool _useFcm;

  static const _channelMedication = AndroidNotificationChannel(
    'medication_channel',
    'Recordatorios de Medicación',
    description: 'Avisos para tomar tus medicamentos a tiempo',
    importance: Importance.high,
  );

  static const _channelHydration = AndroidNotificationChannel(
    'hydration_channel',
    'Recordatorios de Hidratación',
    description: 'Avisos para mantenerte hidratado',
    importance: Importance.defaultImportance,
  );

  NotificationService({
    FirebaseMessaging? messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    bool useFcm = true,
  })  : _messaging = messaging,
        _localNotifications = localNotifications,
        _useFcm = useFcm;

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channelMedication);
      await androidPlugin.createNotificationChannel(_channelHydration);
    }

    if (_useFcm && _messaging != null) {
      await _messaging!.requestPermission();
    }
  }

  Future<void> sendTestNotification() async {
    await _localNotifications.show(
      0,
      'NutriSync',
      '¡Notificaciones activadas!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Recordatorios de Hidratación',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }

  Future<void> cancelHydrationReminders() async {
    await _localNotifications.cancelAll();
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    DateTime? scheduledTime,
    int? hour,
    int? minute,
  }) async {
    int targetHour = hour ?? scheduledTime?.hour ?? 8;
    int targetMinute = minute ?? scheduledTime?.minute ?? 0;

    if (scheduledTime != null) {
      targetHour = scheduledTime.hour;
      targetMinute = scheduledTime.minute;
    }

    try {
      // Usar periodicallyShow para repetición diaria (más fiable que zonedSchedule)
      await _localNotifications.periodicallyShow(
        id,
        medicationName,
        dosage,
        // Usar targetHour y targetMinute para definir RepeatInterval
        RepeatInterval.daily,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Recordatorios de Medicación',
            channelDescription: 'Avisos para tomar tus medicamentos a tiempo',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            ongoing: false,
            autoCancel: true,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      // Si falla la programación, loguear el error en debug
      debugPrint('❌ Error al programar recordatorio de medicación: $e');
    }
  }

  Future<void> cancelMedicationReminder(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> scheduleHydrationReminders({int intervalHours = 2}) async {
    // Programar recordatorios de hidratación cada 2h
    for (int hour = 8; hour <= 22; hour += intervalHours) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        0,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.periodicallyShow(
        hour,
        'NutriSync - Hidratación',
        '¡No olvides tomar agua! 💧',
        RepeatInterval.daily,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_channel',
            'Recordatorios de Hidratación',
            importance: Importance.defaultImportance,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}