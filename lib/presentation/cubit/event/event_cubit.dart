import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/event_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/event_repository_impl.dart';
import '../../../data/repositories/notification_repository_impl.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepositoryImpl eventRepository;
  final NotificationRepositoryImpl notificationRepository;

  // تخزين معرّفات الإشعارات المستخدمة لتجنب التكرار
  final Map<String, List<int>> _eventNotificationIds = {};

  EventCubit({
    required this.eventRepository,
    required this.notificationRepository,
  }) : super(EventInitial());

  Future<void> getEvents() async {
    emit(EventsLoading());
    try {
      final events = await eventRepository.getEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      print("Error loading events: $e");
      emit(const EventError(message: 'Failed to load events'));
    }
  }

  Future<void> getEvent(String id) async {
    emit(EventsLoading());
    try {
      final event = await eventRepository.getEvent(id);
      emit(EventLoaded(event: event));
    } catch (e) {
      print("Error loading event: $e");
      emit(const EventError(message: 'Failed to load event'));
    }
  }

  Future<void> createEvent({
    required String title,
    required DateTime date,
    required String time,
    required String icon,
    required Map<String, dynamic> notificationOptions,
  }) async {
    emit(EventsLoading());
    try {
      final id = const Uuid().v4();
      final event = EventModel(
        id: id,
        title: title,
        date: date,
        time: time,
        icon: icon,
        notificationOptions: notificationOptions,
      );

      print("=== Creating new event ===");
      print("Event ID: $id");
      print("Title: $title");
      print("Date: $date");
      print("Time: $time");
      print("Notification options: $notificationOptions");

      // حفظ الحدث في قاعدة البيانات
      await eventRepository.saveEvent(event);
      print("✓ Event saved to database successfully");

      // جدولة الإشعارات
      await _scheduleEventNotifications(event);

      emit(EventSaved());
      await getEvents(); // تحديث القائمة
    } catch (e) {
      print("❌ Error creating event: $e");
      emit(EventError(message: 'Failed to create event: $e'));
    }
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required DateTime date,
    required String time,
    required String icon,
    required Map<String, dynamic> notificationOptions,
  }) async {
    emit(EventsLoading());
    try {
      final event = EventModel(
        id: id,
        title: title,
        date: date,
        time: time,
        icon: icon,
        notificationOptions: notificationOptions,
      );

      print("=== Updating event ===");
      print("Event ID: $id");
      print("Title: $title");
      print("Date: $date");
      print("Time: $time");
      print("Notification options: $notificationOptions");

      // تحديث الحدث في قاعدة البيانات
      await eventRepository.updateEvent(event);
      print("✓ Event updated in database successfully");

      // إلغاء الإشعارات الحالية
      await _cancelEventNotifications(id);

      // جدولة إشعارات جديدة
      await _scheduleEventNotifications(event);

      emit(EventSaved());
      await getEvents(); // تحديث القائمة
    } catch (e) {
      print("❌ Error updating event: $e");
      emit(EventError(message: 'Failed to update event: $e'));
    }
  }

  Future<void> deleteEvent(String id) async {
    emit(EventsLoading());
    try {
      print("=== Deleting event ===");
      print("Event ID: $id");

      // حذف الحدث من قاعدة البيانات
      await eventRepository.deleteEvent(id);
      print("✓ Event deleted from database successfully");

      // إلغاء الإشعارات
      await _cancelEventNotifications(id);

      emit(EventDeleted());
      await getEvents(); // تحديث القائمة
    } catch (e) {
      print("❌ Error deleting event: $e");
      emit(const EventError(message: 'Failed to delete event'));
    }
  }

  // === دوال مساعدة ===

  // جدولة الإشعارات للحدث
  Future<void> _scheduleEventNotifications(EventModel event) async {
    if (event.notificationOptions['enabled'] != true) {
      print("Notifications disabled for this event. Skipping.");
      return;
    }

    final eventDateTime = _getEventDateTime(event);
    final now = DateTime.now();

    print("Current time: $now");
    print("Event time: $eventDateTime");
    print("Time difference: ${eventDateTime.difference(now)}");

    // قائمة لتتبع معرفات الإشعارات المستخدمة
    final notificationIds = <int>[];

    // 1. جدولة إشعار التذكير (إذا كان مفعلاً)
    if (event.notificationOptions['reminder'] == true) {
      final reminderHours =
          event.notificationOptions['reminderHours'] as int? ?? 24;
      final reminderDateTime = eventDateTime.subtract(
        Duration(hours: reminderHours),
      );

      print("Reminder time: $reminderDateTime");
      print("Reminder time difference: ${reminderDateTime.difference(now)}");

      if (reminderDateTime.isAfter(now)) {
        final reminderId = _generateNotificationId(event.id, "reminder");
        notificationIds.add(reminderId);

        print("Scheduling reminder notification:");
        print("ID: $reminderId");
        print("Title: Reminder: ${event.title}");
        print("Body: Your event is coming up in $reminderHours hours!");
        print("Time: $reminderDateTime");

        try {
          await notificationRepository.scheduleNotification(
            NotificationModel(
              id: reminderId,
              title: 'Reminder: ${event.title}',
              body: 'Your event is coming up in $reminderHours hours!',
              scheduledDate: reminderDateTime,
            ),
          );
          print("✓ Reminder notification scheduled successfully");
        } catch (e) {
          print("❌ Error scheduling reminder notification: $e");
        }
      } else {
        print(
          "⚠️ Reminder time is in the past. Skipping reminder notification.",
        );
      }
    }

    // 2. جدولة الإشعار الرئيسي
    if (eventDateTime.isAfter(now)) {
      final mainId = _generateNotificationId(event.id, "main");
      notificationIds.add(mainId);

      print("Scheduling main notification:");
      print("ID: $mainId");
      print("Title: ${event.title}");
      print("Body: Your event is now!");
      print("Time: $eventDateTime");

      try {
        await notificationRepository.scheduleNotification(
          NotificationModel(
            id: mainId,
            title: event.title,
            body: 'Your event is now!',
            scheduledDate: eventDateTime,
          ),
        );
        print("✓ Main notification scheduled successfully");
      } catch (e) {
        print("❌ Error scheduling main notification: $e");
        print("Error details: $e");
      }
    } else {
      print("⚠️ Event time is in the past. Skipping main notification.");
    }

    // حفظ معرفات الإشعارات للاستخدام في المستقبل
    _eventNotificationIds[event.id] = notificationIds;
  }

  // إلغاء جميع الإشعارات المرتبطة بالحدث
  Future<void> _cancelEventNotifications(String eventId) async {
    print("Canceling notifications for event: $eventId");

    // طريقة 1: إلغاء الإشعارات المخزنة في الكائن
    if (_eventNotificationIds.containsKey(eventId)) {
      final ids = _eventNotificationIds[eventId]!;
      print("Found ${ids.length} notification IDs to cancel: $ids");

      for (final id in ids) {
        try {
          await notificationRepository.cancelNotification(id);
          print("✓ Canceled notification with ID: $id");
        } catch (e) {
          print("❌ Error canceling notification $id: $e");
        }
      }

      _eventNotificationIds.remove(eventId);
    } else {
      print("No stored notification IDs found. Trying alternative method.");

      // طريقة 2: استخدام خوارزمية توليد المعرفات (احتياطية)
      try {
        // إلغاء إشعار التذكير
        final reminderId = _generateNotificationId(eventId, "reminder");
        await notificationRepository.cancelNotification(reminderId);
        print(
          "✓ Canceled potential reminder notification with ID: $reminderId",
        );

        // إلغاء الإشعار الرئيسي
        final mainId = _generateNotificationId(eventId, "main");
        await notificationRepository.cancelNotification(mainId);
        print("✓ Canceled potential main notification with ID: $mainId");
      } catch (e) {
        print("❌ Error during fallback notification cancellation: $e");
      }
    }
  }

  // توليد معرف فريد وثابت للإشعار
  int _generateNotificationId(String eventId, String type) {
    try {
      // استخدام قيمة هاش من معرف الحدث ونوع الإشعار
      // هذا سيضمن أن نفس الحدث ونفس النوع سيحصلان دائمًا على نفس المعرف
      final combinedHash = (eventId + type).hashCode;

      // تحويله إلى رقم إيجابي بين 1000 و 999999
      // هذا يتجنب تشابه المعرفات ويضمن أنها ضمن النطاق المسموح به
      return 1000 + (combinedHash.abs() % 998999);
    } catch (e) {
      print("Error generating notification ID. Using fallback method.");

      // طريقة احتياطية في حالة الخطأ
      final fallbackHash = DateTime.now().millisecondsSinceEpoch;
      return 1000 + (fallbackHash % 998999);
    }
  }

  // تحويل تاريخ ووقت الحدث إلى DateTime
  DateTime _getEventDateTime(EventModel event) {
    try {
      // تقسيم النص إلى مكونات (مثل "6:30 PM")
      final timeComponents = event.time.split(':');
      int hour = int.parse(timeComponents[0]);

      final minuteSecond = timeComponents[1].split(' ');
      int minute = int.parse(minuteSecond[0]);
      final period = minuteSecond[1]; // AM أو PM

      // معالجة صيغة 12 ساعة (AM/PM)
      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        hour,
        minute,
      );
    } catch (e) {
      print("❌ Error parsing event time: $e");
      // في حالة الخطأ، استخدم الساعة التالية كإجراء احتياطي
      final fallbackTime = DateTime.now().add(const Duration(hours: 1));
      return DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        fallbackTime.hour,
        fallbackTime.minute,
      );
    }
  }
}
