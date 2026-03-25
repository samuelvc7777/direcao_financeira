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
    final theme = Get.theme;
    final fallbackBackground = theme.colorScheme.inverseSurface;
    final resolvedBackground = backgroundColor == null
        ? fallbackBackground
        : Color.alphaBlend(backgroundColor, theme.colorScheme.surface);
    final resolvedText = backgroundColor != null && backgroundColor.a < 0.4
        ? ThemeData.estimateBrightnessForColor(resolvedBackground) ==
                Brightness.dark
            ? Colors.white
            : theme.colorScheme.onSurface
        : colorText;

    return Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: resolvedBackground,
      colorText: resolvedText,
      duration: duration,
      icon: icon,
      margin: margin,
      borderRadius: borderRadius,
      isDismissible: isDismissible,
    );
  }
}
