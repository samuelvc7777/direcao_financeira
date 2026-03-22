import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';

import '../../../domain/usecases/register_use_case.dart';
import 'register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RegisterUseCase>()) {
      Get.lazyPut(
        () => RegisterUseCase(Get.find<IAuthRepository>()),
        fenix: true,
      );
    }

    Get.lazyPut<RegisterController>(
      () => RegisterController(registerUseCase: Get.find<RegisterUseCase>()),
      fenix: true,
    );
  }
}
