import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;

import 'core/utils/notification_helper.dart';
import 'data/datasources/local/event_local_datasource.dart';
import 'data/datasources/remote/notification_remote_datasource.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'presentation/cubit/event/event_cubit.dart';
import 'presentation/cubit/settings/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Cubits
  getIt.registerFactory(
    () => EventCubit(eventRepository: getIt(), notificationRepository: getIt()),
  );

  getIt.registerFactory(() => SettingsCubit(preferences: getIt()));

  // Repositories
  getIt.registerLazySingleton<EventRepositoryImpl>(
    () => EventRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerLazySingleton<NotificationRepositoryImpl>(
    () => NotificationRepositoryImpl(remoteDataSource: getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(database: getIt()),
  );

  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      notificationPlugin: getIt(),
      notificationHelper: getIt(),
    ),
  );

  // Utils
  getIt.registerLazySingleton<NotificationHelper>(
    () => NotificationHelperImpl(notificationPlugin: getIt()),
  );

  // External
  final database = await openDatabase(
    join(await getDatabasesPath(), 'event_countdown.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE events(id TEXT PRIMARY KEY, title TEXT, date TEXT, time TEXT, icon TEXT, notificationOptions TEXT)',
      );
    },
    version: 1,
  );

  getIt.registerLazySingleton<Database>(() => database);

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  final notificationPlugin = FlutterLocalNotificationsPlugin();
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => notificationPlugin,
  );

  final localTimezone = tz.local.name;
  print("Local timezone: $localTimezone");
  getIt.registerLazySingleton<String>(
    () => localTimezone,
    instanceName: 'local_timezone',
  );

  print("Dependencies initialized successfully!");
}
