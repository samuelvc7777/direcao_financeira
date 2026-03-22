import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static const Duration defaultDuration = Duration(milliseconds: 900);

  static SnackbarController show(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Duration duration = defaultDuration,
    Widget? icon,
    EdgeInsets? margin,
    double? borderRadius,
    bool isDismissible = true,
  }) {
    return Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration,
      icon: icon,
      margin: margin,
      borderRadius: borderRadius,
      isDismissible: isDismissible,
    );
  }
}
