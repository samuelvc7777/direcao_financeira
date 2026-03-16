import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';
import '../../../domain/usecases/register_use_case.dart';
import 'register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Agora o Repositório já vem do InitialBinding global
    final authRepository = Get.find<IAuthRepository>();

    final registerUseCase = RegisterUseCase(authRepository);
    
    Get.lazyPut<RegisterController>(
      () => RegisterController(registerUseCase: registerUseCase),
    );
  }
}
