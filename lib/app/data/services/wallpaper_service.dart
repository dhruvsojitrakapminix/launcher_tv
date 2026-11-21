import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_handler/wallpaper_handler.dart';

class WallpaperService {
  WallpaperService._();
  static final WallpaperService instance = WallpaperService._();

  String? wallpaperUrl;
  Uint8List? wallpaperBytes; // Add this to hold the raw image data

  List<Color> get fallbackGradient => const [
    Color(0xFF1B2A55),
    Color(0xFF0B0B0F),
  ];

  void setWallpaper(String? url) => wallpaperUrl = url;

  /// Call this after the app is set as the default launcher.
  Future<void> loadSystemWallpaper() async {
    try {
      final status = await Permission.manageExternalStorage.status;

      debugPrint('Manage storage status: $status');
      debugPrint('Granted: ${status.isGranted}');

      if (!status.isGranted) {
        final requested =
        await Permission.manageExternalStorage.request();

        debugPrint('Permission request result: $requested');

        if (!requested.isGranted) {
          debugPrint('Permission not granted');
          return;
        }
      }

      final bytes = await WallpaperHandler.instance.getWallpaper(
        WallpaperLocation.homeScreen,
      );

      debugPrint('Wallpaper result: ${bytes?.length ?? "null"}');

      if (bytes != null && bytes.isNotEmpty) {
        wallpaperBytes = bytes;
        wallpaperUrl = null;
      }
    } catch (e, stackTrace) {
      debugPrint('Wallpaper error: $e');
      debugPrint('Wallpaper stack: $stackTrace');
    }
  }
}