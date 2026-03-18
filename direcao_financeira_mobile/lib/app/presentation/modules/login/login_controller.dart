import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../domain/usecases/login_use_case.dart';

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

    if (email.isEmpty || password.isEmpty) {
      _showError('Campos Vazios', 'Por favor, preencha e-mail e senha.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('E-mail Inválido', 'O formato do e-mail não é válido.');
      return;
    }

    isLoading.value = true;
    final result = await loginUseCase.execute(email, password);
    isLoading.value = false;

    result.fold(
      (failure) => _showError('Erro no Login', failure.message),
      (user) {
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
