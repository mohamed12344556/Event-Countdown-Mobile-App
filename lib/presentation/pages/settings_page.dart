import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/app_strings.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';
// استيراد الصفحات الجديدة (سيتم إنشاؤها)
import 'about_page.dart';
import 'date_time_settings_page.dart';
import 'notification_settings_page.dart';
// import 'theme_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = GetIt.instance<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: BlocProvider.value(
        value: _settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              return ListView(
                children: [
                  // قسم الإشعارات
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text(AppStrings.notifications),
                    subtitle: Text(
                      state.notificationsEnabled ? 'Enabled' : 'Disabled',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),

                  // قسم السمة (Theme)
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text(AppStrings.theme),
                    subtitle: Text(state.darkMode ? 'Dark Mode' : 'Light Mode'),
                    trailing: Switch(
                      value: state.darkMode,
                      onChanged: (value) {
                        _settingsCubit.toggleDarkMode(value);
                      },
                    ),
                    onTap: () {
                      _showThemeModeDialog(context, state);
                    },
                  ),

                  // قسم التاريخ والوقت
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text(AppStrings.dateTime),
                    subtitle: const Text('Configure date and time formats'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DateTimeSettingsPage(),
                        ),
                      );
                    },
                  ),

                  // قسم حول التطبيق
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text(AppStrings.about),
                    subtitle: const Text('App info and developer details'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),

                  // قسم جديد - نسخة التطبيق
                  const ListTile(
                    leading: Icon(Icons.verified),
                    title: Text('App Version'),
                    subtitle: Text('1.0.0 (Build 1)'),
                    enabled: false,
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

  // حوار لاختيار وضع السمة (Light/Dark/System)
  void _showThemeModeDialog(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<bool>(
                title: const Text('Light Mode'),
                value: false,
                groupValue: state.darkMode,
                onChanged: (value) {
                  if (value != null) {
                    _settingsCubit.toggleDarkMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<bool>(
                title: const Text('Dark Mode'),
                value: true,
                groupValue: state.darkMode,
                onChanged: (value) {
                  if (value != null) {
                    _settingsCubit.toggleDarkMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
