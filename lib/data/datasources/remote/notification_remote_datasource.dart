import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../../../core/errors/exceptions.dart';
import '../../../core/utils/notification_helper.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Schedules a notification
  /// 
  /// Throws [NotificationException] if scheduling fails
  Future<void> scheduleNotification(NotificationModel notification);

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
      await notificationHelper.scheduleNotification(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: notification.scheduledDate,
      );
    } catch (e) {
      throw NotificationException();
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await notificationPlugin.cancel(id);
    } catch (e) {
      throw NotificationException();
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await notificationPlugin.cancelAll();
    } catch (e) {
      throw NotificationException();
    }
  }
}