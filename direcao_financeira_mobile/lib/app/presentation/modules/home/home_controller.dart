import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final IAuthRepository authRepository;

  HomeController({required this.authRepository});

  // Dados do usuário
  var userName = ''.obs;
  
  // Mês selecionado
  var selectedMonth = DateTime.now().obs;

  // Visibilidade do saldo
  var isBalanceVisible = true.obs;

  // Dados mockados de saldo
  var saldoAtual = 1273.00.obs;
  var entradas = 0.00.obs;
  var saidas = 250.00.obs;

  // Contas
  final contas = <Map<String, dynamic>>[
    {
      'nome': 'Meu Nubank',
      'tipo': 'CORRENTE',
      'saldo': 1220.00,
      'icon': Icons.account_balance,
      'cor': const Color(0xFF6B21A8), // Roxo
    },
    {
      'nome': 'Carteira',
      'tipo': 'CARTEIRA',
      'saldo': 53.00,
      'icon': Icons.account_balance_wallet,
      'cor': const Color(0xFF047857), // Verde
    },
  ].obs;

  // Cartões de crédito
  final cartoes = <Map<String, dynamic>>[
    {
      'nome': 'Cartão Nubank',
      'fechamento': '03/04/2026',
      'fatura': 250.00,
      'limite': 300.00,
      'disponivel': 50.00,
    },
  ].obs;

  // Gastos por categoria
  final gastosPorCategoria = <Map<String, dynamic>>[
    {'categoria': 'Manutenção', 'valor': 250.00, 'percentual': 100.0, 'cor': const Color(0xFF3B82F6)},
  ].obs;

  // Últimas transações
  final ultimasTransacoes = <Map<String, dynamic>>[
    {
      'titulo': 'troca de pneu (1/2)',
      'categoria': 'Manutenção',
      'data': '25/02',
      'hora': '00:00',
      'valor': -250.00,
    },
  ].obs;

  // Metas
  final metas = <Map<String, dynamic>>[
    {
      'nome': 'Pagar contas',
      'atual': 0.00,
      'meta': 10000.00,
      'percentual': 0.0,
    },
  ].obs;

  // Navegação
  var currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = authRepository.getStoredUser();
    if (user != null) {
      userName.value = user.name;
    }
  }

  bool get isSaldoPositivo => saldoAtual.value >= 0;
  double get saldoTotal => contas.fold(0.0, (total, c) => total + (c['saldo'] as double));
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
