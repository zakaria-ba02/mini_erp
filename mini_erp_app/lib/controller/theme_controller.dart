import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/storage/theme_storage.dart';

class ThemeController extends GetxController {
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    themeMode.value = await ThemeStorage.read();
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await ThemeStorage.write(mode);
  }

  Future<void> toggleLightDark() async {
    final next = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }

  bool get isDark {
    if (themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode.value == ThemeMode.dark;
  }
}
