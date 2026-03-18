import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';
import '../../../../domain/entities/bank_account_entity.dart';

class AccountsSection extends GetView<HomeController> {
  const AccountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

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
              color: context.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.theme.colorScheme.onSurface.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/bank-accounts'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
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
                                Icons.account_balance,
                                color: AppColors.electricCyan,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Minhas Contas',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface,
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
                          color: context.theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: context.theme.colorScheme.onSurface.withOpacity(0.38),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (contas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Nenhuma conta ativa',
                      style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                else
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
                            context: context,
                            nome: conta.name,
                            tipo: conta.accountType.label,
                            saldo: conta.currentBalance,
                            icon: _getIconForType(conta.accountType),
                            cor: AppColors.electricCyan,
                            isVisible: isVisible,
                            currencyFormat: currencyFormat,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Divider(color: context.theme.colorScheme.onSurface.withOpacity(0.08)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Total',
                      style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isVisible
                              ? currencyFormat.format(saldoTotal)
                              : 'R\$ ....',
                          style: const TextStyle(
                            color: AppColors.electricCyan,
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
    required BuildContext context,
    required String nome,
    required String tipo,
    required double saldo,
    required IconData icon,
    required Color cor,
    required bool isVisible,
    required NumberFormat currencyFormat,
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
                  tipo.toUpperCase(),
                  style: TextStyle(
                    color: cor,
                    fontSize: 9,
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
            style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isVisible
                  ? currencyFormat.format(saldo)
                  : 'R\$ ....',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance_rounded;
      case AccountType.savings:
        return Icons.savings_rounded;
      case AccountType.wallet:
        return Icons.wallet_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.other:
        return Icons.help_outline_rounded;
    }
  }
}
