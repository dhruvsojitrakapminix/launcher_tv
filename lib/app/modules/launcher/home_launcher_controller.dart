import 'package:device_apps_ng/device_apps_ng.dart';
import 'package:get/get.dart';

class HomeLauncherController extends GetxController {
  final apps = <Application>[].obs;
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadApps();
  }

  Future<void> loadApps() async {
    loading.value = true;
    try {
      final list = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        onlyAppsWithLaunchIntent: true,
      );
      list.sort((a, b) =>
          a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      apps.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  void openApp(Application app) {
    DeviceApps.openApp(app.packageName);
  }
}