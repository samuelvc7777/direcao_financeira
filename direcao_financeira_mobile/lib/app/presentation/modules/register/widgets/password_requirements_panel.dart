import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../register_controller.dart';

class PasswordRequirementsPanel extends GetView<RegisterController> {
  const PasswordRequirementsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementItem('Mínimo 8 caracteres', controller.hasMinLength.value),
        _buildRequirementItem('Uma letra maiúscula', controller.hasUppercase.value),
        _buildRequirementItem('Uma letra minúscula', controller.hasLowercase.value),
        _buildRequirementItem('Um símbolo especial (@, #, \$...)', controller.hasSpecial.value),
        _buildRequirementItem('As senhas são idênticas', controller.passwordsMatch.value),
      ],
    ));
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? Colors.greenAccent : Colors.white24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.white : Colors.white38,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
