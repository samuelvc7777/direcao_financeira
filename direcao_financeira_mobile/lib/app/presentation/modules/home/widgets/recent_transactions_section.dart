import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class RecentTransactionsSection extends GetView<HomeController> {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transacoes = controller.ultimasTransacoes;
      final isVisible = controller.isBalanceVisible.value;

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
                          Icons.receipt_long,
                          color: AppColors.teal,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'Ultimas Transacoes',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.teal.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...transacoes.map((t) => _buildTransactionItem(t, isVisible)),
            if (transacoes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Nenhuma transacao registrada.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTransactionItem(Map<String, dynamic> transacao, bool isVisible) {
    final valor = transacao['valor'] as double;
    final isNegativo = valor < 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildLeading(isNegativo),
                        const SizedBox(width: 14),
                        Expanded(child: _buildInfo(transacao)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildValue(valor, isNegativo, isVisible),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _buildLeading(isNegativo),
                    const SizedBox(width: 14),
                    Expanded(child: _buildInfo(transacao)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildValue(valor, isNegativo, isVisible),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLeading(bool isNegativo) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isNegativo ? Colors.redAccent : Colors.greenAccent).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isNegativo ? Icons.arrow_downward : Icons.arrow_upward,
        color: isNegativo ? Colors.redAccent : Colors.greenAccent,
        size: 18,
      ),
    );
  }

  Widget _buildInfo(Map<String, dynamic> transacao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transacao['titulo'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${transacao['categoria']} • ${transacao['data']} • ${transacao['hora']}',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildValue(double valor, bool isNegativo, bool isVisible) {
    return Text(
      isVisible
          ? '${isNegativo ? '- ' : '+ '}R\$ ${valor.abs().toStringAsFixed(2).replaceAll('.', ',')}'
          : 'R\$ ....',
      style: TextStyle(
        color: isNegativo ? Colors.redAccent : Colors.greenAccent,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
