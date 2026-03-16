import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(authRepository: Get.find<IAuthRepository>()),
    );
  }
}
