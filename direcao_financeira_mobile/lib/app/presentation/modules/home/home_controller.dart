import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dashboard/dashboard_refresh_notifier.dart';
import '../../../core/network/realtime_client.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/auth_session_use_cases.dart';
import '../../../domain/usecases/bank_account_use_cases.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../../../routes/app_pages.dart';
import 'home_expense_chart_item.dart';
import 'home_tab_navigation.dart';

class HomeController extends GetxController {
  HomeController({
    required this.getStoredUserUseCase,
    required this.logoutUseCase,
    required this.loadBankAccountsUseCase,
    required this.loadCreditCardsUseCase,
    required this.getTransactionsUseCase,
    required this.dashboardRefreshNotifier,
    required this.homeTabNavigation,
    required this.realtimeClient,
  });

  final GetStoredUserUseCase getStoredUserUseCase;
  final LogoutUseCase logoutUseCase;
  final LoadBankAccountsUseCase loadBankAccountsUseCase;
  final LoadCreditCardsUseCase loadCreditCardsUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final DashboardRefreshNotifier dashboardRefreshNotifier;
  final HomeTabNavigation homeTabNavigation;
  final RealtimeClient realtimeClient;

  final isLoading = true.obs;
  final userName = ''.obs;
  final selectedMonth = DateTime.now().obs;
  final isBalanceVisible = true.obs;
  final contas = <BankAccountEntity>[].obs;
  final cartoes = <CreditCardEntity>[].obs;
  final ultimasTransacoes = <TransactionEntity>[].obs;
  final gastosPorCategoria = <HomeExpenseChartItem>[].obs;

  final metas = <Map<String, dynamic>>[
    {
      'nome': 'Pagar contas',
      'atual': 0.00,
      'meta': 10000.00,
      'percentual': 0.0,
    },
  ].obs;

  final currentTabIndex = 0.obs;
  Worker? _dashboardRefreshWorker;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    loadDashboardData();
    _setupSocketListeners();
    _dashboardRefreshWorker = ever<int>(dashboardRefreshNotifier.refreshTick, (
      _,
    ) {
      loadDashboardData(silent: true);
    });
  }

  void _setupSocketListeners() {
    realtimeClient.on('transaction.created', (_) {
      loadDashboardData(silent: true);
    });
  }

  @override
  void onClose() {
    _dashboardRefreshWorker?.dispose();
    realtimeClient.off('transaction.created');
    super.onClose();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }

    final bankAccountsFuture = loadBankAccountsUseCase();
    final creditCardsFuture = loadCreditCardsUseCase();
    final transactionsFuture = getTransactionsUseCase(selectedMonth.value);

    final bankResult = await bankAccountsFuture;
    final cardResult = await creditCardsFuture;
    final transactionResult = await transactionsFuture;

    bankResult.fold(
      (failure) => debugPrint(
        '[HomeController] Erro ao carregar contas: ${failure.message}',
      ),
      (data) => contas.assignAll(data.where((a) => a.isActive).toList()),
    );

    cardResult.fold(
      (failure) => debugPrint(
        '[HomeController] Erro ao carregar cartoes: ${failure.message}',
      ),
      (data) => cartoes.assignAll(data.where((c) => c.isActive).toList()),
    );

    transactionResult.fold(
      (failure) => debugPrint(
        '[HomeController] Erro ao carregar transacoes: ${failure.message}',
      ),
      (data) {
        final sortedData = List<TransactionEntity>.from(data)
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        ultimasTransacoes.assignAll(sortedData);
        gastosPorCategoria.assignAll(_buildExpenseChartItems(sortedData));
      },
    );

    if (!silent) {
      isLoading.value = false;
    }
  }

  void _loadUserData() {
    final result = getStoredUserUseCase();
    result.fold(
      (failure) => debugPrint(
        '[HomeController] Erro ao carregar usuario: ${failure.message}',
      ),
      (user) {
        if (user != null) {
          userName.value = user.name;
        }
      },
    );
  }

  double get saldoTotal =>
      contas.fold(0.0, (total, c) => total + c.currentBalance);
  bool get isSaldoPositivo => saldoTotal >= 0;

  double get entradas => ultimasTransacoes
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (total, t) => total + t.amount);

  double get saidas => ultimasTransacoes
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (total, t) => total + t.amount);

  double get totalSaidas => gastosPorCategoria.fold(
    0.0,
    (total, item) => total + item.amount,
  );

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  Future<void> previousMonth() async {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    await loadDashboardData(silent: true);
  }

  Future<void> nextMonth() async {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    await loadDashboardData(silent: true);
  }

  void changeTab(int index) => currentTabIndex.value = index;

  void openTransactionsTab() => homeTabNavigation.openTransactionsTab();

  void openSubscription() => Get.toNamed(AppRoutes.subscription);

  Future<void> logout() async {
    await logoutUseCase();
    Get.offAllNamed(AppRoutes.login);
  }

  List<HomeExpenseChartItem> _buildExpenseChartItems(
    List<TransactionEntity> transactions,
  ) {
    final expenses = transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) {
      return const [];
    }

    final totalsByCategory = <int, int>{};
    final labelsByCategory = <int, String>{};
    final colorsByCategory = <int, Color>{};

    for (final transaction in expenses) {
      totalsByCategory.update(
        transaction.categoryId,
        (current) => current + transaction.amountCents,
        ifAbsent: () => transaction.amountCents,
      );
      labelsByCategory.putIfAbsent(
        transaction.categoryId,
        () => transaction.categoryName ?? 'Categoria #${transaction.categoryId}',
      );
      colorsByCategory.putIfAbsent(
        transaction.categoryId,
        () => _resolveCategoryColor(transaction),
      );
    }

    final totalExpenseCents = totalsByCategory.values.fold<int>(
      0,
      (total, amount) => total + amount,
    );

    final items = totalsByCategory.entries
        .map(
          (entry) => HomeExpenseChartItem(
            categoryId: entry.key,
            categoryLabel: labelsByCategory[entry.key]!,
            amountCents: entry.value,
            percentage: totalExpenseCents == 0
                ? 0
                : (entry.value / totalExpenseCents) * 100,
            color: colorsByCategory[entry.key]!,
          ),
        )
        .toList()
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));

    return items;
  }

  Color _resolveCategoryColor(TransactionEntity transaction) {
    final rawColor = transaction.categoryColor;
    if (rawColor != null && rawColor.isNotEmpty) {
      final normalized = rawColor.replaceFirst('#', '');
      final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(parsed);
      }
    }

    const palette = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];
    return palette[transaction.categoryId.abs() % palette.length];
  }
}
