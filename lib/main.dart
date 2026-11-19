import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:izooto_plugin/iZooto_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app/data/repositories/favorites_repository.dart';
import 'app/data/services/ads_service.dart';
import 'app/data/services/app_config.dart';
import 'app/data/services/app_update_service.dart';
import 'app/data/services/custom_banner_service.dart';
import 'app/data/services/watch_history.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';

final facebookAppEvents = FacebookAppEvents();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack, fatal: true);
    return true;
  };

  await MobileAds.instance.initialize();

  await AppConfigStore.instance.init();
  CustomBannerService.instance.init();
  WatchHistory.instance.init();
  FavoritesRepo.i.init();

  AdsService.instance.init();

  AppUpdateService.instance.checkOnce();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static const platform = MethodChannel("iZooto-flutter");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestPermission();
  }

  Future<void> requestPermission() async {
    final results = await [Permission.notification, Permission.phone].request();
    if (results[Permission.notification]?.isGranted == true &&
        results[Permission.phone]?.isGranted == true) {
      if (Platform.isAndroid) {
        PermissionStatus notificationStatus = await Permission.notification.request();
        if (notificationStatus.isGranted) {
          debugPrint("Notification permission granted");
          if (Platform.isAndroid) {
            initMethod();
          }
        } else {
          debugPrint("Notification permission denied");
        }
        initMethod();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdsService.instance.showAppOpenIfReady();
    }
  }

  void initMethod() async {
    iZooto.androidInit(false);
    iZooto.promptForPushNotifications();
    iZooto.requestOneTapActivity();

    iZooto.shared.oneTapResponse((response) {
      print('DATA -> ${response.toString()}');

      Map<String, dynamic> jsonString = jsonDecode(response.toString());

      String email = jsonString['email'];
      String firstName = jsonString['firstName'];
      String lastName = jsonString['lastName'];

      print('Email: $email');
      print('First Name: $firstName');
      print('Last Name: $lastName');
    });

    iZooto.syncUserDetailsEmail("abc1@gmail.com", "Test1", "Demo1");

    if (Platform.isIOS) {
      iZooto.iOSInit(
        appId: "36abd056ff78bb1bd340f51fd03263f059953488",
      );
    }

    iZooto.shared.onNotificationReceived((payload) {
      print('PayLoad >> $payload');
    });

    iZooto.shared.onNotificationOpened((data) {
      print('Data >> $data');
    });

    iZooto.shared.onWebView((landingUrl) async {
      if (landingUrl == null) {
        return;
      }
      final Uri? uri = Uri.tryParse(landingUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in Chrome/Safari
        );
      } else {
        print('Could not launch $landingUrl');
      }
    });

    iZooto.shared.onTokenReceived((token) {
      print('Token >> $token');
    });

    try {
      String value = await platform.invokeMethod("OpenNotification");

      if (value != null) {
        print('iZooto Killed state ios data : $value');
      }
    } catch (e) {}

    iZooto.addUserProperty("pramod rai", "Datability");
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, __) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => AdsService.instance.onUserTap(),
        child: StreamBuilder(
          stream: PhoneState.stream,
          builder: (context, snapshot) {
            PhoneState? status = snapshot.data;

            if (status == null) {
              debugPrint('Phone State not available');
            }

            if (status?.status == PhoneStateStatus.CALL_ENDED) {
              debugPrint('Phone State is CALL ENDED');
            }

            return GetMaterialApp(
              title: 'AnimePahe',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              initialRoute: Routes.LAUNCHER,
              getPages: AppPages.pages,
              defaultTransition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 300),
              locale: const Locale('en', 'US'),
              fallbackLocale: const Locale('en', 'US'),
            );
          },
        ),
      ),
    );
  }
}
