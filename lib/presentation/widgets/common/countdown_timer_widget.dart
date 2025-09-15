import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/utils/typography.dart';

/// A reusable countdown timer widget that counts down from a specified duration
class CountdownTimerWidget extends StatefulWidget {
  final Duration initialDuration;
  final bool isDark;
  final VoidCallback? onTimerComplete;

  const CountdownTimerWidget({
    super.key,
    required this.initialDuration,
    required this.isDark,
    this.onTimerComplete,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentDuration.inSeconds > 0) {
        setState(() {
          _currentDuration = Duration(seconds: _currentDuration.inSeconds - 1);
        });
      } else {
        timer.cancel();
        widget.onTimerComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _currentDuration.inDays;
    final hours = _currentDuration.inHours % 24;
    final minutes = _currentDuration.inMinutes % 60;
    final seconds = _currentDuration.inSeconds % 60;

    return Container(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeUnit(days.toString().padLeft(2, '0'), 'DAYS'),
            _buildTimeSeparator(),
            _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HOURS'),
            _buildTimeSeparator(),
            _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'MINS'),
            _buildTimeSeparator(),
            _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'SECS'),
          ],
        ),
      ),
    );
  }

  /// Build individual time unit (days, hours, minutes, seconds)
  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: widget.isDark ? Colors.white : Colors.black87,
            fontFamily: 'monospace',
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  /// Build time separator (:)
  Widget _buildTimeSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.5.w),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: widget.isDark ? Colors.white : Colors.black87,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
