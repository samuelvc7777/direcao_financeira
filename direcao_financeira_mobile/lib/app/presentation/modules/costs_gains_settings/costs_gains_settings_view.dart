import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import 'costs_gains_settings_controller.dart';
import 'widgets/costs_gains_settings_costs_tab.dart';
import 'widgets/costs_gains_settings_result_tab.dart';
import 'widgets/costs_gains_settings_tab_switcher.dart';

class CostsGainsSettingsView extends GetView<CostsGainsSettingsController> {
  const CostsGainsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Configurações', showBackButton: true),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width < 360
                ? 10.0
                : width < 430
                ? 14.0
                : 18.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                6,
                horizontalPadding,
                18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CostsGainsSettingsTabSwitcher(controller: controller),
                      const SizedBox(height: 10),
                      Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child:
                              controller.selectedTab.value ==
                                  CostsGainsSettingsTab.resultado
                              ? CostsGainsSettingsResultTab(
                                  key: const ValueKey('resultado'),
                                  controller: controller,
                                )
                              : CostsGainsSettingsCostsTab(
                                  key: const ValueKey('semaforo'),
                                  controller: controller,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
