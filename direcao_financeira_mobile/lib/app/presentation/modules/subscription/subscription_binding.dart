import 'package:get/get.dart';

import '../../../domain/repositories/i_subscription_repository.dart';
import 'subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(
      () => SubscriptionController(
        subscriptionRepository: Get.find<ISubscriptionRepository>(),
      ),
    );
  }
}
