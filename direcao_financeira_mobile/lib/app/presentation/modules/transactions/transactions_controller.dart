import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../home/home_controller.dart';

class TransactionsController extends GetxController {
  final CreateTransactionUseCase createTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final GetCreditCardsUseCase getCreditCardsUseCase;

  TransactionsController({
    required this.createTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.getCategoriesUseCase,
    required this.getBankAccountsUseCase,
    required this.getCreditCardsUseCase,
  });

  final isSubmitting = false.obs;
  final isLoading = true.obs;

  final transactions = <TransactionEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final activeAccounts = <BankAccountEntity>[].obs;
  final activeCards = <CreditCardEntity>[].obs;

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
    final transactionsFuture = getTransactionsUseCase();

    final categoriesResult = await categoriesFuture;
    final bankAccountsResult = await bankAccountsFuture;
    final creditCardsResult = await creditCardsFuture;
    final transactionsResult = await transactionsFuture;

    categoriesResult.fold(
      (failure) => debugPrint('Erro categorias: ${failure.message}'),
      (data) => categories.assignAll(
        data.where((category) => category.isActive),
      ),
    );

    bankAccountsResult.fold(
      (failure) => debugPrint('Erro contas: ${failure.message}'),
      (data) => activeAccounts.assignAll(
        data.where((account) => account.isActive),
      ),
    );

    creditCardsResult.fold(
      (failure) => debugPrint('Erro cartoes: ${failure.message}'),
      (data) => activeCards.assignAll(
        data.where((card) => card.isActive),
      ),
    );

    transactionsResult.fold(
      (failure) => debugPrint('Erro transacoes: ${failure.message}'),
      (data) {
        final sortedData = List<TransactionEntity>.from(data)
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

        transactions.assignAll(sortedData);
      },
    );

    if (!silent) {
      isLoading.value = false;
    }
  }

  List<CategoryEntity> get incomeCategories =>
      categories.where((category) => category.type.name.toUpperCase() == 'INCOME').toList();

  List<CategoryEntity> get expenseCategories =>
      categories.where((category) => category.type.name.toUpperCase() == 'EXPENSE').toList();

  Future<bool> createTransaction({
    required TransactionType type,
    required AssetType assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required DateTime transactionDate,
    int? bankAccountId,
    int? creditCardId,
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
    );

    isSubmitting.value = false;

    return result.fold(
      (failure) {
        Get.snackbar(
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

        transactions.insert(0, transaction);

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadDashboardData(silent: true);
        }

        Get.back();

        Get.snackbar(
          'Sucesso',
          'Transacao registrada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.12),
          colorText: Get.theme.colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
        );

        return true;
      },
    );
  }
}
