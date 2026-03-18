import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import 'settings_controller.dart';
import 'widgets/settings_profile_card.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/settings_switch_tile.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Ajustes',
        subtitle: 'Configuracoes do app',
        leadingIcon: Icons.settings_rounded,
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360
              ? 12.0
              : width < 430
              ? 16.0
              : 20.0;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  100,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsProfileCard(controller: controller),
                        const SizedBox(height: 22),
                        Column(
                          children: controller.sections
                              .map(
                                (section) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: SettingsSectionCard(
                                    title: section.title,
                                    items: section.items,
                                    onItemTap: controller.openSettingItem,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                        SettingsSwitchTile(controller: controller),
                        const SizedBox(height: 24),
                        _LogoutCard(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTA',
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: controller.logout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.rose.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.rose,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Sair da conta',
                    style: TextStyle(
                      color: AppColors.rose,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.rust.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
