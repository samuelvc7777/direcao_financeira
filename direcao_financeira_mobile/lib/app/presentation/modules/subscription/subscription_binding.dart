import 'package:get/get.dart';

import '../../../domain/repositories/i_subscription_repository.dart';
import '../../../domain/usecases/subscription_use_cases.dart';
import 'subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetMySubscriptionUseCase>()) {
      Get.lazyPut(
        () => GetMySubscriptionUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetSubscriptionHistoryUseCase>()) {
      Get.lazyPut(
        () => GetSubscriptionHistoryUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetAvailablePlansUseCase>()) {
      Get.lazyPut(
        () => GetAvailablePlansUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ChangePlanUseCase>()) {
      Get.lazyPut(
        () => ChangePlanUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CancelSubscriptionUseCase>()) {
      Get.lazyPut(
        () => CancelSubscriptionUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RenewSubscriptionUseCase>()) {
      Get.lazyPut(
        () => RenewSubscriptionUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SyncStoredUserSubscriptionUseCase>()) {
      Get.lazyPut(
        () => SyncStoredUserSubscriptionUseCase(Get.find<ISubscriptionRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SubscriptionController>()) {
      Get.lazyPut<SubscriptionController>(
        () => SubscriptionController(
          getMySubscriptionUseCase: Get.find<GetMySubscriptionUseCase>(),
          getSubscriptionHistoryUseCase: Get.find<GetSubscriptionHistoryUseCase>(),
          getAvailablePlansUseCase: Get.find<GetAvailablePlansUseCase>(),
          changePlanUseCase: Get.find<ChangePlanUseCase>(),
          cancelSubscriptionUseCase: Get.find<CancelSubscriptionUseCase>(),
          renewSubscriptionUseCase: Get.find<RenewSubscriptionUseCase>(),
          syncStoredUserSubscriptionUseCase: Get.find<SyncStoredUserSubscriptionUseCase>(),
        ),
      );
    }
  }
}
