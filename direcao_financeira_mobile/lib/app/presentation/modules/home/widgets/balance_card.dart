import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class BalanceCard extends GetView<HomeController> {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVisible = controller.isBalanceVisible.value;
      final saldo = controller.saldoAtual.value;
      final entradas = controller.entradas.value;
      final saidas = controller.saidas.value;
      final isPositivo = controller.isSaldoPositivo;

      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final amountFontSize = isCompact
              ? 28.0
              : constraints.maxWidth < 430
              ? 32.0
              : 34.0;
          final metricsWidth = constraints.maxWidth < 430
              ? constraints.maxWidth
              : (constraints.maxWidth - 12) / 2;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(isCompact ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceDark,
                  AppColors.petrol.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.teal.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.teal,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'Saldo Atual',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white38,
                        size: 22,
                      ),
                      onPressed: controller.toggleBalanceVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isVisible
                        ? 'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'R\$ .......',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: amountFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPositivo
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositivo ? Icons.trending_up : Icons.trending_down,
                        color: isPositivo
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPositivo ? 'Positivo' : 'Negativo',
                        style: TextStyle(
                          color: isPositivo
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: metricsWidth,
                      child: _buildIndicator(
                        icon: Icons.arrow_upward,
                        label: 'Entradas',
                        value: entradas,
                        color: Colors.greenAccent,
                        isVisible: isVisible,
                      ),
                    ),
                    SizedBox(
                      width: metricsWidth,
                      child: _buildIndicator(
                        icon: Icons.arrow_downward,
                        label: 'Saidas',
                        value: saidas,
                        color: Colors.redAccent,
                        isVisible: isVisible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildIndicator({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required bool isVisible,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  isVisible
                      ? 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}'
                      : 'R\$ ....',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
