import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/feedback/app_snackbar.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController({required this.loginUseCase});

  final LoginUseCase loginUseCase;
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
      _showError('E-mail Invalido', 'O formato do e-mail nao e valido.');
      return;
    }

    isLoading.value = true;
    final result = await loginUseCase.execute(email, password);
    isLoading.value = false;

    result.fold((failure) => _showError('Erro no Login', failure.message), (
      user,
    ) {
      Get.offAllNamed(AppRoutes.initial);
      AppSnackbar.show(
        'Sucesso',
        'Bem-vindo(a), ${user.name}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF03A696).withValues(alpha: 0.12),
        colorText: Colors.white,
      );
    });
  }

  void _showError(String title, String message) {
    AppSnackbar.show(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFBF4124).withValues(alpha: 0.12),
      colorText: Colors.white,
    );
  }
}
