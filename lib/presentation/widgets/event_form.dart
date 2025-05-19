import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';

class EventForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedIcon;
  final Map<String, dynamic> notificationOptions;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<Map<String, dynamic>> onNotificationOptionsChanged;

  const EventForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedIcon,
    required this.notificationOptions,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onIconChanged,
    required this.onNotificationOptionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEventNameField(),
          const SizedBox(height: 16),
          _buildDateField(context),
          const SizedBox(height: 16),
          _buildTimeField(context),
          const SizedBox(height: 16),
          _buildIconField(context),
          const SizedBox(height: 16),
          _buildNotificationOptions(context),
          const SizedBox(height: 24),
          // _buildButtons(context), // إضافة الأزرار مباشرة في النموذج
        ],
      ),
    );
  }

  // Widget _buildButtons(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: CustomButton(
  //           text: "Cancel", // تغيير النص لكلمة واضحة
  //           isOutlined: true,
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: CustomButton(
  //           text: "Save", // تغيير النص لكلمة واضحة
  //           onPressed: () {
  //             if (formKey.currentState!.validate()) {
  //               Navigator.pop(context);
  //             }
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEventNameField() {
    return TextFormField(
      controller: titleController,
      decoration: const InputDecoration(
        labelText: AppStrings.eventName,
        hintText: AppStrings.enterEventName,
        prefixIcon: Icon(Icons.event),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.errorRequiredField;
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.date,
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat.yMMMMd().format(selectedDate)),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.time,
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );
  }

  Widget _buildIconField(BuildContext context) {
    final icons = ['❤️', '🎉', '🎂', '🏆', '✈️', '🎭', '🎓', '💼', '🏠', '🏋️'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.icon,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              icons.map((icon) {
                final isSelected = selectedIcon == icon;

                return GestureDetector(
                  onTap: () => onIconChanged(icon),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotificationOptions(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              contentPadding: EdgeInsets.zero,
              value: notificationOptions['enabled'] ?? true,
              onChanged: (value) {
                final updatedOptions = Map<String, dynamic>.from(
                  notificationOptions,
                );
                updatedOptions['enabled'] = value;
                onNotificationOptionsChanged(updatedOptions);
              },
            ),
            if (notificationOptions['enabled'] == true) ...[
              SwitchListTile(
                title: const Text('Reminder'),
                subtitle: const Text('Get notified before the event'),
                contentPadding: EdgeInsets.zero,
                value: notificationOptions['reminder'] ?? true,
                onChanged: (value) {
                  final updatedOptions = Map<String, dynamic>.from(
                    notificationOptions,
                  );
                  updatedOptions['reminder'] = value;
                  onNotificationOptionsChanged(updatedOptions);
                },
              ),
              if (notificationOptions['reminder'] == true) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Remind me before:'),
                ),
                Slider(
                  value:
                      (notificationOptions['reminderHours'] as int? ?? 24)
                          .toDouble(),
                  min: 1,
                  max: 72,
                  divisions: 71,
                  label: '${notificationOptions['reminderHours'] ?? 24} hours',
                  onChanged: (value) {
                    final updatedOptions = Map<String, dynamic>.from(
                      notificationOptions,
                    );
                    updatedOptions['reminderHours'] = value.toInt();
                    onNotificationOptionsChanged(updatedOptions);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1 hour'),
                      Text(
                        '${notificationOptions['reminderHours'] ?? 24} hours',
                      ),
                      const Text('72 hours'),
                    ],
                  ),
                ),
              ],
              SwitchListTile(
                title: const Text('Sound'),
                contentPadding: EdgeInsets.zero,
                value: notificationOptions['sound'] ?? true,
                onChanged: (value) {
                  final updatedOptions = Map<String, dynamic>.from(
                    notificationOptions,
                  );
                  updatedOptions['sound'] = value;
                  onNotificationOptionsChanged(updatedOptions);
                },
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                contentPadding: EdgeInsets.zero,
                value: notificationOptions['vibration'] ?? true,
                onChanged: (value) {
                  final updatedOptions = Map<String, dynamic>.from(
                    notificationOptions,
                  );
                  updatedOptions['vibration'] = value;
                  onNotificationOptionsChanged(updatedOptions);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      onTimeChanged(picked);
    }
  }
}
