import 'package:get/get.dart';

import '../home/home_binding.dart';
import '../settings/settings_binding.dart';
import '../transactions/transactions_binding.dart';
import 'initial_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitialController>(() => InitialController());

    HomeBinding().dependencies();
    TransactionsBinding().dependencies();
    SettingsBinding().dependencies();
  }
}
