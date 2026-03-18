import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home_view.dart';
import '../transactions/transactions_view.dart';
import '../settings/settings_view.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'initial_controller.dart';

class InitialView extends GetView<InitialController> {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeView(),
      const TransactionsView(),
      const Center(
        child: Text('Orcamento', style: TextStyle(color: Colors.white)),
      ),
      const Center(
        child: Text('Veiculo', style: TextStyle(color: Colors.white)),
      ),
      const SettingsView(),
    ];

    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
