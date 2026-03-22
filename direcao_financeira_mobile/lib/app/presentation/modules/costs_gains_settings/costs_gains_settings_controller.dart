import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../routes/app_pages.dart';
import 'costs_gains_draft.dart';
import 'costs_gains_flow_coordinator.dart';

enum CostsGainsSettingsTab { resultado, semaforo }

class CostsGainsSettingsController extends GetxController {
  final selectedTab = CostsGainsSettingsTab.resultado.obs;
  late final CostsGainsDraft draft;

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    draft = argument is CostsGainsDraft ? argument : CostsGainsDraft.defaults();
  }

  double get monthlyGoal => draft.grossMonthlyGoal;
  double get targetNetProfit => draft.desiredNetProfit;
  double get weeklyTarget => draft.weeklyTarget;
  double get dailyTarget => draft.dailyTarget;
  double get perKmTarget => draft.perKmTarget;
  double get perHourTarget => draft.perHourTarget;
  double get fixedMonthlyCosts => draft.fixedMonthlyCosts;
  double get estimatedFuel => draft.estimatedFuel;
  double get platformFee => draft.platformFeeAmount;
  double get totalCosts => draft.totalCosts;
  String get platformLabel => draft.platformLabel;

  void selectTab(CostsGainsSettingsTab tab) {
    selectedTab.value = tab;
  }

  void applyToTrafficLight() {
    selectedTab.value = CostsGainsSettingsTab.semaforo;
    _showInfo(
      'Semaforo preparado',
      'Visual de custos aplicado na aba de semaforo para esta demonstracao.',
    );
  }

  void openTrafficLightSettings() {
    Get.toNamed(AppRoutes.trafficLightSettings);
  }

  void openAdjustCosts() {
    CostsGainsFlowCoordinator.openWizard(draft);
  }

  void _showInfo(String title, String message) {
    AppSnackbar.show(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
