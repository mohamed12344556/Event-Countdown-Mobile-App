import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';

class DateTimeSettingsPage extends StatefulWidget {
  const DateTimeSettingsPage({super.key});

  @override
  State<DateTimeSettingsPage> createState() => _DateTimeSettingsPageState();
}

class _DateTimeSettingsPageState extends State<DateTimeSettingsPage> {
  late SettingsCubit _settingsCubit;
  String _selectedDateFormat = 'MMM d, yyyy'; // Default format
  String _selectedTimeFormat = 'h:mm a'; // Default format

  // Possible date format options
  final List<Map<String, String>> _dateFormats = [
    {'format': 'MMM d, yyyy', 'example': 'Jan 1, 2023'},
    {'format': 'MMMM d, yyyy', 'example': 'January 1, 2023'},
    {'format': 'yyyy-MM-dd', 'example': '2023-01-01'},
    {'format': 'd/M/yyyy', 'example': '1/1/2023'},
    {'format': 'dd/MM/yyyy', 'example': '01/01/2023'},
  ];

  // Possible time format options
  final List<Map<String, String>> _timeFormats = [
    {'format': 'h:mm a', 'example': '3:30 PM'},
    {'format': 'HH:mm', 'example': '15:30'},
    {'format': 'h:mm:ss a', 'example': '3:30:00 PM'},
    {'format': 'HH:mm:ss', 'example': '15:30:00'},
  ];

  @override
  void initState() {
    super.initState();
    _settingsCubit = GetIt.instance<SettingsCubit>();
    _loadSavedFormats();
  }

  void _loadSavedFormats() {
    if (_settingsCubit.state is SettingsLoaded) {
      final state = _settingsCubit.state as SettingsLoaded;
      
      // يمكنك إضافة هذه الخصائص إلى SettingsState
      // _selectedDateFormat = state.dateFormat;
      // _selectedTimeFormat = state.timeFormat;
      
      // ولكن حاليًا سنستخدم القيم الافتراضية
      setState(() {
        _selectedDateFormat = 'MMM d, yyyy';
        _selectedTimeFormat = 'h:mm a';
      });
    }
  }

  Future<void> _saveDateFormat(String format) async {
    setState(() {
      _selectedDateFormat = format;
    });
    
    // إضافة طريقة لحفظ صيغة التاريخ في SettingsCubit
    // await _settingsCubit.setDateFormat(format);
  }

  Future<void> _saveTimeFormat(String format) async {
    setState(() {
      _selectedTimeFormat = format;
    });
    
    // إضافة طريقة لحفظ صيغة الوقت في SettingsCubit
    // await _settingsCubit.setTimeFormat(format);
  }

  String _formatCurrentDateTime(String format) {
    final now = DateTime.now();
    return DateFormat(format).format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dateTime)),
      body: BlocProvider.value(
        value: _settingsCubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SettingsLoaded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Date Format Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Format',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current date: ${_formatCurrentDateTime(_selectedDateFormat)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          ..._dateFormats.map((format) => RadioListTile<String>(
                                title: Text(format['example']!),
                                subtitle: Text(format['format']!),
                                value: format['format']!,
                                groupValue: _selectedDateFormat,
                                onChanged: (value) {
                                  if (value != null) {
                                    _saveDateFormat(value);
                                  }
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Time Format Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Format',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current time: ${_formatCurrentDateTime(_selectedTimeFormat)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          ..._timeFormats.map((format) => RadioListTile<String>(
                                title: Text(format['example']!),
                                subtitle: Text(format['format']!),
                                value: format['format']!,
                                groupValue: _selectedTimeFormat,
                                onChanged: (value) {
                                  if (value != null) {
                                    _saveTimeFormat(value);
                                  }
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  // Note section
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'These settings only affect how dates and times are displayed in the app. They do not change your device system settings.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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