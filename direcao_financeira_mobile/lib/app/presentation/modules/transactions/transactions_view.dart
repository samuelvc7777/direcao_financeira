import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/app_month_selector.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/custom_app_bar.dart';
import 'transactions_controller.dart';
import 'widgets/transaction_type_selector_sheet.dart';
import 'widgets/transactions_day_group_section.dart';
import 'widgets/transactions_empty_state.dart';
import 'widgets/transactions_filter_tabs.dart';
import 'widgets/transactions_summary_cards.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: Obx(
          () => CustomAppBar(
            title: 'Transações',
            subtitle: controller.selectedMonthSubtitle,
            leadingIcon: Icons.receipt_long_rounded,
            showBackButton: false,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateTransactionFlow,
        backgroundColor: colorScheme.primary,
        elevation: 8,
        child: Icon(Icons.add_rounded, color: colorScheme.onPrimary, size: 28),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingScreen(
            label: 'Carregando transações',
            accentColor: AppColors.violet,
          );
        }

        final currencyFormat = NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$ ',
        );
        final compactCurrencyFormat = NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$ ',
          decimalDigits: 0,
        );
        final groups = controller.groupedVisibleTransactions;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final horizontalPadding = isWide
                ? 0.0
                : Responsive.hp(context, 4.8).clamp(16.0, 18.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    Responsive.vp(context, 18).clamp(132.0, 148.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppMonthSelector(
                        label: controller.selectedMonthLabelUppercase,
                        onPrevious: controller.goToPreviousMonth,
                        onNext: controller.goToNextMonth,
                      ),
                      SizedBox(
                        height: Responsive.vp(context, 1.2).clamp(8.0, 10.0),
                      ),
                      TransactionsSummaryCards(
                        incomeAmount: currencyFormat.format(
                          controller.totalIncomeCents / 100,
                        ),
                        expenseAmount: currencyFormat.format(
                          controller.totalExpenseCents / 100,
                        ),
                        balanceAmount: currencyFormat.format(
                          controller.balanceCents / 100,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.vp(context, 2.2).clamp(16.0, 18.0),
                      ),
                      TransactionsFilterTabs(
                        selectedFilter: controller.selectedFilter.value,
                        onChanged: controller.changeFilter,
                      ),
                      SizedBox(
                        height: Responsive.vp(context, 3).clamp(20.0, 24.0),
                      ),
                      if (groups.isEmpty)
                        TransactionsEmptyState(
                          monthLabel: controller.selectedMonthSubtitle,
                          hasTransactionsLoaded:
                              controller.transactions.isNotEmpty,
                        )
                      else
                        Column(
                          children: [
                            for (
                              var index = 0;
                              index < groups.length;
                              index++
                            ) ...[
                              TransactionsDayGroupSection(
                                group: groups[index],
                                amountFormat: currencyFormat,
                                compactAmountFormat: compactCurrencyFormat,
                                onEdit: _onEditTransaction,
                                onDelete: _onDeleteTransaction,
                              ),
                              if (index != groups.length - 1)
                                SizedBox(
                                  height: Responsive.vp(
                                    context,
                                    2.2,
                                  ).clamp(16.0, 18.0),
                                ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _openCreateTransactionFlow() {
    Get.bottomSheet(
      const TransactionTypeSelectorSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _onEditTransaction(TransactionEntity transaction) {
    if (transaction.assetType == AssetType.creditCard) {
      Get.toNamed(AppRoutes.transactionCreditCard, arguments: transaction);
    } else {
      Get.toNamed(AppRoutes.transactionExpense, arguments: transaction);
    }
  }

  void _onDeleteTransaction(TransactionEntity transaction) {
    final isInstallment = transaction.installmentGroupId != null;
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    final surfaceColor = colorScheme.surface;
    final titleColor = colorScheme.onSurface;
    final bodyColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final secondaryActionColor = colorScheme.errorContainer;
    Get.closeAllSnackbars();

    Get.dialog(
      AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Excluir Transação',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isInstallment
              ? 'Esta transação faz parte de uma compra parcelada. O que deseja fazer?'
              : 'Deseja realmente excluir esta transação?',
          style: TextStyle(color: bodyColor),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ),
          if (isInstallment)
            ElevatedButton(
              onPressed: () {
                if (controller.isDeletingTransaction(transaction.id)) {
                  return;
                }

                Get.closeAllSnackbars();
                Get.back();
                controller.deleteTransaction(
                  transaction.id,
                  scope: TransactionMutationScope.all,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryActionColor,
                foregroundColor: colorScheme.onErrorContainer,
                elevation: 0,
              ),
              child: const Text('Todas Parcelas'),
            ),
          ElevatedButton(
            onPressed: () {
              if (controller.isDeletingTransaction(transaction.id)) {
                return;
              }

              Get.closeAllSnackbars();
              Get.back();
              controller.deleteTransaction(
                transaction.id,
                scope: TransactionMutationScope.current,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 0,
            ),
            child: Text(isInstallment ? 'Apenas esta' : 'Excluir'),
          ),
        ],
      ),
    );
  }
}
