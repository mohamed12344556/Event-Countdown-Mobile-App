// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';

// import '../../data/models/event_model.dart';
// import '../cubit/event/event_cubit.dart';
// import '../cubit/event/event_state.dart';
// import '../widgets/event_card.dart';
// import 'add_edit_event_page.dart';
// import 'settings_page.dart';

// class EventListPage extends StatefulWidget {
//   const EventListPage({super.key});

//   @override
//   State<EventListPage> createState() => _EventListPageState();
// }

// class _EventListPageState extends State<EventListPage> {
//   late EventCubit _eventCubit;

//   @override
//   void initState() {
//     super.initState();
//     _eventCubit = GetIt.instance<EventCubit>();
//     _eventCubit.getEvents();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Event Countdown',
//         ), // Using hardcoded string instead of AppStrings for simplicity
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: BlocProvider.value(
//         value: _eventCubit,
//         child: BlocBuilder<EventCubit, EventState>(
//           builder: (context, state) {
//             if (state is EventsLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is EventsLoaded) {
//               final events = state.events;

//               if (events.isEmpty) {
//                 return const Center(
//                   child: Text('No events yet', style: TextStyle(fontSize: 18)),
//                 );
//               }

//               // Sort events by date
//               events.sort((a, b) {
//                 final aDateTime = _parseEventDateTime(a);
//                 final bDateTime = _parseEventDateTime(b);
//                 return aDateTime.compareTo(bDateTime);
//               });

//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: events.length,
//                 itemBuilder: (context, index) {
//                   final event = events[index];
//                   return EventCard(
//                     event: event,
//                     onTap: () => _navigateToEditEvent(event),
//                     onDelete: () => _showDeleteConfirmation(event),
//                   );
//                 },
//               );
//             } else if (state is EventError) {
//               return Center(
//                 child: Text(
//                   state.message,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               );
//             }

//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddEvent,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _navigateToAddEvent() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddEditEventPage()),
//     );
//     // تحديث القائمة بعد العودة
//     _eventCubit.getEvents();
//   }

//   void _navigateToEditEvent(EventModel event) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => AddEditEventPage(event: event)),
//     );
//   }

//   void _showDeleteConfirmation(EventModel event) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Event'),
//             content: Text('Are you sure you want to delete "${event.title}"?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _eventCubit.deleteEvent(event.id);
//                 },
//                 child: const Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   DateTime _parseEventDateTime(EventModel event) {
//     // Parse the time string (assuming format like "6:30 PM")
//     final timeComponents = event.time.split(':');
//     int hour = int.parse(timeComponents[0]);
//     final minuteSecond = timeComponents[1].split(' ');
//     int minute = int.parse(minuteSecond[0]);

//     // Handle AM/PM
//     if (minuteSecond[1] == 'PM' && hour < 12) {
//       hour += 12;
//     } else if (minuteSecond[1] == 'AM' && hour == 12) {
//       hour = 0;
//     }

//     return DateTime(
//       event.date.year,
//       event.date.month,
//       event.date.day,
//       hour,
//       minute,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/timezone.dart' as tz;

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
  bool _isTestingNotification = false;

  @override
  void initState() {
    super.initState();
    _eventCubit = GetIt.instance<EventCubit>();
    _eventCubit.getEvents();
  }

  // دالة لاختبار الإشعارات الفورية
  Future<void> _testImmediateNotification() async {
    setState(() {
      _isTestingNotification = true;
    });

    try {
      // الحصول على إصدار plugin الإشعارات
      final FlutterLocalNotificationsPlugin notificationsPlugin =
          GetIt.instance<FlutterLocalNotificationsPlugin>();

      // تكوين تفاصيل الإشعار
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'event_countdown_channel', // معرف القناة
            'Event Countdown', // اسم القناة
            channelDescription:
                'Notifications for event countdowns', // وصف القناة
            importance: Importance.high, // أهمية عالية
            priority: Priority.high, // أولوية عالية
            playSound: true, // تشغيل صوت
            enableVibration: true, // تمكين الاهتزاز
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // عرض إشعار فوري
      await notificationsPlugin.show(
        9999, // معرف فريد للإشعار التجريبي
        'اختبار الإشعار',
        'هذا إشعار تجريبي للتأكد من عمل نظام الإشعارات',
        notificationDetails,
      );

      // عرض رسالة توضيحية للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال إشعار تجريبي. تحقق من مركز الإشعارات!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // عرض رسالة خطأ في حالة فشل الإشعار
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال الإشعار: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      print("❌ خطأ في اختبار الإشعار: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isTestingNotification = false;
        });
      }
    }
  }

  // دالة لاختبار الإشعارات المجدولة بعد 10 ثوانٍ
  Future<void> _testScheduledNotification() async {
    setState(() {
      _isTestingNotification = true;
    });

    try {
      // الحصول على إصدار plugin الإشعارات
      final FlutterLocalNotificationsPlugin notificationsPlugin =
          GetIt.instance<FlutterLocalNotificationsPlugin>();

      // تكوين تفاصيل الإشعار
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'event_countdown_channel',
            'Event Countdown',
            channelDescription: 'Notifications for event countdowns',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // إنشاء وقت للإشعار بعد 10 ثوانٍ من الآن
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      final scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // جدولة الإشعار
      await notificationsPlugin.zonedSchedule(
        8888, // معرف فريد للإشعار المجدول التجريبي
        'إشعار مجدول',
        'تم جدولة هذا الإشعار ليظهر بعد 10 ثوانٍ',
        scheduledTZTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
      );

      // عرض رسالة توضيحية للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم جدولة إشعار للظهور بعد 10 ثوانٍ: ${scheduledTime.hour}:${scheduledTime.minute}:${scheduledTime.second}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // عرض رسالة خطأ في حالة فشل الإشعار
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جدولة الإشعار: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      print("❌ خطأ في جدولة الإشعار التجريبي: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isTestingNotification = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Countdown'),
        actions: [
          // زر اختبار الإشعارات
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notifications',
            onPressed:
                _isTestingNotification ? null : _testImmediateNotification,
          ),
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
      body: Column(
        children: [
          // شريط اختبار الإشعارات
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('إشعار فوري'),
                    onPressed:
                        _isTestingNotification
                            ? null
                            : _testImmediateNotification,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.alarm),
                    label: const Text('إشعار بعد 10 ثوانٍ'),
                    onPressed:
                        _isTestingNotification
                            ? null
                            : _testScheduledNotification,
                  ),
                ),
              ],
            ),
          ),

          // قائمة الأحداث
          Expanded(
            child: BlocProvider.value(
              value: _eventCubit,
              child: BlocBuilder<EventCubit, EventState>(
                builder: (context, state) {
                  if (state is EventsLoading || _isTestingNotification) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EventsLoaded) {
                    final events = state.events;

                    if (events.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events yet',
                          style: TextStyle(fontSize: 18),
                        ),
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
          ),
        ],
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
