import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

/// Consistent Arabic snackbars — never dump raw API text outside mapped messages.
class AppSnackbars {
  AppSnackbars._();

  static void error(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode
          ? AppColors.darkSurfaceMuted
          : AppColors.lightSurface,
      colorText: Get.isDarkMode
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadii.md,
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message) {
    Get.snackbar(
      'تم',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.isDarkMode
          ? AppColors.darkSurfaceMuted
          : AppColors.lightSurface,
      colorText: Get.isDarkMode
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadii.md,
      duration: const Duration(seconds: 2),
    );
  }
}
