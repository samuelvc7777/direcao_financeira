import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/scale_button.dart';
import '../home/home_controller.dart';
import 'transactions_controller.dart';
import 'widgets/transaction_type_selector_sheet.dart';
import '../../../domain/entities/transaction_entity.dart';

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
            padding: const EdgeInsets.only(right: 16),
            child: ScaleButton(
              onTap: () {
                Get.bottomSheet(
                  const TransactionTypeSelectorSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.teal, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Nova',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
              ? 12.0
              : width < 430
              ? 16.0
              : 20.0;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
            ),
            child: Obx(() {
              final homeController = Get.find<HomeController>();
              final transacoes = homeController.ultimasTransacoes;

              if (homeController.isLoading.value) {
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
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                color: context.theme.colorScheme.onSurface
                                    .withOpacity(0.1),
                                size: 80,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nenhuma transacao',
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sua lista de despesas e receitas aparecera aqui.',
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  height: 1.5,
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
                          16,
                          horizontalPadding,
                          100,
                        ),
                        itemCount: transacoes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final t = transacoes[index];
                          return _buildTransactionItem(
                            context,
                            t,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLeading(isNegativo),
                    const SizedBox(width: 14),
                    Expanded(child: _buildInfo(context, transacao, dateFormat)),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildValue(valor, isNegativo, currencyFormat),
                ),
              ],
            )
          : Row(
              children: [
                _buildLeading(isNegativo),
                const SizedBox(width: 14),
                Expanded(child: _buildInfo(context, transacao, dateFormat)),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _buildValue(valor, isNegativo, currencyFormat),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeading(bool isNegativo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isNegativo ? AppColors.rose : AppColors.emerald).withOpacity(
          0.15,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isNegativo ? Icons.arrow_downward : Icons.arrow_upward,
        color: isNegativo ? AppColors.rose : AppColors.emerald,
        size: 20,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${transacao.categoryName ?? 'Sem categoria'} • ${dateFormat.format(transacao.transactionDate)}',
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildValue(
    double valor,
    bool isNegativo,
    NumberFormat currencyFormat,
  ) {
    return Text(
      '${isNegativo ? '- ' : '+ '}${currencyFormat.format(valor)}',
      style: TextStyle(
        color: isNegativo ? AppColors.rose : AppColors.emerald,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
