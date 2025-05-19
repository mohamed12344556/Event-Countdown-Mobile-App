import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/models/event_model.dart';
import '../cubit/event/event_cubit.dart';
import '../cubit/event/event_state.dart';
import '../widgets/event_card.dart';
import 'add_edit_event_page.dart';
import 'settings_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late EventCubit _eventCubit;

  @override
  void initState() {
    super.initState();
    _eventCubit = GetIt.instance<EventCubit>();
    _eventCubit.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Countdown',
        ), // Using hardcoded string instead of AppStrings for simplicity
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _eventCubit,
        child: BlocBuilder<EventCubit, EventState>(
          builder: (context, state) {
            if (state is EventsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EventsLoaded) {
              final events = state.events;

              if (events.isEmpty) {
                return const Center(
                  child: Text('No events yet', style: TextStyle(fontSize: 18)),
                );
              }

              // Sort events by date
              events.sort((a, b) {
                final aDateTime = _parseEventDateTime(a);
                final bDateTime = _parseEventDateTime(b);
                return aDateTime.compareTo(bDateTime);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => _navigateToEditEvent(event),
                    onDelete: () => _showDeleteConfirmation(event),
                  );
                },
              );
            } else if (state is EventError) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditEventPage()),
    );
    // تحديث القائمة بعد العودة
    _eventCubit.getEvents();
  }

  void _navigateToEditEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditEventPage(event: event)),
    );
  }

  void _showDeleteConfirmation(EventModel event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: Text('Are you sure you want to delete "${event.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _eventCubit.deleteEvent(event.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  DateTime _parseEventDateTime(EventModel event) {
    // Parse the time string (assuming format like "6:30 PM")
    final timeComponents = event.time.split(':');
    int hour = int.parse(timeComponents[0]);
    final minuteSecond = timeComponents[1].split(' ');
    int minute = int.parse(minuteSecond[0]);

    // Handle AM/PM
    if (minuteSecond[1] == 'PM' && hour < 12) {
      hour += 12;
    } else if (minuteSecond[1] == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      hour,
      minute,
    );
  }
}
