import 'package:device_apps_ng/device_apps_ng.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class LauncherAppIcon extends StatelessWidget {
  final Application app;
  final VoidCallback? onTap;

  const LauncherAppIcon({super.key, required this.app, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50.r,
            height: 50.r,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(R.pill),
              child: app is ApplicationWithIcon
                  ? Image.memory(
                // ✅ Explicit cast so the compiler knows `icon` exists
                (app as ApplicationWithIcon).icon,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
                  : Icon(
                Icons.android,
                color: AppColors.textHint,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            app.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: T.small.copyWith(
              color: AppColors.text,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}