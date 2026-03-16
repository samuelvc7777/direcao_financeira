import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class AccountsSection extends GetView<HomeController> {
  const AccountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final contas = controller.contas;
      final saldoTotal = controller.saldoTotal;
      final isVisible = controller.isBalanceVisible.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth < 400
              ? constraints.maxWidth * 0.72
              : constraints.maxWidth < 720
              ? constraints.maxWidth * 0.44
              : 220.0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Row(
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
                              Icons.account_balance,
                              color: AppColors.teal,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'Minhas Contas',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white38,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 124,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: contas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final conta = contas[index];
                      return SizedBox(
                        width: cardWidth.clamp(160.0, 240.0),
                        child: _buildAccountCard(
                          nome: conta['nome'],
                          tipo: conta['tipo'],
                          saldo: conta['saldo'],
                          icon: conta['icon'],
                          cor: conta['cor'],
                          isVisible: isVisible,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo Total',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isVisible
                              ? 'R\$ ${saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}'
                              : 'R\$ ....',
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildAccountCard({
    required String nome,
    required String tipo,
    required double saldo,
    required IconData icon,
    required Color cor,
    required bool isVisible,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: cor, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tipo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isVisible
                  ? 'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}'
                  : 'R\$ ....',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
