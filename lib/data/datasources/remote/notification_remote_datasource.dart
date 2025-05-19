import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/errors/exceptions.dart';
import '../../../core/utils/notification_helper.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Schedules a notification
  ///
  /// Throws [NotificationException] if scheduling fails
  Future<void> scheduleNotification(NotificationModel notification);

  /// Schedules a notification using alternative (inexact) method
  ///
  /// Throws [NotificationException] if scheduling fails
  Future<void> scheduleNotificationInexact(NotificationModel notification);

  /// Shows an immediate notification
  ///
  /// Throws [NotificationException] if showing fails
  Future<void> showImmediateNotification(NotificationModel notification);

  /// Cancels a notification by its ID
  Future<void> cancelNotification(int id);

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FlutterLocalNotificationsPlugin notificationPlugin;
  final NotificationHelper notificationHelper;

  NotificationRemoteDataSourceImpl({
    required this.notificationPlugin,
    required this.notificationHelper,
  });

  @override
  Future<void> scheduleNotification(NotificationModel notification) async {
    try {
      print(
        "Attempting to schedule notification with helper: ID: ${notification.id}, Time: ${notification.scheduledDate}",
      );
      await notificationHelper.scheduleNotification(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: notification.scheduledDate,
      );
      print("✓ Schedule notification completed successfully");
    } catch (e) {
      print("❌ Error in scheduleNotification: $e");
      throw NotificationException();
    }
  }

  @override
  Future<void> scheduleNotificationInexact(
    NotificationModel notification,
  ) async {
    try {
      print(
        "Attempting to schedule inexact notification: ID: ${notification.id}, Time: ${notification.scheduledDate}",
      );

      // تكوين تفاصيل الإشعار
      const androidDetails = AndroidNotificationDetails(
        'event_countdown_channel',
        'Event Countdown',
        channelDescription: 'Notifications for event countdowns',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // جدولة الإشعار باستخدام وضع غير دقيق
      await notificationPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );

      print("✓ Inexact notification scheduled successfully");
    } catch (e) {
      print("❌ Error in scheduleNotificationInexact: $e");
      throw NotificationException();
    }
  }

  @override
  Future<void> showImmediateNotification(NotificationModel notification) async {
    try {
      print(
        "Attempting to show immediate notification: ID: ${notification.id}",
      );

      // تكوين تفاصيل الإشعار
      const androidDetails = AndroidNotificationDetails(
        'event_countdown_channel',
        'Event Countdown',
        channelDescription: 'Notifications for event countdowns',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // عرض إشعار فوري
      await notificationPlugin.show(
        notification.id,
        notification.title,
        notification.body,
        notificationDetails,
      );

      print("✓ Immediate notification shown successfully");
    } catch (e) {
      print("❌ Error in showImmediateNotification: $e");
      throw NotificationException();
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      print("Cancelling notification with ID: $id");
      await notificationPlugin.cancel(id);
      print("✓ Notification cancelled successfully");
    } catch (e) {
      print("❌ Error in cancelNotification: $e");
      throw NotificationException();
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      print("Cancelling all notifications");
      await notificationPlugin.cancelAll();
      print("✓ All notifications cancelled successfully");
    } catch (e) {
      print("❌ Error in cancelAllNotifications: $e");
      throw NotificationException();
    }
  }
}
