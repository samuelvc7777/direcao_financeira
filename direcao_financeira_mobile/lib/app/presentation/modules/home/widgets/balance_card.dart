import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class BalanceCard extends GetView<HomeController> {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Obx(() {
      final isVisible = controller.isBalanceVisible.value;
      final saldo = controller.saldoTotal;
      final entradas = controller.entradas; // Sera real no proximo modulo
      final saidas = controller.saidas;     // Sera real no proximo modulo
      final isPositivo = controller.isSaldoPositivo;

      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final amountFontSize = isCompact
              ? 28.0
              : constraints.maxWidth < 430
              ? 32.0
              : 34.0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(isCompact ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.theme.colorScheme.surface,
                    context.theme.scaffoldBackgroundColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.royalBlue.withOpacity(0.15)),
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
                              color: AppColors.electricCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.electricCyan,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Saldo Atual',
                              overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface.withOpacity(0.7),
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
                        color: context.theme.colorScheme.onSurface.withOpacity(0.38),
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
                        ? currencyFormat.format(saldo)
                        : 'R\$ .......',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface,
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
                        ? AppColors.emerald.withOpacity(0.15)
                        : AppColors.rose.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositivo ? Icons.trending_up : Icons.trending_down,
                        color: isPositivo
                            ? AppColors.emerald
                            : AppColors.rose,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPositivo ? 'Positivo' : 'Negativo',
                        style: TextStyle(
                          color: isPositivo
                              ? AppColors.emerald
                              : AppColors.rose,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: context.theme.colorScheme.onSurface.withOpacity(0.08)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicator(
                        context: context,
                        icon: Icons.arrow_upward,
                        label: 'Entradas',
                        value: entradas,
                        color: AppColors.emerald,
                        isVisible: isVisible,
                        currencyFormat: currencyFormat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIndicator(
                        context: context,
                        icon: Icons.arrow_downward,
                        label: 'Saidas',
                        value: saidas,
                        color: AppColors.rose,
                        isVisible: isVisible,
                        currencyFormat: currencyFormat,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required bool isVisible,
    required NumberFormat currencyFormat,
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
                style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 12),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  isVisible
                      ? currencyFormat.format(value)
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
