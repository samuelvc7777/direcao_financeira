import 'package:get/get.dart';

import 'costs_gains_wizard_controller.dart';

class CostsGainsWizardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CostsGainsWizardController>()) {
      Get.lazyPut<CostsGainsWizardController>(CostsGainsWizardController.new);
    }
  }
}
