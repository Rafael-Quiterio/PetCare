import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 1. INITIALIZE
  Future<void> initNotifcations() async {
    if (_isInitialized) return;

    tzData.initializeTimeZones();

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // 2. SHOW INSTANT (For Testing)
  Future<void> showInstantNotifiction({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Notificações Instantâneas',
          channelDescription: 'Canal para testes rápidos',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // 3. SCHEDULE REMINDER
  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
    required DateTime scheduledTime,
  }) async {
    
    // Default fallback
    String timeZoneName = 'Europe/Lisbon'; 

    // Timezone Logic 
    try {
      var timeZoneResult = await FlutterTimezone.getLocalTimezone();
      
      timeZoneName = timeZoneResult.toString(); 
      
    } catch (e) {
      print("Timezone error: $e. Using default.");
      timeZoneName = 'Europe/Lisbon';
    }

    // Configure Location
    try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
        // If the ID from phone is weird, fallback to Lisbon
        tz.setLocalLocation(tz.getLocation('Europe/Lisbon'));
    }

    // Convert DateTime
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Safety Check
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print("Hora já passou ($tzScheduledTime). Nada agendado.");
      return;
    }

    // Schedule
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id',
          'Lembretes Diários',
          channelDescription: 'Lembretes para completar tarefas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    print(">>> Alarme agendado para: $tzScheduledTime ($timeZoneName)");
  }
  
  // 4. CANCEL
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}