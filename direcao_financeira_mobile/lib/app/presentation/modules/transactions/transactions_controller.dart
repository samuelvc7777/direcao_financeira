import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/dashboard/dashboard_refresh_notifier.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

enum TransactionsFilter {
  all,
  income,
  expense;

  String get label {
    switch (this) {
      case TransactionsFilter.all:
        return 'Todos';
      case TransactionsFilter.income:
        return 'Entradas';
      case TransactionsFilter.expense:
        return 'Saidas';
    }
  }
}

class TransactionsDayGroup {
  TransactionsDayGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<TransactionEntity> transactions;

  int get totalCents => transactions.fold<int>(
    0,
    (total, transaction) =>
        total + transaction.amountCents * _signalFor(transaction.type),
  );

  static int _signalFor(TransactionType type) {
    return type == TransactionType.expense ? -1 : 1;
  }
}

class TransactionsController extends GetxController {
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final GetCreditCardsUseCase getCreditCardsUseCase;
  final DashboardRefreshNotifier dashboardRefreshNotifier;

  TransactionsController({
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.getCategoriesUseCase,
    required this.getBankAccountsUseCase,
    required this.getCreditCardsUseCase,
    required this.dashboardRefreshNotifier,
  });

  final isSubmitting = false.obs;
  final isLoading = true.obs;
  final deletingTransactionIds = <int>{}.obs;

  final transactions = <TransactionEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final activeAccounts = <BankAccountEntity>[].obs;
  final activeCards = <CreditCardEntity>[].obs;
  final selectedFilter = TransactionsFilter.all.obs;
  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }

    final categoriesFuture = getCategoriesUseCase();
    final bankAccountsFuture = getBankAccountsUseCase();
    final creditCardsFuture = getCreditCardsUseCase();
    final transactionsFuture = getTransactionsUseCase(selectedMonth.value);

    final categoriesResult = await categoriesFuture;
    final bankAccountsResult = await bankAccountsFuture;
    final creditCardsResult = await creditCardsFuture;
    final transactionsResult = await transactionsFuture;

    categoriesResult.fold(
      (failure) => debugPrint('Erro categorias: ${failure.message}'),
      (data) =>
          categories.assignAll(data.where((category) => category.isActive)),
    );

    bankAccountsResult.fold(
      (failure) => debugPrint('Erro contas: ${failure.message}'),
      (data) =>
          activeAccounts.assignAll(data.where((account) => account.isActive)),
    );

    creditCardsResult.fold(
      (failure) => debugPrint('Erro cartoes: ${failure.message}'),
      (data) => activeCards.assignAll(data.where((card) => card.isActive)),
    );

    transactionsResult.fold(
      (failure) => debugPrint('Erro transacoes: ${failure.message}'),
      (data) {
        final sortedData = List<TransactionEntity>.from(data)
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

        transactions.assignAll(sortedData);

        if (sortedData.isNotEmpty &&
            !_hasTransactionsInSelectedMonth(sortedData)) {
          final latestDate = sortedData.first.transactionDate;
          selectedMonth.value = DateTime(latestDate.year, latestDate.month);
        }
      },
    );

    if (!silent) {
      isLoading.value = false;
    }
  }

  List<CategoryEntity> get incomeCategories => categories
      .where((category) => category.type.name.toUpperCase() == 'INCOME')
      .toList();

  List<CategoryEntity> get expenseCategories => categories
      .where((category) => category.type.name.toUpperCase() == 'EXPENSE')
      .toList();

  List<TransactionEntity> get monthTransactions {
    return transactions
        .where(
          (transaction) =>
              transaction.transactionDate.year == selectedMonth.value.year &&
              transaction.transactionDate.month == selectedMonth.value.month,
        )
        .toList();
  }

  List<TransactionEntity> get visibleTransactions {
    switch (selectedFilter.value) {
      case TransactionsFilter.all:
        return monthTransactions;
      case TransactionsFilter.income:
        return monthTransactions
            .where((transaction) => transaction.type == TransactionType.income)
            .toList();
      case TransactionsFilter.expense:
        return monthTransactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .toList();
    }
  }

  int get totalIncomeCents => monthTransactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold<int>(0, (total, transaction) => total + transaction.amountCents);

  int get totalExpenseCents => monthTransactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold<int>(0, (total, transaction) => total + transaction.amountCents);

  int get balanceCents => totalIncomeCents - totalExpenseCents;

  String get selectedMonthSubtitle {
    final formatted = DateFormat(
      "MMMM 'de' yyyy",
      'pt_BR',
    ).format(selectedMonth.value);
    return _capitalize(formatted);
  }

  String get selectedMonthLabelUppercase => DateFormat(
    'MMMM yyyy',
    'pt_BR',
  ).format(selectedMonth.value).toUpperCase();

  List<TransactionsDayGroup> get groupedVisibleTransactions {
    final buckets = <DateTime, List<TransactionEntity>>{};

    for (final transaction in visibleTransactions) {
      final day = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      buckets.putIfAbsent(day, () => <TransactionEntity>[]).add(transaction);
    }

    final groups =
        buckets.entries
            .map(
              (entry) => TransactionsDayGroup(
                date: entry.key,
                transactions: entry.value
                  ..sort(
                    (a, b) => b.transactionDate.compareTo(a.transactionDate),
                  ),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return groups;
  }

  void changeFilter(TransactionsFilter filter) {
    selectedFilter.value = filter;
  }

  void goToPreviousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
  }

  void goToNextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
  }

  Future<bool> createTransaction({
    required TransactionType type,
    required AssetType assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required DateTime transactionDate,
    int? bankAccountId,
    int? creditCardId,
    int? installmentCount,
  }) async {
    isSubmitting.value = true;

    final result = await createTransactionUseCase(
      type: type,
      assetType: assetType,
      amountCents: amountCents,
      categoryId: categoryId,
      description: description,
      transactionDate: transactionDate,
      bankAccountId: bankAccountId,
      creditCardId: creditCardId,
      installmentCount: installmentCount,
    );

    isSubmitting.value = false;

    return result.fold(
      (failure) {
        AppSnackbar.show(
          'Erro',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.12),
          colorText: Get.theme.colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
        );
        return false;
      },
      (transaction) {
        if (type == TransactionType.income) {
          dev.log(
            'Receita adicionada: R\$ ${amountCents / 100} - $description',
            name: 'TRANSACTION',
          );
        }

        selectedMonth.value = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
        );
        dashboardRefreshNotifier.requestRefresh();
        return _finalizeCreateTransaction();
      },
    );
  }

  Future<bool> _finalizeCreateTransaction() async {
    await loadData(silent: true);

    Get.back();

    AppSnackbar.show(
      'Sucesso',
      'Transacao registrada com sucesso.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withValues(alpha: 0.12),
      colorText: Get.theme.colorScheme.onSurface,
      margin: const EdgeInsets.all(16),
    );

    return true;
  }

  Future<void> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  }) async {
    isSubmitting.value = true;

    final result = await updateTransactionUseCase(
      id,
      categoryId: categoryId,
      description: description,
      amountCents: amountCents,
      transactionDate: transactionDate,
      scope: scope,
    );

    isSubmitting.value = false;

    result.fold((failure) => AppSnackbar.show('Erro', failure.message), (
      transaction,
    ) {
      if (scope == TransactionMutationScope.all) {
        loadData(silent: true);
      } else {
        final index = transactions.indexWhere((t) => t.id == id);
        if (index != -1) {
          transactions[index] = transaction;
        }
      }

      dashboardRefreshNotifier.requestRefresh();

      Get.back();
      AppSnackbar.show('Sucesso', 'Transacao atualizada.');
    });
  }

  Future<void> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async {
    if (deletingTransactionIds.contains(id)) {
      return;
    }

    deletingTransactionIds.add(id);
    isLoading.value = true;
    Get.closeAllSnackbars();

    final result = await deleteTransactionUseCase(id, scope: scope);

    result.fold(
      (failure) {
        deletingTransactionIds.remove(id);
        isLoading.value = false;
        Get.closeAllSnackbars();
        AppSnackbar.show('Erro', failure.message);
      },
      (_) {
        if (scope == TransactionMutationScope.all) {
          loadData(silent: true);
        } else {
          transactions.removeWhere((t) => t.id == id);
          isLoading.value = false;
        }

        dashboardRefreshNotifier.requestRefresh();

        deletingTransactionIds.remove(id);
        Get.closeAllSnackbars();
        AppSnackbar.show('Sucesso', 'Transacao excluida.');
      },
    );
  }

  bool isDeletingTransaction(int id) => deletingTransactionIds.contains(id);

  bool _hasTransactionsInSelectedMonth(List<TransactionEntity> data) {
    return data.any(
      (transaction) =>
          transaction.transactionDate.year == selectedMonth.value.year &&
          transaction.transactionDate.month == selectedMonth.value.month,
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
