import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/event_model.dart';
import '../cubit/event/event_cubit.dart';
import '../cubit/event/event_state.dart';
import '../widgets/event_form.dart';

class AddEditEventPage extends StatefulWidget {
  final EventModel? event;

  const AddEditEventPage({super.key, this.event});

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  late EventCubit _eventCubit;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedIcon;
  late Map<String, dynamic> _notificationOptions;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _eventCubit = GetIt.instance<EventCubit>();

    // Initialize controllers and values
    _titleController = TextEditingController();

    if (_isEditing) {
      _titleController.text = widget.event!.title;
      _selectedDate = widget.event!.date;

      // Parse the time string (assuming format like "6:30 PM")
      final timeComponents = widget.event!.time.split(':');
      int hour = int.parse(timeComponents[0]);
      final minuteSecond = timeComponents[1].split(' ');
      int minute = int.parse(minuteSecond[0]);
      final period = minuteSecond[1];

      // Handle AM/PM
      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      _selectedTime = TimeOfDay(hour: hour, minute: minute);
      _selectedIcon = widget.event!.icon;
      _notificationOptions = Map<String, dynamic>.from(
        widget.event!.notificationOptions,
      );
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedIcon = '❤️';
      _notificationOptions = {
        'enabled': true,
        'reminder': true,
        'reminderHours': 24,
        'sound': true,
        'vibration': true,
      };
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editEvent : AppStrings.addNewEvent),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider.value(
        value: _eventCubit,
        child: BlocListener<EventCubit, EventState>(
          listener: (context, state) {
            if (state is EventSaved) {
              Navigator.pop(context);
            } else if (state is EventError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: EventForm(
            formKey: _formKey,
            titleController: _titleController,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            selectedIcon: _selectedIcon,
            notificationOptions: _notificationOptions,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onTimeChanged: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
            onIconChanged: (icon) {
              setState(() {
                _selectedIcon = icon;
              });
            },
            onNotificationOptionsChanged: (options) {
              setState(() {
                _notificationOptions = options;
              });
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomButton(
                text: AppStrings.cancel,
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(text: AppStrings.save, onPressed: _saveEvent),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEvent() {
    try {
      if (_formKey.currentState!.validate()) {
        // Format time string
        final formattedTime = DateFormat('h:mm a').format(
          DateTime(2022, 1, 1, _selectedTime.hour, _selectedTime.minute),
        );

        if (_isEditing) {
          _eventCubit.updateEvent(
            id: widget.event!.id,
            title: _titleController.text,
            date: _selectedDate,
            time: formattedTime,
            icon: _selectedIcon,
            notificationOptions: _notificationOptions,
          );
        } else {
          _eventCubit.createEvent(
            title: _titleController.text,
            date: _selectedDate,
            time: formattedTime,
            icon: _selectedIcon,
            notificationOptions: _notificationOptions,
          );
        }
      }
    } catch (e) {
      print("Error saving event: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    }
  }
}
