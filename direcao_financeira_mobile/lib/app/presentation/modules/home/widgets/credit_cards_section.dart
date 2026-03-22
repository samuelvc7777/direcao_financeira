import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';
import '../../../../domain/entities/credit_card_entity.dart';
import '../../../../core/utils/responsive.dart';

class CreditCardsSection extends StatefulWidget {
  const CreditCardsSection({super.key, required this.controller});

  final HomeController controller;

  @override
  State<CreditCardsSection> createState() => _CreditCardsSectionState();
}

class _CreditCardsSectionState extends State<CreditCardsSection> {
  bool _showOpenInvoices = true;

  bool _isInvoiceClosed(CreditCardEntity card) {
    final today = DateTime.now().day;
    return today >= card.closingDay;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final controller = widget.controller;

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
          final sectionPadding = Responsive.hp(context, 2.1).clamp(8.0, 10.0);
          final titleSize = Responsive.sp(context, 16).clamp(15.0, 16.0);
          final titleGap = Responsive.hp(context, 1.8).clamp(6.0, 8.0);
          final iconBoxSize = Responsive.hp(context, 7.4).clamp(28.0, 32.0);
          final arrowBoxSize = Responsive.hp(context, 6.4).clamp(24.0, 28.0);
          final sectionRadius = Responsive.hp(context, 4.8).clamp(16.0, 18.0);
          final contentGap = Responsive.vp(context, 1).clamp(6.0, 8.0);
          final listGap = Responsive.hp(context, 2.8).clamp(10.0, 12.0);

          final cardWidth = constraints.maxWidth < 400
              ? constraints.maxWidth * 0.75
              : constraints.maxWidth < 720
              ? constraints.maxWidth * 0.45
              : 260.0;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(sectionPadding),
            decoration: BoxDecoration(
              color: const Color(0xFF1F222B),
              borderRadius: BorderRadius.circular(sectionRadius),
              border: Border.all(color: const Color(0xFF2F4367)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => Get.toNamed('/credit-cards'),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 1,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4C2A77,
                            ), // Violet shade for Credit Cards
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.credit_card_rounded,
                            size: Responsive.sp(context, 16).clamp(15.0, 17.0),
                            color: const Color(0xFFD4A5FF),
                          ),
                        ),
                        SizedBox(width: titleGap),
                        Expanded(
                          child: Text(
                            'Cartões de Crédito',
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurface,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: arrowBoxSize,
                          height: arrowBoxSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF24364E),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: Responsive.sp(context, 16).clamp(15.0, 17.0),
                            color: const Color(0xFF78AFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: contentGap),
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
                        child: _buildTab(
                          'Faturas Fechadas',
                          !_showOpenInvoices,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: contentGap),
                if (cartoesFiltrados.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.vp(context, 3).clamp(18.0, 24.0),
                    ),
                    child: Text(
                      _showOpenInvoices
                          ? 'Nenhuma fatura aberta'
                          : 'Nenhuma fatura fechada',
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: Responsive.sp(context, 14).clamp(13.0, 14.0),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cartoesFiltrados.length,
                      separatorBuilder: (_, itemIndex) =>
                          SizedBox(width: listGap),
                      itemBuilder: (context, index) {
                        final cartao = cartoesFiltrados[index];
                        return SizedBox(
                          width: cardWidth.clamp(200.0, 280.0),
                          child: _buildCreditCard(
                            context,
                            cartao,
                            isVisible,
                            currencyFormat,
                            _showOpenInvoices,
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: contentGap),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                SizedBox(height: contentGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showOpenInvoices
                          ? 'Faturas Totais (Abertas)'
                          : 'Faturas Totais (Fechadas)',
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                        fontSize: Responsive.sp(context, 13).clamp(12.0, 13.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isVisible
                              ? currencyFormat.format(totalPagar)
                              : 'R\$ ....',
                          style: TextStyle(
                            color: AppColors.rose,
                            fontSize: Responsive.sp(
                              context,
                              14,
                            ).clamp(13.0, 14.0),
                            fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF24364E) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: const Color(0xFF2F4367)) : null,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isActive
              ? context.theme.colorScheme.onSurface
              : context.theme.colorScheme.onSurface.withValues(alpha: 0.38),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCreditCard(
    BuildContext context,
    CreditCardEntity cartao,
    bool isVisible,
    NumberFormat currencyFormat,
    bool isOpenInvoice,
  ) {
    final fatura = cartao
        .usedLimit; // Simulando a fatura com o limite usado. Ficará real no módulo de Transacoes.
    final disponivel = cartao.availableLimit;
    final percentual = cartao.usedPercentage;
    final cardColor = _parseColor(cartao.color);

    final cardPadding = Responsive.hp(context, 3.2).clamp(10.0, 12.0);
    final cardRadius = Responsive.hp(context, 4.3).clamp(14.0, 16.0);
    final iconBoxSize = Responsive.hp(context, 6.9).clamp(24.0, 26.0);
    final badgeHorizontal = Responsive.hp(context, 2.1).clamp(7.0, 8.0);
    final badgeVertical = Responsive.vp(context, 0.4).clamp(3.0, 4.0);
    final nameSize = Responsive.sp(context, 14).clamp(13.0, 14.0);
    final valueSize = Responsive.sp(context, 15).clamp(14.0, 15.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.16),
            cardColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: cardColor.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  size: Responsive.sp(context, 15).clamp(14.0, 15.0),
                  color: cardColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: badgeHorizontal,
                  vertical: badgeVertical,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cartao.brand.toUpperCase(),
                  style: TextStyle(
                    color: cardColor,
                    fontSize: Responsive.sp(context, 8).clamp(7.0, 8.0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            cartao.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.86,
              ),
              fontSize: nameSize,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          Text(
            isOpenInvoice
                ? 'Fecha dia ${cartao.closingDay}'
                : 'Vence dia ${cartao.dueDay}',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              fontSize: Responsive.sp(context, 10).clamp(9.0, 10.0),
            ),
          ),
          SizedBox(height: Responsive.vp(context, 0.5).clamp(4.0, 6.0)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isVisible ? currencyFormat.format(fatura) : 'R\$ ....',
              style: TextStyle(
                color: context.theme.colorScheme.onSurface,
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: Responsive.vp(context, 0.5).clamp(4.0, 6.0)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentual > 0.9 ? AppColors.rose : cardColor,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isVisible
                ? 'Lim: ${currencyFormat.format(disponivel)}'
                : 'Lim: R\$ ....',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              fontSize: Responsive.sp(context, 9).clamp(8.0, 9.0),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    final normalized = colorHex.replaceFirst('#', '');
    if (normalized.length != 6) {
      return AppColors.violet;
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }
}
