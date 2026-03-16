import 'package:direcao_financeira_mobile/app/domain/usecases/login_use_case.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  // Observáveis reativos
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validação local básica
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Campos Vazios',
        'Por favor, preencha e-mail e senha.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[900],
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'E-mail Inválido',
        'O formato do e-mail não é válido.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await loginUseCase.execute(email, password);

      // Redireciona para o dashboard em caso de sucesso
      Get.offAllNamed('/dashboard');
      Get.snackbar(
        'Sucesso',
        'Bem-vindo(a), ${user.name}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar(
        'Erro no Login',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
