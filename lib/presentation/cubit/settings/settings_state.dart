import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkMode;
  final String theme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String dateFormat;
  final String timeFormat;

  const SettingsLoaded({
    required this.darkMode,
    required this.theme,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.dateFormat = 'MMM d, yyyy', // القيمة الافتراضية
    this.timeFormat = 'h:mm a', // القيمة الافتراضية
  });

  @override
  List<Object> get props => [
    darkMode,
    theme,
    notificationsEnabled,
    soundEnabled,
    vibrationEnabled,
    dateFormat,
    timeFormat,
  ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object> get props => [message];
}
