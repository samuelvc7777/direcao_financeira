import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';

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
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.theme.colorScheme.onSurface.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
              onPressed: controller.previousMonth,
              splashRadius: 20,
            ),
            Expanded(
              child: Text(
                formatted,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
              onPressed: controller.nextMonth,
              splashRadius: 20,
            ),
          ],
        ),
      );
    });
  }
}
