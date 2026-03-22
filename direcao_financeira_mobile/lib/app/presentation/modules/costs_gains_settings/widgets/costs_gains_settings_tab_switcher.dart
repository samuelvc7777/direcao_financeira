import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../costs_gains_settings_controller.dart';

class CostsGainsSettingsTabSwitcher extends StatelessWidget {
  const CostsGainsSettingsTabSwitcher({super.key, required this.controller});

  final CostsGainsSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _TabItem(
                label: 'Resultado',
                icon: Icons.auto_graph_rounded,
                isSelected:
                    controller.selectedTab.value ==
                    CostsGainsSettingsTab.resultado,
                onTap: () =>
                    controller.selectTab(CostsGainsSettingsTab.resultado),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabItem(
                label: 'Semáforo',
                icon: Icons.traffic_rounded,
                isSelected:
                    controller.selectedTab.value ==
                    CostsGainsSettingsTab.semaforo,
                onTap: () =>
                    controller.selectTab(CostsGainsSettingsTab.semaforo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF60A5FA), AppColors.primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurface.withValues(alpha: 0.56),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurface.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
