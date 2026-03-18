import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';
import '../../../../domain/entities/credit_card_entity.dart';

class CreditCardsSection extends StatefulWidget {
  const CreditCardsSection({super.key});

  @override
  State<CreditCardsSection> createState() => _CreditCardsSectionState();
}

class _CreditCardsSectionState extends State<CreditCardsSection> {
  bool _showOpenInvoices = true;

  bool _isInvoiceClosed(CreditCardEntity card) {
    final today = DateTime.now().day;
    // Se o dia atual for maior ou igual ao dia de fechamento, a fatura fechou.
    // Ela continuara aparecendo em 'Fechadas' ate o mes virar ou (no futuro) a fatura ser paga.
    return today >= card.closingDay;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final controller = Get.find<HomeController>();

    return Obx(() {
      final cartoes = controller.cartoes;
      final isVisible = controller.isBalanceVisible.value;
      
      final cartoesFiltrados = cartoes.where((card) {
        final isClosed = _isInvoiceClosed(card);
        return _showOpenInvoices ? !isClosed : isClosed;
      }).toList();

      final totalPagar = cartoesFiltrados.fold(
        0.0,
        (total, c) => total + c.usedLimit,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth < 400
              ? constraints.maxWidth * 0.75
              : constraints.maxWidth < 720
              ? constraints.maxWidth * 0.45
              : 260.0;

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
                  onTap: () => Get.toNamed('/credit-cards'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.violet.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                color: AppColors.violet,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Cartoes de Credito',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showOpenInvoices = true),
                        child: _buildTab('Faturas Abertas', _showOpenInvoices),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showOpenInvoices = false),
                        child: _buildTab('Faturas Fechadas', !_showOpenInvoices),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (cartoesFiltrados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _showOpenInvoices ? 'Nenhuma fatura aberta' : 'Nenhuma fatura fechada',
                      style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                else
                  SizedBox(
                    height: 180, // Aumentado de 160 para 180 para evitar overflow
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cartoesFiltrados.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cartao = cartoesFiltrados[index];
                        return SizedBox(
                          width: cardWidth.clamp(200.0, 280.0),
                          child: _buildCreditCard(context, cartao, isVisible, currencyFormat, _showOpenInvoices),
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
                      _showOpenInvoices ? 'Faturas Totais (Abertas)' : 'Faturas Totais (Fechadas)',
                      style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isVisible
                              ? currencyFormat.format(totalPagar)
                              : 'R\$ ....',
                          style: const TextStyle(
                            color: AppColors.rose,
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
        color: isActive ? context.theme.colorScheme.onSurface.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive ? context.theme.colorScheme.onSurface : context.theme.colorScheme.onSurface.withOpacity(0.38),
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, CreditCardEntity cartao, bool isVisible, NumberFormat currencyFormat, bool isOpenInvoice) {
    final fatura = cartao.usedLimit; // Simulando a fatura com o limite usado. Ficará real no módulo de Transacoes.
    final disponivel = cartao.availableLimit;
    final percentual = cartao.usedPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.violet.withOpacity(0.25),
            AppColors.violet.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.violet.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: AppColors.violet, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.violet.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cartao.brand.toUpperCase(),
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cartao.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            isOpenInvoice ? 'Fecha dia ${cartao.closingDay}' : 'Vence dia ${cartao.dueDay}',
            style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.38), fontSize: 12),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isVisible
                  ? currencyFormat.format(fatura)
                  : 'R\$ ....',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual,
              backgroundColor: context.theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentual > 0.9 ? AppColors.rose : AppColors.violet,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVisible
                ? 'Disponivel: ${currencyFormat.format(disponivel)}'
                : 'Disponivel: R\$ ....',
            style: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.38), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
