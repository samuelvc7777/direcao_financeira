import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/connection_controller.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/auth_session_use_cases.dart';
import '../../../domain/usecases/bank_account_use_cases.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  HomeController({
    required this.getStoredUserUseCase,
    required this.logoutUseCase,
    required this.loadBankAccountsUseCase,
    required this.loadCreditCardsUseCase,
    required this.getTransactionsUseCase,
  });

  final GetStoredUserUseCase getStoredUserUseCase;
  final LogoutUseCase logoutUseCase;
  final LoadBankAccountsUseCase loadBankAccountsUseCase;
  final LoadCreditCardsUseCase loadCreditCardsUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;

  final isLoading = true.obs;
  final userName = ''.obs;
  final selectedMonth = DateTime.now().obs;
  final isBalanceVisible = true.obs;
  final contas = <BankAccountEntity>[].obs;
  final cartoes = <CreditCardEntity>[].obs;
  final ultimasTransacoes = <TransactionEntity>[].obs;

  final gastosPorCategoria = <Map<String, dynamic>>[
    {'categoria': 'Manutencao', 'valor': 250.00, 'percentual': 100.0, 'cor': const Color(0xFF3B82F6)},
  ].obs;

  final metas = <Map<String, dynamic>>[
    {
      'nome': 'Pagar contas',
      'atual': 0.00,
      'meta': 10000.00,
      'percentual': 0.0,
    },
  ].obs;

  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    loadDashboardData();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    try {
      final connection = Get.find<ConnectionController>();
      connection.socket?.on('transaction.created', (_) {
        loadDashboardData(silent: true);
      });
    } catch (_) {}
  }

  @override
  void onClose() {
    try {
      final connection = Get.find<ConnectionController>();
      connection.socket?.off('transaction.created');
    } catch (_) {}
    super.onClose();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }

    final bankAccountsFuture = loadBankAccountsUseCase();
    final creditCardsFuture = loadCreditCardsUseCase();
    final transactionsFuture = getTransactionsUseCase();

    final bankResult = await bankAccountsFuture;
    final cardResult = await creditCardsFuture;
    final transactionResult = await transactionsFuture;

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

    if (!silent) {
      isLoading.value = false;
    }
  }

  void _loadUserData() {
    final result = getStoredUserUseCase();
    result.fold(
      (failure) => debugPrint('[HomeController] Erro ao carregar usuario: ${failure.message}'),
      (user) {
        if (user != null) {
          userName.value = user.name;
        }
      },
    );
  }

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
    try {
      Get.find<ConnectionController>().disconnect();
    } catch (_) {}
    await logoutUseCase();
    Get.offAllNamed(AppRoutes.login);
  }
}
