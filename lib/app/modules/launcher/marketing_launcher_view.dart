import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/services/launcher_service.dart';
import '../../data/services/wallpaper_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class MarketingLauncherView extends StatefulWidget {
  const MarketingLauncherView({super.key});

  @override
  State<MarketingLauncherView> createState() => _MarketingLauncherViewState();
}

class _MarketingLauncherViewState extends State<MarketingLauncherView>
    with WidgetsBindingObserver {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Triggers when the user returns to the app from Android Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLauncherStatus();
    }
  }

  Future<void> _checkLauncherStatus() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final isLauncher = await LauncherService.instance.isDefaultLauncher();
    debugPrint('🏠 (Marketing) isDefaultLauncher = $isLauncher');

    if (isLauncher) {
      // Success! Continue to onboarding
      await WallpaperService.instance.loadSystemWallpaper();
      Get.offAllNamed(Routes.LAUNCHER);
    } else {
      // Not set as default -> Stay on page and warn user
      setState(() => _isLoading = false);
      Get.snackbar(
        'Action Required',
        'Please set AnimePahe as your default home app to continue.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: EdgeInsets.all(S.md),
        borderRadius: R.md,
      );
    }
  }

  Future<void> _setDefaultLauncher() async {
    await LauncherService.openLauncherChooser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: S.lg),
                child: Column(
                  children: [
                    SizedBox(height: S.xxl),

                    // App Icon
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF4500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(R.xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 48.sp),
                    ),
                    SizedBox(height: S.lg),

                    // Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: S.md, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(R.xl),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: AppColors.primary, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'ONE STEP TO UNLOCK',
                            style: T.small.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: S.md),

                    // Title
                    Text(
                      'MAKE AnimePahe YOUR HOME',
                      textAlign: TextAlign.center,
                      style: T.h1.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: S.sm),

                    // Subtitle
                    Text(
                      'Set AnimePahe as your home app so movies and series are one swipe away — free, whenever you want.',
                      textAlign: TextAlign.center,
                      style: T.body.copyWith(
                        color: AppColors.textHint,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: S.lg),

                    // Feature Cards
                    Row(
                      children: [
                        _buildFeatureCard(
                            Icons.movie_creation_outlined, 'Movies'),
                        SizedBox(width: S.sm),
                        _buildFeatureCard(Icons.tv_outlined, 'Series'),
                        SizedBox(width: S.sm),
                        _buildFeatureCard(
                            Icons.local_offer_outlined, '100% free'),
                      ],
                    ),
                    SizedBox(height: S.xl),

                    // Mock System Dialog (Visual representation only)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(R.xl),
                      ),
                      child: Column(
                        children: [
                          // AnimePahe Row (Selected)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: S.lg, vertical: 6.h),
                            leading: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFFFF4500)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(R.sm),
                              ),
                              child: Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 20.sp),
                            ),
                            title: Text(
                              'AnimePahe',
                              style: T.body.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Icon(Icons.radio_button_checked,
                                color: AppColors.primary, size: 24.sp),
                          ),
                          Divider(height: 1, color: AppColors.divider),
                          // One UI Home Row (Not Selected)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: S.lg, vertical: 6.h),
                            leading: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(R.sm),
                              ),
                              child: Icon(Icons.home,
                                  color: AppColors.textHint, size: 20.sp),
                            ),
                            title: Text(
                              'One UI Home',
                              style: T.body.copyWith(
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Current default',
                              style: T.small.copyWith(
                                color: AppColors.textHint.withOpacity(0.7),
                              ),
                            ),
                            trailing: Icon(Icons.radio_button_unchecked,
                                color: AppColors.divider, size: 24.sp),
                          ),
                          Divider(height: 1, color: AppColors.divider),
                          // Mock Buttons Row
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: S.lg, vertical: S.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: T.body.copyWith(
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 24.h,
                                    color: AppColors.divider),
                                Expanded(
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 10.h),
                                    margin: EdgeInsets.only(left: S.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.divider,
                                      borderRadius:
                                      BorderRadius.circular(R.xl),
                                    ),
                                    child: Text(
                                      'Set as default',
                                      textAlign: TextAlign.center,
                                      style: T.small.copyWith(
                                        color: AppColors.bg,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: S.lg),

                    // Warning Banner
                    Container(
                      padding: EdgeInsets.all(S.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(R.md),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.primary, size: 24.sp),
                          SizedBox(width: S.sm),
                          Expanded(
                            child: Text(
                              'Almost there — choose AnimePahe as your default home app.',
                              style: T.small.copyWith(
                                color: AppColors.textHint,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: S.xxl),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Action Area
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: S.lg, vertical: S.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tap to set as default',
                    style: T.small.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primary, size: 24.sp),
                  SizedBox(height: S.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _setDefaultLauncher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.xl),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.white, size: 20.sp),
                          SizedBox(width: S.sm),
                          Text(
                            'SET AS DEFAULT',
                            style: T.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: S.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24.sp),
            SizedBox(height: S.sm),
            Text(
              label,
              style: T.small.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}