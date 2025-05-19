import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_strings.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late SettingsCubit _settingsCubit;
  int? _androidVersion;
  bool _isCheckingPermissions = false;
  String _permissionStatus = '';

  @override
  void initState() {
    super.initState();
    _settingsCubit = GetIt.instance<SettingsCubit>();

    if (Platform.isAndroid) {
      _checkAndroidVersion();
    }
  }

  // التحقق من إصدار Android
  Future<void> _checkAndroidVersion() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      setState(() {
        _androidVersion = androidInfo.version.sdkInt;
      });

      print('إصدار Android: $_androidVersion (API Level)');

      // تحقق من حالة الأذونات إذا كان الإصدار 33 أو أعلى (Android 13+)
      if (_androidVersion != null && _androidVersion! >= 33) {
        _checkNotificationPermissions();
      }
    } catch (e) {
      print('خطأ في التحقق من إصدار Android: $e');
    }
  }

  // التحقق من حالة أذونات الإشعارات
  Future<void> _checkNotificationPermissions() async {
    if (!Platform.isAndroid ||
        _androidVersion == null ||
        _androidVersion! < 33) {
      return;
    }

    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      final permissionStatus = await Permission.notification.status;

      setState(() {
        _permissionStatus =
            permissionStatus.isGranted
                ? AppStrings.permissionGranted
                : (permissionStatus.isPermanentlyDenied
                    ? AppStrings.permissionPermanentlyDenied
                    : AppStrings.permissionDenied);
        _isCheckingPermissions = false;
      });

      print('حالة أذونات الإشعارات: $_permissionStatus');
    } catch (e) {
      setState(() {
        _permissionStatus = AppStrings.permissionCheckError;
        _isCheckingPermissions = false;
      });
      print('خطأ في التحقق من أذونات الإشعارات: $e');
    }
  }

  // طلب أذونات الإشعارات
  Future<void> _requestNotificationPermissions() async {
    if (!Platform.isAndroid ||
        _androidVersion == null ||
        _androidVersion! < 33) {
      return;
    }

    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      final status = await Permission.notification.request();

      setState(() {
        _permissionStatus =
            status.isGranted
                ? AppStrings.permissionGranted
                : (status.isPermanentlyDenied
                    ? AppStrings.permissionPermanentlyDenied
                    : AppStrings.permissionDenied);
        _isCheckingPermissions = false;
      });

      print('نتيجة طلب الأذونات: ${status.isGranted ? 'ممنوحة' : 'مرفوضة'}');

      // تحديث حالة تمكين الإشعارات في الإعدادات
      if (status.isGranted) {
        _settingsCubit.toggleNotifications(true);
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog();
      }
    } catch (e) {
      setState(() {
        _permissionStatus = AppStrings.permissionRequestError;
        _isCheckingPermissions = false;
      });
      print('خطأ في طلب أذونات الإشعارات: $e');
    }
  }

  // عرض حوار فتح الإعدادات
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.notificationPermissions),
            content: const Text(
              AppStrings.notificationPermissionPermanentlyDenied,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.later),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text(AppStrings.openSettings),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notifications)),
      body: BlocProvider.value(
        value: _settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading || _isCheckingPermissions) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              return ListView(
                children: [
                  // بطاقة حالة أذونات الإشعارات (تظهر فقط على Android 13+)
                  if (Platform.isAndroid &&
                      _androidVersion != null &&
                      _androidVersion! >= 33)
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  state.notificationsEnabled &&
                                          _permissionStatus ==
                                              AppStrings.permissionGranted
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  color:
                                      state.notificationsEnabled &&
                                              _permissionStatus ==
                                                  AppStrings.permissionGranted
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppStrings.notificationPermissions,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _permissionStatus.isNotEmpty
                                  ? _permissionStatus
                                  : AppStrings.permissionStatusUnknown,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            if (_permissionStatus !=
                                AppStrings.permissionGranted)
                              ElevatedButton(
                                onPressed: _requestNotificationPermissions,
                                child: Text(
                                  _permissionStatus ==
                                          AppStrings.permissionPermanentlyDenied
                                      ? AppStrings.openSettings
                                      : AppStrings.requestPermissions,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // إعدادات الإشعارات
                  SwitchListTile(
                    title: const Text(AppStrings.enableNotifications),
                    subtitle: const Text(AppStrings.notificationsSubtitle),
                    value: state.notificationsEnabled,
                    onChanged: (value) {
                      // إذا كان المستخدم يحاول تفعيل الإشعارات على Android 13+ ولم يتم منح الإذن
                      if (value &&
                          Platform.isAndroid &&
                          _androidVersion != null &&
                          _androidVersion! >= 33 &&
                          _permissionStatus != AppStrings.permissionGranted) {
                        _requestNotificationPermissions();
                      } else {
                        _settingsCubit.toggleNotifications(value);
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text(AppStrings.sound),
                    subtitle: const Text(AppStrings.soundSubtitle),
                    value: state.soundEnabled,
                    onChanged:
                        state.notificationsEnabled
                            ? (value) {
                              _settingsCubit.toggleSound(value);
                            }
                            : null,
                  ),
                  SwitchListTile(
                    title: const Text(AppStrings.vibration),
                    subtitle: const Text(AppStrings.vibrationSubtitle),
                    value: state.vibrationEnabled,
                    onChanged:
                        state.notificationsEnabled
                            ? (value) {
                              _settingsCubit.toggleVibration(value);
                            }
                            : null,
                  ),

                  // معلومات إضافية
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      AppStrings.notificationNote,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is SettingsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
