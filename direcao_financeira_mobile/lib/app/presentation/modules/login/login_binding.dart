import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/login_use_case.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Agora o Repositório já vem do InitialBinding global
    final authRepository = Get.find<IAuthRepository>();

    // Injeta apenas o que é específico do Login
    final loginUseCase = LoginUseCase(authRepository);

    Get.lazyPut<LoginController>(
      () => LoginController(loginUseCase: loginUseCase),
    );
  }
}
