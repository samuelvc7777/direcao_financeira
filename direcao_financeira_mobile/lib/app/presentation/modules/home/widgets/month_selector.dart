import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class MonthSelector extends GetView<HomeController> {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final month = controller.selectedMonth.value;
      final formatted = DateFormat(
        'MMMM yyyy',
        'pt_BR',
      ).format(month).toUpperCase();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              onPressed: controller.previousMonth,
              splashRadius: 20,
            ),
            Expanded(
              child: Text(
                formatted,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: controller.nextMonth,
              splashRadius: 20,
            ),
          ],
        ),
      );
    });
  }
}
