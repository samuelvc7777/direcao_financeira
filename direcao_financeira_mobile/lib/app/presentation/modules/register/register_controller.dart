import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/usecases/register_use_case.dart';

class RegisterController extends GetxController {
  final RegisterUseCase registerUseCase;

  RegisterController({required this.registerUseCase});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  var hasMinLength = false.obs;
  var hasUppercase = false.obs;
  var hasLowercase = false.obs;
  var hasSpecial = false.obs;
  var passwordsMatch = false.obs;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    hasMinLength.value = password.length >= 8;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    hasSpecial.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    passwordsMatch.value = password.isNotEmpty && password == confirmPassword;
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Erro', 'Por favor, preencha todos os campos.');
      return;
    }

    if (!passwordsMatch.value) {
      _showError('Erro', 'As senhas não coincidem.');
      return;
    }

    isLoading.value = true;
    final result = await registerUseCase.execute(name, email, password);
    isLoading.value = false;

    result.fold(
      (failure) => _showError('Erro no Cadastro', failure.message),
      (data) {
        final userData = data['user'];
        Get.offAllNamed('/initial');
        Get.snackbar(
          'Bem-vindo(a)!',
          'Cadastro realizado! Boas vindas, ${userData['name']}.',
          backgroundColor: const Color(0xFF03A696).withOpacity(0.12),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFBF4124).withOpacity(0.12),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
