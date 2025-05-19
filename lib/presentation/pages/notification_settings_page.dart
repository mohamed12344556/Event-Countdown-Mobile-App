import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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

  @override
  void initState() {
    super.initState();
    _settingsCubit = GetIt.instance<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notifications)),
      body: BlocProvider.value(
        value: _settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              return ListView(
                children: [
                  SwitchListTile(
                    title: const Text(AppStrings.enableNotifications),
                    subtitle: const Text(
                      'Receive push notifications for events',
                    ),
                    value: state.notificationsEnabled,
                    onChanged: (value) {
                      _settingsCubit.toggleNotifications(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text(AppStrings.sound),
                    subtitle: const Text('Play sound with notifications'),
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
                    subtitle: const Text('Vibrate with notifications'),
                    value: state.vibrationEnabled,
                    onChanged:
                        state.notificationsEnabled
                            ? (value) {
                              _settingsCubit.toggleVibration(value);
                            }
                            : null,
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
