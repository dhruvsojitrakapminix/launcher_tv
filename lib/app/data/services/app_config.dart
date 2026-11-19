import 'dart:convert';
import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_install_referrer/flutter_install_referrer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ─────────────────────────────────────────────
//  Nested models matching your JSON schema
// ─────────────────────────────────────────────

class ApiData {
  final String base;
  final String fbId;
  final String fbToken;
  bool isMarketing;
  final bool isShowAdTapOnApp;
  final String img;
  final String imgBig;
  final String token; // TMDB bearer token

  ApiData({
    required this.base,
    required this.fbId,
    required this.fbToken,
    required this.isMarketing,
    required this.isShowAdTapOnApp,
    required this.img,
    required this.imgBig,
    required this.token,
  });

  factory ApiData.fromJson(Map<String, dynamic> j) => ApiData(
        base: j['base'] ?? 'https://api.themoviedb.org/3',
        fbId: j['fbId'] ?? '',
        fbToken: j['fbToken'] ?? '',
        isMarketing: j['isMarketing'] ?? false,
        isShowAdTapOnApp: j['isshowAdTapOnApp'] ?? false,
        img: j['img'] ?? 'https://image.tmdb.org/t/p/w500',
        imgBig: j['imgBig'] ?? 'https://image.tmdb.org/t/p/w780',
        token: j['token'] ?? '',
      );
}

class AppUpdateConfig {
  final bool enabled;
  final bool forceUpdate;
  final String minVersion;
  final int minBuildNumber;
  final String updateTitle;
  final String updateMessage;
  final String buttonText;
  final String laterText;
  final String androidStoreUrl;
  final String appStoreUrl;
  final String privacyPolicy;
  final String termsAndCondition;
  final bool isIntroLoopActive;

  AppUpdateConfig({
    required this.enabled,
    required this.forceUpdate,
    required this.minVersion,
    required this.minBuildNumber,
    required this.updateTitle,
    required this.updateMessage,
    required this.buttonText,
    required this.laterText,
    required this.androidStoreUrl,
    required this.appStoreUrl,
    required this.privacyPolicy,
    required this.termsAndCondition,
    required this.isIntroLoopActive,
  });

  factory AppUpdateConfig.fromJson(Map<String, dynamic> j) => AppUpdateConfig(
        enabled: j['enabled'] ?? false,
        forceUpdate: j['forceUpdate'] ?? false,
        minVersion: j['minVersion'] ?? '1.0.0',
        minBuildNumber: j['minBuildNumber'] ?? 1,
        updateTitle: j['updateTitle'] ?? 'Update Required',
        updateMessage: j['updateMessage'] ?? '',
        buttonText: j['buttonText'] ?? 'UPDATE',
        laterText: j['laterText'] ?? 'Later',
        androidStoreUrl: j['androidStoreUrl'] ?? '',
        appStoreUrl: j['appStoreUrl'] ?? '',
        privacyPolicy: j['privacy_policy'] ?? '',
        termsAndCondition: j['terms_and_condition'] ?? '',
        isIntroLoopActive: j['isIntroLoopActive'] ?? false,
      );
}

class WatchRedirect {
  final bool enabled;
  final String url;

  WatchRedirect({required this.enabled, required this.url});

  factory WatchRedirect.fromJson(Map<String, dynamic> j) => WatchRedirect(
        enabled: j['enabled'] ?? false,
        url: j['url'] ?? '',
      );
}

/// One ad-slot: isShow + list of ids.
class AdSlot {
  final bool isShow;
  final List<String> ids;

  AdSlot({required this.isShow, required this.ids});

  String pick({int index = 0}) {
    if (ids.isEmpty) return '';
    final i = index % ids.length;
    return ids[i];
  }

  factory AdSlot.fromJson(Map<String, dynamic> j) => AdSlot(
        isShow: j['isShow'] ?? false,
        ids: (j['id'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class AdmobAdsIds {
  final AdSlot open;
  final AdSlot interstitial;
  final AdSlot native;
  final AdSlot reward;
  final AdSlot customBanner;

  AdmobAdsIds({
    required this.open,
    required this.interstitial,
    required this.native,
    required this.reward,
    required this.customBanner,
  });

  factory AdmobAdsIds.fromJson(Map<String, dynamic> j) {
    final ids = j['AdsIds'] as Map<String, dynamic>? ?? {};
    return AdmobAdsIds(
      open: AdSlot.fromJson(ids['open'] as Map<String, dynamic>? ?? {}),
      interstitial: AdSlot.fromJson(ids['interstitial'] as Map<String, dynamic>? ?? {}),
      native: AdSlot.fromJson(ids['native'] as Map<String, dynamic>? ?? {}),
      reward: AdSlot.fromJson(ids['reward'] as Map<String, dynamic>? ?? {}),
      customBanner: AdSlot.fromJson(ids['custom_banner'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CustomNativeAssets {
  final List<String> smallImages;
  final List<String> mediumImages;
  final List<String> ctaUrls;

  CustomNativeAssets({
    required this.smallImages,
    required this.mediumImages,
    required this.ctaUrls,
  });

  factory CustomNativeAssets.fromJson(Map<String, dynamic> j) => CustomNativeAssets(
        smallImages: (j['smallImages'] as List? ?? []).map((e) => e.toString()).toList(),
        mediumImages: (j['mediumImages'] as List? ?? []).map((e) => e.toString()).toList(),
        ctaUrls: (j['ctaUrls'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class CustomBannerAssets {
  final List<String> images;
  final List<String> urls;

  CustomBannerAssets({required this.images, required this.urls});

  factory CustomBannerAssets.fromJson(Map<String, dynamic> j) => CustomBannerAssets(
        images: (j['images'] as List? ?? []).map((e) => e.toString()).toList(),
        urls: (j['urls'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class CustomInterstitialAssets {
  final List<String> urls;

  CustomInterstitialAssets({required this.urls});

  factory CustomInterstitialAssets.fromJson(Map<String, dynamic> j) => CustomInterstitialAssets(
        urls: (j['urls'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class CustomAds {
  final List<String> headlines;
  final List<String> descriptions;
  final List<String> buttonTexts;
  final String adBadgeText;
  final CustomNativeAssets native;
  final CustomBannerAssets banner;
  final CustomInterstitialAssets interstitial;

  CustomAds({
    required this.headlines,
    required this.descriptions,
    required this.buttonTexts,
    required this.adBadgeText,
    required this.native,
    required this.banner,
    required this.interstitial,
  });

  String headline(int i) => headlines.isEmpty ? 'Sponsored' : headlines[i % headlines.length];

  String description(int i) => descriptions.isEmpty ? '' : descriptions[i % descriptions.length];

  String buttonText(int i) => buttonTexts.isEmpty ? 'Open' : buttonTexts[i % buttonTexts.length];

  factory CustomAds.fromJson(Map<String, dynamic> j) => CustomAds(
        headlines: (j['headlines'] as List? ?? []).map((e) => e.toString()).toList(),
        descriptions: (j['descriptions'] as List? ?? []).map((e) => e.toString()).toList(),
        buttonTexts: (j['buttonTexts'] as List? ?? []).map((e) => e.toString()).toList(),
        adBadgeText: j['adBadgeText'] ?? 'Ad',
        native: CustomNativeAssets.fromJson(j['native'] as Map<String, dynamic>? ?? {}),
        banner: CustomBannerAssets.fromJson(j['banner'] as Map<String, dynamic>? ?? {}),
        interstitial:
            CustomInterstitialAssets.fromJson(j['interstitial'] as Map<String, dynamic>? ?? {}),
      );
}

class NativeConfig {
  final String backgroundColor;
  final String fontColor;
  final String buttonColor;
  final String buttonFontColor;
  final double buttonBorderRadius;
  final double borderRadius;
  final int adSlotMinHeight;
  final int adSlotMaxHeight;
  final double mediaCornerRadius;
  final String adBadgeBackgroundColor;
  final String adBadgeFontColor;

  NativeConfig({
    required this.backgroundColor,
    required this.fontColor,
    required this.buttonColor,
    required this.buttonFontColor,
    required this.buttonBorderRadius,
    required this.borderRadius,
    required this.adSlotMinHeight,
    required this.adSlotMaxHeight,
    required this.mediaCornerRadius,
    required this.adBadgeBackgroundColor,
    required this.adBadgeFontColor,
  });

  factory NativeConfig.fromJson(Map<String, dynamic> j) => NativeConfig(
        backgroundColor: j['backgroundColor'] ?? '#1A2744',
        fontColor: j['fontColor'] ?? '#FFFFFF',
        buttonColor: j['buttonColor'] ?? '#168F84',
        buttonFontColor: j['buttonFontColor'] ?? '#FFFFFF',
        buttonBorderRadius: (j['buttonBorderRadius'] as num? ?? 18).toDouble(),
        borderRadius: (j['borderRadius'] as num? ?? 12).toDouble(),
        adSlotMinHeight: j['adSlotMinHeight'] ?? 120,
        adSlotMaxHeight: j['adSlotMaxHeight'] ?? 210,
        mediaCornerRadius: (j['mediaCornerRadius'] as num? ?? 12).toDouble(),
        adBadgeBackgroundColor: j['adBadgeBackgroundColor'] ?? '#FFCC66',
        adBadgeFontColor: j['adBadgeFontColor'] ?? '#FFFFFF',
      );
}

// ─────────────────────────────────────────────
//  Root config
// ─────────────────────────────────────────────

class AppConfig {
  final ApiData apiData;
  final AppUpdateConfig appUpdateConfig;
  final WatchRedirect watchRedirect;
  final bool preloadAds;
  final bool ondemandFallback;
  final int interstitialClickCount;
  final String primaryNetwork;
  final AdmobAdsIds admobAds;
  final CustomAds custom;
  final NativeConfig nativeConfig;

  AppConfig({
    required this.apiData,
    required this.appUpdateConfig,
    required this.watchRedirect,
    required this.preloadAds,
    required this.ondemandFallback,
    required this.interstitialClickCount,
    required this.primaryNetwork,
    required this.admobAds,
    required this.custom,
    required this.nativeConfig,
  });

  factory AppConfig.defaults() => AppConfig.fromJson({});

  factory AppConfig.fromJson(Map<String, dynamic> j) {
    final adsArr = j['admobAds'] as List? ?? [];

    // Safely extract the first ad-network entry, converting to Map<String,dynamic>
    Map<String, dynamic> firstAds = <String, dynamic>{};
    if (adsArr.isNotEmpty && adsArr.first is Map) {
      firstAds = Map<String, dynamic>.from(adsArr.first as Map);
    }

    return AppConfig(
      apiData: ApiData.fromJson(Map<String, dynamic>.from(j['ApiData'] as Map? ?? {})),
      appUpdateConfig:
          AppUpdateConfig.fromJson(Map<String, dynamic>.from(j['appUpdateConfig'] as Map? ?? {})),
      watchRedirect:
          WatchRedirect.fromJson(Map<String, dynamic>.from(j['watchRedirect'] as Map? ?? {})),
      preloadAds: j['preloadAds'] ?? true,
      ondemandFallback: j['ondemandFallback'] ?? true,
      interstitialClickCount: j['interstitialClickCount'] ?? 5,
      primaryNetwork: j['primaryNetwork'] ?? 'admob',
      admobAds: AdmobAdsIds.fromJson(firstAds),
      custom: CustomAds.fromJson(Map<String, dynamic>.from(j['custom'] as Map? ?? {})),
      nativeConfig:
          NativeConfig.fromJson(Map<String, dynamic>.from(j['nativeConfig'] as Map? ?? {})),
    );
  }
}

// ─────────────────────────────────────────────
//  Store (singleton)
// ─────────────────────────────────────────────

class AppConfigStore extends GetxController {
  AppConfigStore._();

  static final AppConfigStore instance = AppConfigStore._();

  static const String _cacheKey = 'anime_pahe_app';

  final GetStorage _box = GetStorage();

  AppConfig _config = AppConfig.defaults();

  AppConfig get appConfig => _config;

  bool _initialized = false;
  bool _facebookInitialized = false;

  // Native Android Facebook channel
  static const MethodChannel _facebookChannel = MethodChannel('com.dhruv.launcher.app/facebook');

  // Facebook Flutter plugin
  static final FacebookAppEvents _facebookEvents = FacebookAppEvents();

  // ------------------------------------------
  // INITIALIZE APP CONFIGURATION
  // ------------------------------------------

  Future<void> init() async {
    if (_initialized) return;

    _initialized = true;

    // STEP 1: Load cached configuration
    final raw = _box.read(_cacheKey);

    if (raw != null) {
      try {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          jsonDecode(raw) as Map,
        );

        _config = AppConfig.fromJson(json);

        debugPrint('Cached configuration loaded');
      } catch (e) {
        debugPrint('Cache parsing error: $e');
      }
    }

    // STEP 2: Fetch Firebase Remote Config
    await checkInstallSource();
    await _fetchRemoteConfig();

    // STEP 3: Configure and initialize Facebook
    await initializeFacebook();
  }

  bool isMarketingCheck = false;

  Future<void> checkInstallSource() async {
    try {
      final InstallationApp? app = await InstallReferrer.app;

      if (app == null) {
        debugPrint('Install referrer info not available');
        return;
      }

      final InstallationAppReferrer? referrer = app.referrer;

      if (referrer == null) {
        return;
      }

      final checkList = [
        "gclid",
        "fbclid",
        "utm_source=facebook",
        "utm_source=meta",
        "utm_source=instagram",
        "androidDebug",
      ];

      for (var keyword in checkList) {
        if (referrer.toString().split(".").last.contains(keyword)) {
          isMarketingCheck = true;
          debugPrint("================>$keyword");
          break;
        }
      }

      debugPrint('Install source: ${referrer.toString().split(".").last}');
      debugPrint('Package name: ${app.packageName}');

      if (referrer == InstallationAppReferrer.androidGooglePlay) {
        debugPrint('Installed from Google Play');
      }
    } catch (e) {
      print('Referrer not available: $e');
    }
  }

  // ------------------------------------------
  // FETCH FIREBASE REMOTE CONFIG
  // ------------------------------------------

  Future<void> _fetchRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      final bool updated = await remoteConfig.fetchAndActivate();

      debugPrint('Firebase updated: $updated');

      // Always read currently active value
      final String jsonString = remoteConfig.getString(_cacheKey);

      if (jsonString.isEmpty) {
        debugPrint('Firebase configuration is empty');
        return;
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(jsonString) as Map,
      );

      // Update application configuration
      _config = AppConfig.fromJson(json);

      // Save configuration locally
      await _box.write(_cacheKey, jsonString);
      if (!_config.apiData.isMarketing && isMarketingCheck) {
        _config.apiData.isMarketing = true;
        debugPrint('Updated ApiData.isMarketing to true based on install referrer');
      }

      debugPrint('Firebase configuration loaded');
      debugPrint(
        'Marketing enabled: ${_config.apiData.isMarketing}',
      );

      debugPrint(
        'Facebook App ID available: ${_config.apiData.fbId.isNotEmpty}',
      );
    } catch (e, stackTrace) {
      debugPrint('Firebase Remote Config error: $e');
      debugPrint('$stackTrace');

      // Continue using cached configuration if available
    }
  }

  // ------------------------------------------
  // INITIALIZE FACEBOOK SDK
  // ------------------------------------------

  Future<void> initializeFacebook() async {
    if (_facebookInitialized) return;

    try {
      final ApiData api = _config.apiData;

      // Check marketing enabled
      // if (!api.isMarketing) {
      //   debugPrint('Facebook marketing disabled');
      //   return;
      // }

      // Read Firebase credentials
      final String appId = api.fbId.trim();
      final String clientToken = api.fbToken.trim();

      if (appId.isEmpty || clientToken.isEmpty) {
        debugPrint('Facebook App ID or Client Token missing');
        return;
      }

      if (defaultTargetPlatform != TargetPlatform.android) {
        debugPrint('This native implementation is Android only');
        return;
      }

      debugPrint('Sending Facebook credentials to Android');

      // STEP 1: Send credentials to Kotlin
      final bool? nativeResult = await _facebookChannel.invokeMethod<bool>(
        'setFacebookCredentials',
        {
          'appId': appId,
          'clientToken': clientToken,
        },
      );

      if (nativeResult != true) {
        throw Exception(
          'Android Facebook native configuration failed',
        );
      }

      debugPrint('Native Facebook configuration successful');

      // STEP 2: Complete Facebook SDK initialization
      await _facebookEvents.initializeSdk();

      debugPrint('Facebook SDK initialized successfully');

      // STEP 3: Log custom event
      await _facebookEvents.logEvent(
        name: 'app_opened',
        parameters: {
          'Time': DateTime.now().toString(),
          'platform': Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
                  ? 'Ios'
                  : 'Other',
          'source': 'firebase_remote_config',
        },
      );

      _facebookInitialized = true;

      debugPrint('Facebook app_opened event logged');
    } on PlatformException catch (e) {
      debugPrint(
        'Facebook PlatformException: ${e.code} ${e.message}',
      );
    } catch (e, stackTrace) {
      debugPrint('Facebook initialization error: $e');
      debugPrint('$stackTrace');
    }
  }
}
