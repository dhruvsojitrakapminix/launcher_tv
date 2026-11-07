import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LauncherClock extends StatefulWidget {
  const LauncherClock({super.key});

  @override
  State<LauncherClock> createState() => _LauncherClockState();
}

class _LauncherClockState extends State<LauncherClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('HH:mm').format(_now),
          style: T.h1.copyWith(
            fontSize: 64.sp,
            fontWeight: FontWeight.w300,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          DateFormat('EEEE, MMM d').format(_now),
          style: T.body.copyWith(
            color: AppColors.textSub,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}