import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationHelper {
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });
}

class NotificationHelperImpl implements NotificationHelper {
  final FlutterLocalNotificationsPlugin notificationPlugin;

  NotificationHelperImpl({required this.notificationPlugin});

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      print("Scheduling notification: $title at $scheduledDate");

      // التأكد من أن التاريخ في المستقبل
      if (scheduledDate.isBefore(DateTime.now())) {
        print("Error: Cannot schedule notification in the past");
        return;
      }

      // تحويل DateTime إلى TZDateTime
      final scheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_countdown_channel',
            'Event Countdown',
            channelDescription: 'Notifications for event countdowns',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // استخدام القيم المناسبة لإصدار المكتبة
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // للإصدارات القديمة
        // Removed uiLocalNotificationDateInterpretation as it is not supported
      );
      print("Notification scheduled successfully");
    } catch (e) {
      print("Error scheduling notification: $e");
      rethrow;
    }
  }
}

// تعريف enum إذا لم يكن متوفرًا في الحزمة الحالية
enum UILocalNotificationDateInterpretation { absoluteTime, wallClockTime }
