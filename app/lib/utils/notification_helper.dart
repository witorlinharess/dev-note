import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // initialize timezone package
    tzdata.initializeTimeZones();
    try {
      final String localTz = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // fallback to UTC if timezone cannot be determined
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (response) {
      // handle notification tap if needed
      if (kDebugMode) {
        // ignore: avoid_print
        print('Notification tapped: ${response.payload}');
      }
    });

    // create Android notification channel (ensures heads-up/high importance)
    try {
      const channel = AndroidNotificationChannel('reminders_channel', 'Lembretes', description: 'Notificações de lembretes', importance: Importance.max);
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    } catch (_) {}

    // request iOS permissions explicitly and try to enable foreground presentation
    try {
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  /// Schedules a notification at [dateTime] (in local timezone).
  /// If [dateTime] is null or in the past, the notification is shown immediately.
  /// [id] should be a unique integer for the notification.
  static Future<void> scheduleNotification({required int id, required String title, String? body, DateTime? dateTime, String? payload}) async {
    final androidDetails = AndroidNotificationDetails('reminders_channel', 'Lembretes', channelDescription: 'Notificações de lembretes', importance: Importance.max, priority: Priority.high, playSound: true);
    final iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (dateTime == null) {
      await _plugin.show(id, title, body, details, payload: payload);
      return;
    }

    try {
      final tzDate = tz.TZDateTime.from(dateTime, tz.local);
      if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
        // if in the past, show immediately
        await _plugin.show(id, title, body, details, payload: payload);
        return;
      }

  await _plugin.zonedSchedule(id, title, body, tzDate, details, payload: payload, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to schedule zoned notification: $e. Falling back to immediate show.');
      }
      try {
        await _plugin.show(id, title, body, details, payload: payload);
      } catch (_) {}
    }
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Shows a notification immediately (useful when app is in foreground).
  static Future<void> showNotification({required int id, required String title, String? body, String? payload}) async {
    final androidDetails = AndroidNotificationDetails('reminders_channel', 'Lembretes', channelDescription: 'Notificações de lembretes', importance: Importance.max, priority: Priority.high, playSound: true);
    final iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to show notification immediately: $e');
      }
    }
  }
}
