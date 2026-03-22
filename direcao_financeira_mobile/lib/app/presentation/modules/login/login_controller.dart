import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../domain/usecases/login_use_case.dart';
import '../../../core/network/connection_controller.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

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

    debugPrint('LoginController.login() - Iniciando tentativa de login para o email: $email');

    if (email.isEmpty || password.isEmpty) {
      debugPrint('LoginController.login() - Falha: Campos vazios');
      _showError('Campos Vazios', 'Por favor, preencha e-mail e senha.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      debugPrint('LoginController.login() - Falha: Email inválido ($email)');
      _showError('E-mail Inválido', 'O formato do e-mail não é válido.');
      return;
    }

    isLoading.value = true;
    debugPrint('LoginController.login() - Chamando loginUseCase.execute');
    final result = await loginUseCase.execute(email, password);
    isLoading.value = false;

    result.fold(
      (failure) {
        debugPrint('LoginController.login() - Falha no caso de uso: ${failure.message}');
        _showError('Erro no Login', failure.message);
      },
      (user) {
        debugPrint('LoginController.login() - Login bem-sucedido. Usuário: ${user.name}');
        final storage = Get.find<GetStorage>();
        final token = storage.read('token');
        if (token != null) {
          debugPrint('LoginController.login() - Token encontrado no storage. Conectando com token.');
          Get.find<ConnectionController>().connectWithToken(token);
        } else {
          debugPrint('LoginController.login() - ALERTA: Token não encontrado no storage após login bem sucedido!');
        }

        Get.offAllNamed('/initial');
        Get.snackbar(
          'Sucesso',
          'Bem-vindo(a), ${user.name}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF03A696).withValues(alpha: 0.12),
          colorText: Colors.white,
        );
      },
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFBF4124).withValues(alpha: 0.12),
      colorText: Colors.white,
    );
  }
}
