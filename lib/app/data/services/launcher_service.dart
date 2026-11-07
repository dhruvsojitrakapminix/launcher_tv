import 'package:flutter/services.dart';

class LauncherService {
  LauncherService._();
  static final LauncherService instance = LauncherService._();

  // ✅ FIX: Changed to match your applicationId (com.dhruv.launcher.app)
  static const MethodChannel _channel =
  MethodChannel('com.dhruv.launcher.app/launcher');

  Future<bool> isDefaultLauncher() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isDefaultLauncher');
      return result ?? false;
    } on PlatformException catch (e) {
      print('isDefaultLauncher failed: ${e.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openLauncherChooser() async {
    try {
      await _channel.invokeMethod('openLauncherChooser');
    } on PlatformException catch (e) {
      print('openLauncherChooser failed: ${e.message}');
    } on MissingPluginException {
      print('MethodChannel not found! Check native code.');
    }
  }

  Future<void> requestDefaultLauncher() async {
    await openLauncherChooser();
  }
}