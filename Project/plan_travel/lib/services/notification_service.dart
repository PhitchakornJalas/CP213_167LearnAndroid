import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  // Schedule a countdown notification for a specific event
  Future<void> scheduleEventAlert({
    required String eventId,
    required String eventTitle,
    required DateTime eventStartTime,
    required int daysBefore,
    required int hour,
    required int minute,
  }) async {
    // Generate a unique ID based on eventId string
    int id = eventId.hashCode;

    DateTime scheduledDate = DateTime(
      eventStartTime.year,
      eventStartTime.month,
      eventStartTime.day,
      hour,
      minute,
    ).subtract(Duration(days: daysBefore));

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'เตรียมตัวออกเดินทาง!',
      body: 'อีก $daysBefore วันจะถึงกิจกรรม "$eventTitle" แล้วครับ!',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_countdown',
          'Event Countdown',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Schedule a reminder before the event starts (for timed events)
  Future<void> scheduleEventStartAlert({
    required String eventId,
    required String eventTitle,
    required DateTime eventStartTime,
    required int hoursBefore,
  }) async {
    // ใช้ ID ที่ต่างจาก Countdown (บวก 1)
    int id = eventId.hashCode + 1; 

    DateTime scheduledDate = eventStartTime.subtract(Duration(hours: hoursBefore));

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'ใกล้ถึงเวลากิจกรรมแล้ว!',
      body: 'อีก $hoursBefore ชั่วโมงจะถึงกิจกรรม "$eventTitle" แล้วครับ!',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_start_reminder',
          'Event Start Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Schedule saving reminders (Repeating)
  Future<void> scheduleSavingReminder({
    required int id,
    required int intervalHours, // 1 or 6
  }) async {
    // Note: Periodic notifications in flutter_local_notifications are limited (Every Minute, Every Hour, Daily, etc.)
    // For custom intervals like 6 hours, we might need to schedule multiple daily ones or use WorkManager.
    // For now, let's use the closest native option: Hourly or Daily.
    
    RepeatInterval interval = intervalHours == 1 ? RepeatInterval.hourly : RepeatInterval.daily;

    await _notificationsPlugin.periodicallyShow(
      id: id,
      title: 'ได้เวลาออมเงินแล้ว!',
      body: 'อย่าลืมออมเงินตามแผนการเดินทางของคุณนะครับ',
      repeatInterval: interval,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'saving_reminder',
          'Saving Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Show an immediate notification (e.g. when first created and needs saving today)
  Future<void> showImmediateSavingReminder() async {
    await _notificationsPlugin.show(
      id: 101, // Different ID for immediate alert
      title: 'เริ่มออมเงินวันนี้!',
      body: 'คุณมีรายการออมเงินสำหรับทริปใหม่ที่ต้องทำวันนี้ครับ',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'saving_reminder_immediate',
          'Immediate Saving Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
