import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Servicio central de notificaciones. Maneja dos canales distintos:
///
/// 1. FCM (push remoto) — la nutrióloga envía la dieta desde su plataforma.
///    Requiere internet, llega aunque la app esté cerrada.
///
/// 2. Local scheduled — recordatorios de medicamento y agua.
///    Se programan en el dispositivo, funcionan sin internet.
class NotificationService {
  final FirebaseMessaging _messaging;
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

  static const _channelMealPlan = AndroidNotificationChannel(
    'meal_plan_channel',
    'Plan de Comidas',
    description: 'Avisos cuando tu nutrióloga actualiza tu plan',
    importance: Importance.high,
  );

  NotificationService({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    bool useFcm = true,
  })  : _messaging = messaging,
        _localNotifications = localNotifications,
        _useFcm = useFcm;

  /// Envía una notificación de prueba inmediata para verificar que funciona
  Future<void> sendTestNotification() async {
    await _localNotifications.show(
      9999,
      '🔔 Notificaciones activadas',
      'Los recordatorios de NutriSync funcionan correctamente',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Recordatorios de Medicación',
          channelDescription: 'Avisos para tomar tus medicamentos a tiempo',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Inicializa todo — llamar una sola vez en bootstrap.dart
  Future<void> init() async {
    tz_data.initializeTimeZones();

    // ── Configuración de notificaciones locales ──────────────────
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

    // Crea los canales en Android (requerido en Android 8+)
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channelMedication);
    await androidPlugin?.createNotificationChannel(_channelHydration);
    await androidPlugin?.createNotificationChannel(_channelMealPlan);

    // ── Permiso POST_NOTIFICATIONS (Android 13+) ──────────────────
    await androidPlugin?.requestNotificationsPermission();

    // ── FCM (solo si está habilitado) ───────────────────────────────
    if (_useFcm) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listener de mensajes en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    }
  }

  /// Token único del dispositivo — se manda al backend para que
  /// la nutrióloga pueda enviarle push a ESTE paciente específico.
  Future<String?> getDeviceToken() =>
      _useFcm ? _messaging.getToken() : Future.value(null);

  /// Cuando llega un push mientras la app está abierta,
  /// FCM no lo muestra automático en Android — hay que mostrarlo
  /// manualmente con flutter_local_notifications.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Determina el canal según el tipo de mensaje que manda el backend
    final type = message.data['type'] as String?;
    final channel = switch (type) {
      'meal_plan_update' => _channelMealPlan,
      _ => _channelMealPlan,
    };

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ── Recordatorios LOCALES de medicación ───────────────────────────

  /// Programa un recordatorio diario repetido a una hora fija.
  /// [id] debe ser único por medicamento+hora para poder cancelarlo después.
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    // Si la hora es dentro de los próximos 60 segundos, envía inmediatamente
    final diff = scheduledDate.difference(tz.TZDateTime.now(tz.local));
    if (diff.inSeconds < 60) {
      await _localNotifications.show(
        id,
        'Hora de tu medicamento 💊',
        '$medicationName — $dosage',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelMedication.id,
            _channelMedication.name,
            channelDescription: _channelMedication.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      return;
    }

    await _localNotifications.zonedSchedule(
      id,
      'Hora de tu medicamento 💊',
      '$medicationName — $dosage',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelMedication.id,
          _channelMedication.name,
          channelDescription: _channelMedication.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // se repite cada día
    );
  }

  // ── Recordatorios LOCALES de hidratación ──────────────────────────

  /// Programa recordatorios de agua cada [intervalHours] horas,
  /// dentro de una ventana horaria razonable (ej. 8am a 10pm).
  Future<void> scheduleHydrationReminders({
    required int intervalHours,
    int startHour = 8,
    int endHour = 22,
  }) async {
    // Cancela los anteriores antes de reprogramar
    await cancelHydrationReminders();

    int reminderId = 2000; // rango reservado para hidratación
    for (int hour = startHour; hour <= endHour; hour += intervalHours) {
      await _localNotifications.zonedSchedule(
        reminderId,
        'Hora de hidratarte 💧',
        'No olvides tomar agua para llegar a tu meta diaria',
        _nextInstanceOfTime(hour, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelHydration.id,
            _channelHydration.name,
            channelDescription: _channelHydration.description,
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      reminderId++;
    }
  }

  Future<void> cancelHydrationReminders() async {
    for (int id = 2000; id < 2020; id++) {
      await _localNotifications.cancel(id);
    }
  }

  Future<void> cancelMedicationReminder(int id) =>
      _localNotifications.cancel(id);

  Future<void> cancelAll() => _localNotifications.cancelAll();

  /// Calcula la próxima ocurrencia de una hora:minuto específicos.
  /// Si la hora ya pasó hoy, programa para mañana.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}