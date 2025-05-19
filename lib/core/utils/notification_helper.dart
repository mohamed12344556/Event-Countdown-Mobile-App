// import 'dart:io';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// abstract class NotificationHelper {
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   });
// }

// class NotificationHelperImpl implements NotificationHelper {
//   final FlutterLocalNotificationsPlugin notificationPlugin;

//   NotificationHelperImpl({required this.notificationPlugin});

//   @override
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     try {
//       print("Scheduling notification: $title at $scheduledDate");

//       // التأكد من أن التاريخ في المستقبل
//       final now = DateTime.now();
//       if (scheduledDate.isBefore(now)) {
//         print("Error: Cannot schedule notification in the past");
//         return;
//       }

//       // تحويل DateTime إلى TZDateTime
//       final scheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

//       // تعريف تفاصيل الإشعار لنظام أندرويد
//       const androidDetails = AndroidNotificationDetails(
//         'event_countdown_channel', // معرف القناة
//         'Event Countdown', // اسم القناة
//         channelDescription: 'Notifications for event countdowns', // وصف القناة
//         importance: Importance.high, // أهمية عالية
//         priority: Priority.high, // أولوية عالية
//         playSound: true, // تشغيل صوت
//         enableVibration: true, // تمكين الاهتزاز
//         // ضبط أيقونة الإشعار (اختياري)
//         icon: '@mipmap/ic_launcher',
//       );

//       // تعريف تفاصيل الإشعار لنظام iOS
//       const iOSDetails = DarwinNotificationDetails(
//         presentAlert: true, // عرض التنبيه
//         presentBadge: true, // عرض الشارة
//         presentSound: true, // تشغيل الصوت
//       );

//       // دمج التفاصيل لكل الأنظمة
//       const notificationDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iOSDetails,
//       );

//       // جدولة الإشعار باستخدام الخيارات المناسبة لإصدار المكتبة
//       if (Platform.isAndroid) {
//         try {
//           // نحاول أولاً جدولة إشعار دقيق (على أندرويد)
//           await notificationPlugin.zonedSchedule(
//             id,
//             title,
//             body,
//             scheduleTime,
//             notificationDetails,
//             androidScheduleMode: AndroidScheduleMode.exact,
//             // androidAllowWhileIdle: true, // يسمح بالعمل أثناء وضع السكون (للإصدارات القديمة)
//           );
//           print(
//             "✅ Notification scheduled successfully (with allow-while-idle)",
//           );
//         } catch (exactError) {
//           print("❌ Exact scheduling failed: $exactError");

//           try {
//             // محاولة بخيارات مختلفة
//             await notificationPlugin.zonedSchedule(
//               id,
//               title,
//               body,
//               scheduleTime,
//               notificationDetails,
//               androidScheduleMode: AndroidScheduleMode.inexact,
//             );
//             print("✅ Notification scheduled successfully (basic)");
//           } catch (e) {
//             print("❌ Basic scheduling also failed: $e");

//             // محاولة بإشعار غير مجدول (فوري) كملاذ أخير
//             await notificationPlugin.show(id, title, body, notificationDetails);
//             print("⚠️ Immediate notification shown instead of scheduled");
//           }
//         }
//       } else if (Platform.isIOS) {
//         // على iOS، الأمر أبسط
//         await notificationPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduleTime,
//           notificationDetails,
//           androidScheduleMode: AndroidScheduleMode.exact,
//         );
//         print("✅ iOS notification scheduled successfully");
//       }
//     } catch (e) {
//       print("❌ Error scheduling notification: $e");
//       rethrow; // إعادة رفع الاستثناء للمعالجة في المستوى الأعلى
//     }
//   }
// }

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../errors/exceptions.dart';

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
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        print("Error: Cannot schedule notification in the past");
        return;
      }

      // التحقق من أذونات الإشعارات على Android 13+
      if (Platform.isAndroid) {
        final permissionGranted = await _checkNotificationPermission();
        if (!permissionGranted) {
          print(
            "❌ Notification permission not granted. Cannot schedule notification.",
          );
          throw NotificationException();
        }
      }

      // تحويل DateTime إلى TZDateTime
      final scheduleTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // تعريف تفاصيل الإشعار لنظام أندرويد
      const androidDetails = AndroidNotificationDetails(
        'event_countdown_channel', // معرف القناة
        'Event Countdown', // اسم القناة
        channelDescription: 'Notifications for event countdowns', // وصف القناة
        importance: Importance.high, // أهمية عالية
        priority: Priority.high, // أولوية عالية
        playSound: true, // تشغيل صوت
        enableVibration: true, // تمكين الاهتزاز
        // ضبط أيقونة الإشعار
        icon: '@mipmap/ic_launcher',
      );

      // تعريف تفاصيل الإشعار لنظام iOS
      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true, // عرض التنبيه
        presentBadge: true, // عرض الشارة
        presentSound: true, // تشغيل الصوت
      );

      // دمج التفاصيل لكل الأنظمة
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // جدولة الإشعار حسب نظام التشغيل
      if (Platform.isAndroid) {
        await _scheduleAndroidNotification(
          id: id,
          title: title,
          body: body,
          scheduleTime: scheduleTime,
          notificationDetails: notificationDetails,
        );
      } else if (Platform.isIOS) {
        await _scheduleIOSNotification(
          id: id,
          title: title,
          body: body,
          scheduleTime: scheduleTime,
          notificationDetails: notificationDetails,
        );
      }
    } catch (e) {
      print("❌ Error scheduling notification: $e");
      rethrow; // إعادة رفع الاستثناء للمعالجة في المستوى الأعلى
    }
  }

  // التحقق من أذونات الإشعارات
  Future<bool> _checkNotificationPermission() async {
    try {
      // التحقق من إصدار Android
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final int sdkVersion = androidInfo.version.sdkInt;

      print(
        "Checking notification permission for Android SDK version: $sdkVersion",
      );

      // في Android 13 (API 33) وما بعده، نحتاج إلى إذن صريح
      if (sdkVersion >= 33) {
        final status = await Permission.notification.status;
        final isGranted = status.isGranted;

        print(
          "Notification permission status: ${isGranted ? 'GRANTED' : 'DENIED'}",
        );
        return isGranted;
      } else {
        // الإصدارات الأقدم تمنح الإذن تلقائيًا
        print(
          "Using Android version < 13, notification permission is granted by default",
        );
        return true;
      }
    } catch (e) {
      print("❌ Error checking notification permission: $e");
      // في حالة حدوث خطأ أثناء التحقق من الإذن، نفترض أن الإذن ممنوح
      // هذا لضمان استمرار التطبيق في العمل إذا فشل التحقق من الإذن
      return true;
    }
  }

  // جدولة الإشعار على Android مع استراتيجية المحاولات المتعددة
  Future<void> _scheduleAndroidNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduleTime,
    required NotificationDetails notificationDetails,
  }) async {
    // طريقة 1: استخدام الوضع الدقيق (Exact)
    try {
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      print("✅ Android notification scheduled successfully (exact mode)");
      return;
    } catch (exactError) {
      print("❌ Exact scheduling failed: $exactError");
    }

    // طريقة 2: استخدام الوضع غير الدقيق (Inexact) كخطة بديلة
    try {
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
      print("✅ Android notification scheduled successfully (inexact mode)");
      return;
    } catch (inexactError) {
      print("❌ Inexact scheduling also failed: $inexactError");
    }

    // طريقة 3: إظهار إشعار فوري كملاذ أخير
    try {
      await notificationPlugin.show(id, title, body, notificationDetails);
      print("⚠️ Immediate notification shown instead of scheduled");
      return;
    } catch (showError) {
      print("❌ All notification methods failed");
      throw NotificationException();
    }
  }

  // جدولة الإشعار على iOS
  Future<void> _scheduleIOSNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduleTime,
    required NotificationDetails notificationDetails,
  }) async {
    try {
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduleTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      print("✅ iOS notification scheduled successfully");
    } catch (e) {
      print("❌ iOS notification scheduling failed: $e");
      throw NotificationException();
    }
  }
}
