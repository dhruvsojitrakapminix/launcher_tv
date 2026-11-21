import 'package:device_apps_ng/device_apps_ng.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/services/ads_service.dart';
import '../../data/services/app_config.dart';
import '../../data/services/launcher_service.dart';
import '../../data/services/wallpaper_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/launcher_app_icon.dart';
import '../../widgets/launcher_clock.dart';
import '../home/home_view.dart';
import '../onboarding/onboarding_name_age_view.dart';
import 'app_drawer_view.dart';
import 'home_launcher_controller.dart';
import 'marketing_launcher_view.dart';

class HomeLauncherView extends StatefulWidget {
  const HomeLauncherView({super.key});

  @override
  State<HomeLauncherView> createState() => _HomeLauncherViewState();
}

class _HomeLauncherViewState extends State<HomeLauncherView> {
  final PageController _pageCtrl = PageController(initialPage: 1);
  int page = 1;
  bool _drawerOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final RxList<Application> _pinned = <Application>[].obs;

  @override
  void initState() {
    super.initState();
    AdsService.launcherMode = true;
    final c = Get.put(HomeLauncherController());

    ever(c.apps, (List<Application> list) {
      if (list.isNotEmpty && _pinned.isEmpty) {
        _pinned.assignAll(list.take(25).toList());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }
bool isPendingScreen = false;
  Future<void> _bootstrap() async {
    // 1. Check the JSON config for marketing mode
    final isMarketing = AppConfigStore.instance.appConfig.apiData.isMarketing;
    debugPrint('🏠 isMarketing mode = $isMarketing');

    if (isMarketing) {
      // MARKETING FLOW: Force the user to set the app as the default launcher
      final isLauncher = await LauncherService.instance.isDefaultLauncher();
      debugPrint('🏠 (Marketing) isDefaultLauncher = $isLauncher');

      if (!isLauncher) {
        Get.offAll(() => const MarketingLauncherView());
      } else {
        await WallpaperService.instance.loadSystemWallpaper();
        final box = GetStorage();
        final done = box.read<bool>('onboarding_done') ?? false;
        if(!done && AppConfigStore.instance.appConfig.apiData.isMarketing){
          isPendingScreen = true;
        }
        if (mounted) setState(() {});
      }
    } else {
      Get.offAllNamed(_initialRoute());
    }
  }

  String _initialRoute() {
    final box = GetStorage();
    final done = box.read<bool>('onboarding_done') ?? false;
    debugPrint('🏠 is intro is done $done');
    return done ? Routes.HOME : Routes.OB_NAME_AGE;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    AdsService.launcherMode = false;
    _pageCtrl.dispose();
    super.dispose();
  }

  Widget _gradientWidget(List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeLauncherController>();
    final wp = WallpaperService.instance;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isPendingScreen ? const OnboardingNameAgeView() : Stack(
        children: [
          // ── Wallpaper background ───────────────────
          Positioned.fill(
            child: wp.wallpaperBytes != null
                ? Image.memory(
                    wp.wallpaperBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : wp.wallpaperUrl != null
                    ? Image.network(
                        wp.wallpaperUrl!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return _gradientWidget(wp.fallbackGradient);
                        },
                        errorBuilder: (_, __, ___) => _gradientWidget(wp.fallbackGradient),
                      )
                    : _gradientWidget(wp.fallbackGradient),
          ),

          // ── PageView (Home · Launcher · All Apps) ──
          PageView(
            controller: _pageCtrl,
            onPageChanged: (i) {
              setState(() => page = i);
              if (i == 2) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              }
            },
            children: [
              const HomeView(),
              _buildHomePage(c),
              _buildAllAppsPage(c),
            ],
          ),

          // ── Slide-up app drawer ────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            bottom: _drawerOpen ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: const AppDrawerView(),
          ),

          if (_drawerOpen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
              ),
            ),
        ],
      ),
    );
  }

  // ── Home (pinned apps) ───────────────────────────
  Widget _buildHomePage(HomeLauncherController c) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          setState(() => _drawerOpen = true);
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: S.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // Clock
              const LauncherClock(),

              SizedBox(height: 48.h),

              // Pinned apps grid
              Obx(() {
                if (_pinned.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: Center(
                      child: c.loading.value
                          ? const SizedBox()
                          : Text(
                              'No apps found',
                              style: T.body.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: S.md,
                    mainAxisSpacing: S.lg,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _pinned.length > 20 ? 20 : _pinned.length,
                  itemBuilder: (_, i) {
                    final app = _pinned[i];
                    return LauncherAppIcon(
                      app: app,
                      onTap: () => c.openApp(app),
                    );
                  },
                );
              }),

              const Spacer(),

              // Bottom dock
              Obx(() {
                if (_pinned.length < 20) {
                  return const SizedBox(height: 90);
                }
                return Container(
                  margin: EdgeInsets.only(bottom: S.xl),
                  padding: EdgeInsets.symmetric(
                    horizontal: S.lg,
                    vertical: S.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(R.xl),
                    border: Border.all(
                      color: AppColors.divider.withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _pinned
                        .sublist(20)
                        .map(
                          (app) => GestureDetector(
                            onTap: () => c.openApp(app),
                            child: SizedBox(
                              width: 48.r,
                              height: 48.r,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(R.md),
                                child: app is ApplicationWithIcon
                                    ? Image.memory(
                                        app.icon,
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
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── All apps (search + grid) ─────────────────────
  Widget _buildAllAppsPage(HomeLauncherController c) {
    return Container(
      color: AppColors.bg.withOpacity(0.3),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(S.lg, S.xl, S.lg, S.md),
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: S.lg),
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(R.xl),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 20.sp,
                    ),
                    SizedBox(width: S.sm),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: T.body.copyWith(
                          color: AppColors.text,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search apps…',
                          hintStyle: T.small.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        onChanged: (q) => setState(() => _searchQuery = q),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textHint,
                          size: 18.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Grid of apps
            Expanded(
              child: Obx(() {
                if (c.loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                final all = c.apps;
                final filtered = _searchQuery.isEmpty
                    ? all
                    : all
                        .where((a) => a.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: AppColors.textHint,
                          size: 48.sp,
                        ),
                        SizedBox(height: S.md),
                        Text(
                          _searchQuery.isEmpty ? 'No apps found' : 'No apps match "$_searchQuery"',
                          style: T.body.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: S.lg,
                    vertical: S.sm,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: S.md,
                    mainAxisSpacing: S.lg,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
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
