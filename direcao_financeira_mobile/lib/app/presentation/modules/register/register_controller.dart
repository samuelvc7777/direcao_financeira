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

  // Requisitos de senha (reativos)
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
      Get.snackbar(
        'Erro',
        'Por favor, preencha todos os campos.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!passwordsMatch.value) {
      Get.snackbar(
        'Erro',
        'As senhas não coincidem.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final result = await registerUseCase.execute(name, email, password);
      final userData = result['user'];
      
      // Redireciona direto para o Dashboard (Login Automático)
      Get.offAllNamed('/dashboard');
      
      Get.snackbar(
        'Bem-vindo(a)!',
        'Cadastro realizado! Boas vindas, ${userData['name']}.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Erro no Cadastro',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
