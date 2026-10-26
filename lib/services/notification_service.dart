import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder.dart';

/// Servicio de notificaciones locales
/// Sprint 2 - HU-4: Recordatorios de horarios de comida
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar zonas horarias
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos en Android 13+
    await requestPermission();

    _initialized = true;
  }

  /// Solicitar permisos de notificación explícitamente (Android 13+ e iOS)
  Future<bool> requestPermission() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted =
        await androidImplementation?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Mostrar una notificación de prueba o instantánea
  Future<void> showNotificationNow({
    required String title,
    required String message,
  }) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'nutiok_meals',
      'Recordatorios de Comida',
      channelDescription: 'Notificaciones para recordar horarios de comida',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      DateTime.now().millisecond,
      title,
      message,
      details,
    );
  }

  /// Callback cuando se toca una notificacion
  void _onNotificationTapped(NotificationResponse response) {
    // Navegar a la pantalla de recordatorios
    // Se maneja en el main con el callback
  }

  /// Programar un recordatorio de comida
  Future<int> scheduleReminder(ReminderModel reminder) async {
    await initialize();

    final scheduledTime = _getNextOccurrence(reminder.time);

    final androidDetails = const AndroidNotificationDetails(
      'nutiok_meals',
      'Recordatorios de Comida',
      channelDescription: 'Notificaciones para recordar horarios de comida',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = reminder.id.isNotEmpty ? reminder.id.hashCode : reminder.hashCode;

    if (reminder.repeatDaily) {
      // Repeticion diaria
      await _plugin.zonedSchedule(
        id,
        reminder.title,
        reminder.message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      // Notificacion unica
      await _plugin.zonedSchedule(
        id,
        reminder.title,
        reminder.message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    return id;
  }

  /// Cancelar un recordatorio programado
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancelar todos los recordatorios
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Obtener la proxima ocurrencia de una hora dada
  tz.TZDateTime _getNextOccurrence(String timeStr) {
    final now = tz.TZDateTime.now(tz.local);
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Si la hora ya paso hoy, programar para manana
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
