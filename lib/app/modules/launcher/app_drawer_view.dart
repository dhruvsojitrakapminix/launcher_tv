import 'package:device_apps_ng/device_apps_ng.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/launcher_app_icon.dart';
import 'home_launcher_controller.dart';

class AppDrawerView extends StatelessWidget {
  const AppDrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeLauncherController>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF20B0B0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: S.md),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: S.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: S.lg),
              child: Text('All Apps', style: T.h3),
            ),
            SizedBox(height: S.md),
            Expanded(
              child: Obx(() {
                if (c.loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.lg,
                    vertical: S.sm,
                  ),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: S.md,
                    mainAxisSpacing: S.lg,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: c.apps.length,
                  itemBuilder: (_, i) {
                    final Application app = c.apps[i];
                    return LauncherAppIcon(
                      app: app,
                      onTap: () => c.openApp(app),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}