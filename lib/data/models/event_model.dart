import 'dart:convert';

import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String icon;
  final Map<String, dynamic> notificationOptions;

  const EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.icon,
    required this.notificationOptions,
  });

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    String? icon,
    Map<String, dynamic>? notificationOptions,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      notificationOptions: notificationOptions ?? this.notificationOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'icon': icon,
      'notificationOptions': jsonEncode(notificationOptions),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      icon: map['icon'],
      notificationOptions: jsonDecode(map['notificationOptions']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EventModel.fromJson(String source) => EventModel.fromMap(jsonDecode(source));

  @override
  List<Object> get props => [id, title, date, time, icon, notificationOptions];
  
  // Calculate the remaining time until the event
  Duration timeRemaining() {
    final now = DateTime.now();
    
    // Parse the time string (assuming format like "6:30 PM")
    final timeComponents = time.split(':');
    int hour = int.parse(timeComponents[0]);
    final minuteSecond = timeComponents[1].split(' ');
    int minute = int.parse(minuteSecond[0]);
    
    // Handle AM/PM
    if (minuteSecond[1] == 'PM' && hour < 12) {
      hour += 12;
    } else if (minuteSecond[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    
    final eventDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    
    return eventDateTime.difference(now);
  }
}