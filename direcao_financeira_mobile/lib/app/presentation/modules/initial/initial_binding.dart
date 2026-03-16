import 'package:get/get.dart';
import 'initial_controller.dart';
import '../home/home_controller.dart';
import '../settings/settings_controller.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Injeta o controlador do módulo Initial
    Get.lazyPut<InitialController>(() => InitialController());

    // Injeta o controlador do módulo Home, já que ele será a primeira aba
    Get.lazyPut<HomeController>(
      () => HomeController(authRepository: Get.find<IAuthRepository>()),
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(authRepository: Get.find<IAuthRepository>()),
    );
  }
}
