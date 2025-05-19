import '../datasources/remote/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  Future<void> scheduleNotification(NotificationModel notification) async {
    await remoteDataSource.scheduleNotification(notification);
  }

  Future<void> scheduleAlternativeNotification(
    NotificationModel notification,
  ) async {
    await remoteDataSource.scheduleNotificationInexact(notification);
  }

  Future<void> showImmediateNotification(NotificationModel notification) async {
    await remoteDataSource.showImmediateNotification(notification);
  }

  Future<void> cancelNotification(int id) async {
    await remoteDataSource.cancelNotification(id);
  }

  Future<void> cancelAllNotifications() async {
    await remoteDataSource.cancelAllNotifications();
  }
}
