import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return 'Event has passed';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '$days days, $hours hrs';
    } else if (hours > 0) {
      return '$hours hrs, $minutes min';
    } else {
      return '$minutes min';
    }
  }
  
  static String formatCountdownShort(Duration duration) {
    if (duration.isNegative) {
      return 'Passed';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '$days days';
    } else if (hours > 0) {
      return '$hours hrs';
    } else {
      return '$minutes min';
    }
  }
}