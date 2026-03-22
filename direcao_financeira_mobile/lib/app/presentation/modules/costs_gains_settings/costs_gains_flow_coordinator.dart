import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'costs_gains_draft.dart';

abstract final class CostsGainsFlowCoordinator {
  static bool hasRegisteredCosts() => false;

  static void openEntry([CostsGainsDraft? draft]) {
    if (hasRegisteredCosts()) {
      Get.toNamed(AppRoutes.costsGainsSettings, arguments: draft);
      return;
    }

    openWizard(draft);
  }

  static void openWizard([CostsGainsDraft? draft]) {
    Get.toNamed(AppRoutes.costsGainsWizard, arguments: draft);
  }

  static void openResult(CostsGainsDraft draft) {
    Get.toNamed(AppRoutes.costsGainsSettings, arguments: draft);
  }
}
