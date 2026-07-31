import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class Helpers {
  static void showSnackbar(String title, String message,
      {bool isError = false}) {
    final colors = Get.context?.appColors ?? AppColors.light;
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? colors.error : colors.accent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    showSnackbar('Error', message, isError: true);
  }
}
