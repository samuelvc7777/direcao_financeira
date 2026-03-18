import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart' as dartz;
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final IAuthRepository authRepository;
  final IBankAccountRepository bankAccountRepository;
  final ICreditCardRepository creditCardRepository;
  final GetTransactionsUseCase getTransactionsUseCase;

  HomeController({
    required this.authRepository,
    required this.bankAccountRepository,
    required this.creditCardRepository,
    required this.getTransactionsUseCase,
  });

  // Loading state
  final isLoading = true.obs;

  // Dados do usuario
  final userName = ''.obs;
  
  // Mes selecionado
  final selectedMonth = DateTime.now().obs;

  // Visibilidade do saldo
  final isBalanceVisible = true.obs;

  // Real Data
  final contas = <BankAccountEntity>[].obs;
  final cartoes = <CreditCardEntity>[].obs;
  final ultimasTransacoes = <TransactionEntity>[].obs;

  // Gastos por categoria (Ainda mockados ate o dashboard de graficos reais)
  final gastosPorCategoria = <Map<String, dynamic>>[
    {'categoria': 'Manutencao', 'valor': 250.00, 'percentual': 100.0, 'cor': const Color(0xFF3B82F6)},
  ].obs;

  // Metas (Ainda mockadas)
  final metas = <Map<String, dynamic>>[
    {
      'nome': 'Pagar contas',
      'atual': 0.00,
      'meta': 10000.00,
      'percentual': 0.0,
    },
  ].obs;

  // Navegacao
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    loadDashboardData();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    
    // Buscar contas, cartoes e transacoes em paralelo
    final responses = await Future.wait([
      bankAccountRepository.getBankAccounts(),
      creditCardRepository.getCreditCards(),
      getTransactionsUseCase(),
    ]);

    final bankResult = responses[0] as dartz.Either<dynamic, List<BankAccountEntity>>;
    final cardResult = responses[1] as dartz.Either<dynamic, List<CreditCardEntity>>;
    final transactionResult = responses[2] as dartz.Either<dynamic, List<TransactionEntity>>;

    bankResult.fold(
      (failure) => debugPrint('[HomeController] Erro ao carregar contas: ${failure.message}'),
      (data) => contas.assignAll(data.where((a) => a.isActive).toList()),
    );

    cardResult.fold(
      (failure) => debugPrint('[HomeController] Erro ao carregar cartoes: ${failure.message}'),
      (data) => cartoes.assignAll(data.where((c) => c.isActive).toList()),
    );

    transactionResult.fold(
      (failure) => debugPrint('[HomeController] Erro ao carregar transacoes: ${failure.message}'),
      (data) {
        final sortedData = List<TransactionEntity>.from(data)
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        ultimasTransacoes.assignAll(sortedData);
      },
    );

    if (!silent) isLoading.value = false;
  }

  void _loadUserData() {
    final result = authRepository.getStoredUser();
    result.fold(
      (failure) => debugPrint('[HomeController] Erro ao carregar usuario: ${failure.message}'),
      (user) {
        if (user != null) {
          userName.value = user.name;
        }
      },
    );
  }

  // Calculos Reais
  double get saldoTotal => contas.fold(0.0, (total, c) => total + c.currentBalance);
  bool get isSaldoPositivo => saldoTotal >= 0;
  
  double get entradas => ultimasTransacoes
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (total, t) => total + t.amount);
      
  double get saidas => ultimasTransacoes
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (total, t) => total + t.amount);
      
  double get totalSaidas => gastosPorCategoria.fold(0.0, (total, g) => total + (g['valor'] as double));

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  void previousMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month - 1);
  }

  void nextMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1);
  }

  void changeTab(int index) => currentTabIndex.value = index;

  void openSubscription() => Get.toNamed(AppRoutes.subscription);

  Future<void> logout() async {
    await authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
