import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;  

import 'core/constants/app_themes.dart';
import 'injection_container.dart' as di;
import 'presentation/pages/event_list_page.dart';

Future<void> requestNotificationPermissions() async {
  if (Platform.isAndroid) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final permissionGranted =
        await androidPlugin?.areNotificationsEnabled() ?? false;
    if (!permissionGranted) {
      print("Notification permissions are not granted on Android.");
    }
  } else if (Platform.isIOS) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

// Future<void> checkNotificationPermissions(
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
// ) async {
//   final androidPlugin =
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >();
//   final permissionGranted =
//       await androidPlugin?.areNotificationsEnabled() ?? false;
//   print("Notification permissions granted: $permissionGranted");
// }
Future<void> checkAndRequestNotificationPermissions() async {
  if (Platform.isAndroid) {
    // التحقق من إصدار Android
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    int? androidVersion = androidInfo.version.sdkInt;
    print("إصدار Android: $androidVersion (API Level)");

    if (androidVersion >= 33) {
      // طلب إذن الإشعارات على Android 13+
      final status = await Permission.notification.request();
      print(
        "حالة أذونات الإشعارات: ${status.isGranted ? 'ممنوحة' : 'غير ممنوحة'}",
      );
    } else {
      // الإذن ممنوح تلقائيًا على الإصدارات الأقدم
      print("أذونات الإشعارات ممنوحة تلقائيًا على Android <13");
    }
  } else if (Platform.isIOS) {
    // طلب الأذونات على iOS
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  // Initialize dependency injection
  await di.init();

  // Initialize notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // تحقق من إصدار Android وأذونات الإشعارات
  await checkAndRequestNotificationPermissions();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Countdown',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const EventListPage(),
    );
  }
}
