import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class CreditCardsSection extends GetView<HomeController> {
  const CreditCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cartoes = controller.cartoes;
      final isVisible = controller.isBalanceVisible.value;
      final totalPagar = cartoes.fold(
        0.0,
        (total, c) => total + (c['fatura'] as double),
      );

      return LayoutBuilder(
        builder: (context, constraints) {
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
                              color: const Color(0xFF6B21A8).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: Color(0xFF6B21A8),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'Cartoes de Credito',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildTab('Faturas Abertas', true),
                      const SizedBox(width: 8),
                      _buildTab('Faturas Fechadas', false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...cartoes.map(
                  (cartao) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCreditCard(cartao, isVisible),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a Pagar',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isVisible
                              ? 'R\$ ${totalPagar.toStringAsFixed(2).replaceAll('.', ',')}'
                              : 'R\$ ....',
                          style: const TextStyle(
                            color: Colors.redAccent,
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

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white38,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCreditCard(Map<String, dynamic> cartao, bool isVisible) {
    final fatura = cartao['fatura'] as double;
    final limite = cartao['limite'] as double;
    final disponivel = cartao['disponivel'] as double;
    final percentual = (fatura / limite).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B21A8).withOpacity(0.25),
            const Color(0xFF6B21A8).withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6B21A8).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: Color(0xFF6B21A8), size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B21A8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CARTAO',
                  style: TextStyle(
                    color: Color(0xFFD8B4FE),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cartao['nome'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Fecha ${cartao['fechamento']}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isVisible
                  ? 'R\$ ${fatura.toStringAsFixed(2).replaceAll('.', ',')}'
                  : 'R\$ ....',
              style: const TextStyle(
                color: AppColors.sand,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVisible
                ? 'Disponivel: R\$ ${disponivel.toStringAsFixed(2).replaceAll('.', ',')}'
                : 'Disponivel: R\$ ....',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
