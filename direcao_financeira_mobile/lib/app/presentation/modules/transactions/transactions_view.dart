import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/scale_button.dart';
import 'transactions_controller.dart';
import 'widgets/transaction_type_selector_sheet.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM', 'pt_BR');

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Transacoes',
        subtitle: 'Seu historico de movimentacoes',
        leadingIcon: Icons.receipt_long_rounded,
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Responsive.hp(context, 4)),
            child: ScaleButton(
              onTap: () {
                Get.bottomSheet(
                  const TransactionTypeSelectorSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hp(context, 3.2),
                  vertical: Responsive.vp(context, 1),
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Responsive.sp(context, 12)),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.teal,
                      size: Responsive.sp(context, 20),
                    ),
                    SizedBox(width: Responsive.hp(context, 1)),
                    Text(
                      'Nova',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.sp(context, 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360
              ? Responsive.hp(context, 3.2)
              : width < 430
                  ? Responsive.hp(context, 4.2)
                  : Responsive.hp(context, 5.2);

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: context.theme.scaffoldBackgroundColor,
            child: Obx(() {
              final transacoes = controller.transactions;

              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.aqua),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: transacoes.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Padding(
                          padding: EdgeInsets.all(Responsive.sp(context, 32)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                size: Responsive.sp(context, 80),
                              ),
                              SizedBox(height: Responsive.vp(context, 3)),
                              Text(
                                'Nenhuma transacao',
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface,
                                  fontSize: Responsive.sp(context, 20),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: Responsive.vp(context, 1.5)),
                              Text(
                                'Sua lista de despesas e receitas aparecera aqui.',
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.5,
                                  fontSize: Responsive.sp(context, 14),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        key: const ValueKey('list'),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          Responsive.vp(context, 2),
                          horizontalPadding,
                          Responsive.vp(context, 12),
                        ),
                        itemCount: transacoes.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: Responsive.vp(context, 1.5)),
                        itemBuilder: (context, index) {
                          final transaction = transacoes[index];
                          return _buildTransactionItem(
                            context,
                            transaction,
                            currencyFormat,
                            dateFormat,
                            constraints.maxWidth,
                          );
                        },
                      ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionEntity transacao,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
    double maxWidth,
  ) {
    final valor = transacao.amount;
    final isNegativo = transacao.type == TransactionType.expense;
    final isCompact = maxWidth < 390;

    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 16)),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLeading(context, isNegativo),
                    SizedBox(width: Responsive.hp(context, 3.5)),
                    Expanded(child: _buildInfo(context, transacao, dateFormat)),
                  ],
                ),
                SizedBox(height: Responsive.vp(context, 1.2)),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildValue(context, valor, isNegativo, currencyFormat),
                ),
              ],
            )
          : Row(
              children: [
                _buildLeading(context, isNegativo),
                SizedBox(width: Responsive.hp(context, 3.5)),
                Expanded(child: _buildInfo(context, transacao, dateFormat)),
                SizedBox(width: Responsive.hp(context, 3)),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildValue(context, valor, isNegativo, currencyFormat),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeading(BuildContext context, bool isNegativo) {
    return Container(
      padding: EdgeInsets.all(Responsive.sp(context, 12)),
      decoration: BoxDecoration(
        color: (isNegativo ? AppColors.rose : AppColors.emerald).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Responsive.sp(context, 14)),
      ),
      child: Icon(
        isNegativo ? Icons.arrow_downward : Icons.arrow_upward,
        color: isNegativo ? AppColors.rose : AppColors.emerald,
        size: Responsive.sp(context, 20),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    TransactionEntity transacao,
    DateFormat dateFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transacao.description,
          style: TextStyle(
            color: context.theme.colorScheme.onSurface,
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.vp(context, 0.5)),
        Text(
          '${transacao.categoryName ?? 'Sem categoria'} - ${dateFormat.format(transacao.transactionDate)}',
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: Responsive.sp(context, 13),
          ),
        ),
      ],
    );
  }

  Widget _buildValue(
    BuildContext context,
    double valor,
    bool isNegativo,
    NumberFormat currencyFormat,
  ) {
    return Text(
      '${isNegativo ? '- ' : '+ '}${currencyFormat.format(valor)}',
      style: TextStyle(
        color: isNegativo ? AppColors.rose : AppColors.emerald,
        fontSize: Responsive.sp(context, 16),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
