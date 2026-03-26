import 'package:get/get.dart';

import '../../../core/dashboard/dashboard_refresh_notifier.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';
import 'credit_cards_controller.dart';

class CreditCardsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LoadCreditCardsUseCase>()) {
      Get.lazyPut(
        () => LoadCreditCardsUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CreateCreditCardUseCase>()) {
      Get.lazyPut(
        () => CreateCreditCardUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<UpdateCreditCardUseCase>()) {
      Get.lazyPut(
        () => UpdateCreditCardUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DeactivateCreditCardUseCase>()) {
      Get.lazyPut(
        () => DeactivateCreditCardUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ReactivateCreditCardUseCase>()) {
      Get.lazyPut(
        () => ReactivateCreditCardUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CreditCardsController>()) {
      Get.lazyPut<CreditCardsController>(
        () => CreditCardsController(
          loadCreditCardsUseCase: Get.find<LoadCreditCardsUseCase>(),
          createCreditCardUseCase: Get.find<CreateCreditCardUseCase>(),
          updateCreditCardUseCase: Get.find<UpdateCreditCardUseCase>(),
          deactivateCreditCardUseCase: Get.find<DeactivateCreditCardUseCase>(),
          reactivateCreditCardUseCase: Get.find<ReactivateCreditCardUseCase>(),
          dashboardRefreshNotifier: Get.find<DashboardRefreshNotifier>(),
        ),
      );
    }
  }
}
