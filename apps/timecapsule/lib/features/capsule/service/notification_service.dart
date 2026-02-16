import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleUnlockNotification({
    required String capsuleId,
    required String title,
    required DateTime unlockAt,
  }) async {
    final id = capsuleId.hashCode.abs() % 2147483647;
    await _notifications.zonedSchedule(
      id,
      '🔓 时间胶囊已解锁',
      '"$title" — 来自过去的你写了一封信，现在可以打开了',
      tz.TZDateTime.from(unlockAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'capsule_unlock',
          '胶囊解锁通知',
          channelDescription: '当时间胶囊到达解锁日期时通知您',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(String capsuleId) async {
    final id = capsuleId.hashCode.abs() % 2147483647;
    await _notifications.cancel(id);
  }
}
