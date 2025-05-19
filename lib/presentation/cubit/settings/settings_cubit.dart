import 'package:event_countdown_mobile_app/presentation/cubit/settings/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences preferences;

  SettingsCubit({required this.preferences}) : super(SettingsInitial()) {
    loadSettings();
  }

  // Future<void> loadSettings() async {
  //   emit(SettingsLoading());
  //   try {
  //     final darkMode = preferences.getBool('darkMode') ?? false;
  //     final theme = preferences.getString('theme') ?? 'default';
  //     final notificationsEnabled =
  //         preferences.getBool('notificationsEnabled') ?? true;
  //     final soundEnabled = preferences.getBool('soundEnabled') ?? true;
  //     final vibrationEnabled = preferences.getBool('vibrationEnabled') ?? true;

  //     emit(
  //       SettingsLoaded(
  //         darkMode: darkMode,
  //         theme: theme,
  //         notificationsEnabled: notificationsEnabled,
  //         soundEnabled: soundEnabled,
  //         vibrationEnabled: vibrationEnabled,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(const SettingsError(message: 'Failed to load settings'));
  //   }
  // }

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final darkMode = preferences.getBool('darkMode') ?? false;
      final theme = preferences.getString('theme') ?? 'default';
      final notificationsEnabled =
          preferences.getBool('notificationsEnabled') ?? true;
      final soundEnabled = preferences.getBool('soundEnabled') ?? true;
      final vibrationEnabled = preferences.getBool('vibrationEnabled') ?? true;
      final dateFormat = preferences.getString('dateFormat') ?? 'MMM d, yyyy';
      final timeFormat = preferences.getString('timeFormat') ?? 'h:mm a';

      emit(
        SettingsLoaded(
          darkMode: darkMode,
          theme: theme,
          notificationsEnabled: notificationsEnabled,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          dateFormat: dateFormat,
          timeFormat: timeFormat,
        ),
      );
    } catch (e) {
      emit(const SettingsError(message: 'Failed to load settings'));
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setBool('darkMode', value);

        emit(
          SettingsLoaded(
            darkMode: value,
            theme: currentState.theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: currentState.vibrationEnabled,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to toggle dark mode'));
      }
    }
  }

  Future<void> setTheme(String theme) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setString('theme', theme);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: currentState.vibrationEnabled,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to set theme'));
      }
    }
  }

  Future<void> toggleNotifications(bool value) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setBool('notificationsEnabled', value);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: currentState.theme,
            notificationsEnabled: value,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: currentState.vibrationEnabled,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to toggle notifications'));
      }
    }
  }

  Future<void> toggleSound(bool value) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setBool('soundEnabled', value);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: currentState.theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: value,
            vibrationEnabled: currentState.vibrationEnabled,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to toggle sound'));
      }
    }
  }

  Future<void> toggleVibration(bool value) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setBool('vibrationEnabled', value);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: currentState.theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: value,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to toggle vibration'));
      }
    }
  }

  Future<void> setDateFormat(String format) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setString('dateFormat', format);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: currentState.theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: currentState.vibrationEnabled,
            dateFormat: format,
            timeFormat: currentState.timeFormat,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to set date format'));
      }
    }
  }

  Future<void> setTimeFormat(String format) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await preferences.setString('timeFormat', format);

        emit(
          SettingsLoaded(
            darkMode: currentState.darkMode,
            theme: currentState.theme,
            notificationsEnabled: currentState.notificationsEnabled,
            soundEnabled: currentState.soundEnabled,
            vibrationEnabled: currentState.vibrationEnabled,
            dateFormat: currentState.dateFormat,
            timeFormat: format,
          ),
        );
      } catch (e) {
        emit(const SettingsError(message: 'Failed to set time format'));
      }
    }
  }
}
