import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/app_strings.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';
import 'notification_settings_page.dart';

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
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text(AppStrings.notifications),
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
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text(AppStrings.theme),
                    trailing: Switch(
                      value: state.darkMode,
                      onChanged: (value) {
                        _settingsCubit.toggleDarkMode(value);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text(AppStrings.dateTime),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to date & time settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text(AppStrings.about),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to about page
                    },
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
