import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        const Icon(Icons.person_add_rounded, size: 80, color: AppColors.teal),
        const SizedBox(height: 16),
        const Text(
          'Criar Conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'Junte-se à elite dos motoristas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
        ),
      ],
    );
  }
}
