import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/date_formatter.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final String time;
  final bool showSeconds; // خيار إضافي لعرض الثواني

  const CountdownTimer({
    super.key,
    required this.targetDate,
    required this.time,
    this.showSeconds = false, // افتراضياً لا تظهر الثواني
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;
  DateTime? _targetDateTime;

  @override
  void initState() {
    super.initState();
    _calculateTargetDateTime(); // حساب الوقت المستهدف مرة واحدة
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _calculateRemainingTime(); // تحديث كل نصف ثانية للحصول على دقة أعلى
    });
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إعادة حساب الوقت المستهدف إذا تغيرت بيانات الحدث
    if (oldWidget.targetDate != widget.targetDate ||
        oldWidget.time != widget.time) {
      _calculateTargetDateTime();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // استخراج وقت الحدث مرة واحدة وتخزينه
  void _calculateTargetDateTime() {
    try {
      // Parse the time string (assuming format like "6:30 PM")
      final timeComponents = widget.time.split(':');
      int hour = int.parse(timeComponents[0]);
      final minuteSecond = timeComponents[1].split(' ');
      int minute = int.parse(minuteSecond[0]);

      // Handle AM/PM
      if (minuteSecond[1] == 'PM' && hour < 12) {
        hour += 12;
      } else if (minuteSecond[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      _targetDateTime = DateTime(
        widget.targetDate.year,
        widget.targetDate.month,
        widget.targetDate.day,
        hour,
        minute,
      );
    } catch (e) {
      print("Error parsing event time: $e");
      // استخدام وقت افتراضي في حالة حدوث خطأ
      _targetDateTime = widget.targetDate.add(const Duration(hours: 12));
    }
  }

  // حساب الوقت المتبقي
  void _calculateRemainingTime() {
    if (_targetDateTime == null) return;

    final now = DateTime.now();

    setState(() {
      _remainingTime = _targetDateTime!.difference(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // إذا كان الحدث في الماضي
    if (_remainingTime.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isLight
                  ? Colors.red.withOpacity(0.2)
                  : Colors.red.shade900.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Event has passed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.red.shade800 : Colors.red.shade300,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isLight
                ? AppColors.accentLight.withOpacity(0.2)
                : AppColors.accentDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // العد التنازلي الأساسي
          Text(
            widget.showSeconds
                ? _formatCountdownWithSeconds(_remainingTime)
                : DateFormatter.formatCountdown(_remainingTime),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.primaryLight : AppColors.primaryDark,
            ),
          ),

          // إذا كان خيار عرض الثواني مفعلاً وكان الحدث سيحدث خلال ساعة
          if (widget.showSeconds && _remainingTime.inHours < 1) ...[
            const SizedBox(height: 4),
            Text(
              '${_remainingTime.inMinutes % 60} min, ${_remainingTime.inSeconds % 60} sec',
              style: TextStyle(
                fontSize: 14,
                color:
                    isLight
                        ? AppColors.primaryLight.withOpacity(0.7)
                        : AppColors.primaryDark.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // تنسيق العد التنازلي مع إضافة الثواني
  String _formatCountdownWithSeconds(Duration duration) {
    if (duration.isNegative) {
      return 'Event has passed';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days days, $hours hrs, $minutes min';
    } else if (hours > 0) {
      return '$hours hrs, $minutes min, $seconds sec';
    } else if (minutes > 0) {
      return '$minutes min, $seconds sec';
    } else {
      return '$seconds seconds';
    }
  }
}
