import 'package:get/get.dart';

import 'costs_gains_settings_controller.dart';

class CostsGainsSettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CostsGainsSettingsController>()) {
      Get.lazyPut<CostsGainsSettingsController>(
        CostsGainsSettingsController.new,
      );
    }
  }
}
