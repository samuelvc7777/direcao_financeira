import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_category_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../home/home_controller.dart';

class TransactionsController extends GetxController {
  final CreateTransactionUseCase createTransactionUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final ICategoryRepository categoryRepository;
  final IBankAccountRepository bankAccountRepository;
  final ICreditCardRepository creditCardRepository;

  TransactionsController({
    required this.createTransactionUseCase,
    required this.getTransactionsUseCase,
    required this.categoryRepository,
    required this.bankAccountRepository,
    required this.creditCardRepository,
  });

  final isSubmitting = false.obs;
  final isLoadingDependencies = true.obs;

  final categories = <CategoryEntity>[].obs;
  final activeAccounts = <BankAccountEntity>[].obs;
  final activeCards = <CreditCardEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDependencies();
  }

  Future<void> _loadDependencies() async {
    isLoadingDependencies.value = true;
    
    final responses = await Future.wait([
      categoryRepository.getCategories(),
      bankAccountRepository.getBankAccounts(),
      creditCardRepository.getCreditCards(),
    ]);

    responses[0].fold(
      (l) => debugPrint('Erro categorias: ${l.message}'),
      (data) => categories.assignAll((data as List<CategoryEntity>).where((c) => c.isActive)),
    );

    responses[1].fold(
      (l) => debugPrint('Erro contas: ${l.message}'),
      (data) => activeAccounts.assignAll((data as List<BankAccountEntity>).where((a) => a.isActive)),
    );

    responses[2].fold(
      (l) => debugPrint('Erro cartoes: ${l.message}'),
      (data) => activeCards.assignAll((data as List<CreditCardEntity>).where((c) => c.isActive)),
    );

    isLoadingDependencies.value = false;
  }

  List<CategoryEntity> get incomeCategories => 
      categories.where((c) => c.type.name.toUpperCase() == 'INCOME').toList();
      
  List<CategoryEntity> get expenseCategories => 
      categories.where((c) => c.type.name.toUpperCase() == 'EXPENSE').toList();

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
          backgroundColor: AppColors.error.withOpacity(0.12),
          colorText: Get.theme.colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
        );
        return false;
      },
      (transaction) {
        if (type == TransactionType.income) {
          dev.log('💰 Receita adicionada: R\$ ${amountCents / 100} - $description', name: 'TRANSACTION');
        }

        // Atualiza a home de forma silenciosa para refletir o novo saldo/limite/extrato
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadDashboardData(silent: true);
        }

        // Volta para a tela anterior primeiro
        Get.back();

        Get.snackbar(
          'Sucesso',
          'Transacao registrada com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.12),
          colorText: Get.theme.colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
        );

        return true;
      },
    );
  }
}
