import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../settings_controller.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERSONALIZACAO',
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.royalBlue.withValues(alpha: 0.96),
                        AppColors.electricCyan.withValues(alpha: 0.88),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.royalBlue.withValues(alpha: 0.20),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.dark_mode_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema ',
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.isDarkModeEnabled.value
                            ? 'Toque para mudar para claro'
                            : 'Toque para mudar para escuro',
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.62,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.isDarkModeEnabled.value,
                  onChanged: controller.toggleTheme,
                  activeThumbColor: AppColors.aqua,
                  activeTrackColor: AppColors.royalBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                  inactiveTrackColor: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
