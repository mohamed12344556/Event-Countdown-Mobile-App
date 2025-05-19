import 'dart:async';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/date_formatter.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final String time;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    required this.time,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
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

    final targetDateTime = DateTime(
      widget.targetDate.year,
      widget.targetDate.month,
      widget.targetDate.day,
      hour,
      minute,
    );

    final now = DateTime.now();

    setState(() {
      _remainingTime = targetDateTime.difference(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isLight
                ? AppColors.accentLight.withOpacity(0.2)
                : AppColors.accentDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        DateFormatter.formatCountdown(_remainingTime),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isLight ? AppColors.primaryLight : AppColors.primaryDark,
        ),
      ),
    );
  }
}
