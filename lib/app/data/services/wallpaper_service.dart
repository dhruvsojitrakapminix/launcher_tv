import 'dart:typed_data';
import 'package:flutter/material.dart';
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
      // The method to get wallpaper
      Uint8List? bytes = await WallpaperHandler.instance.getWallpaper(WallpaperLocation.homeScreen);

      if (bytes != null) {
        wallpaperBytes = bytes;
        wallpaperUrl = null; // Clear URL to use bytes
        debugPrint("System wallpaper loaded: ${bytes.length} bytes");
      }
    } catch (e) {
      debugPrint("Failed to get wallpaper: $e");
    }
  }
}