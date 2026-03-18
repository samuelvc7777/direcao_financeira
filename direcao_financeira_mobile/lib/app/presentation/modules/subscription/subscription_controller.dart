import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/repositories/i_subscription_repository.dart';

class SubscriptionController extends GetxController {
  SubscriptionController({required this.subscriptionRepository});

  final ISubscriptionRepository subscriptionRepository;

  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final hasPlanCatalog = true.obs;
  final errorMessage = RxnString();
  final activeSubscription = Rxn<SubscriptionEntity>();
  final history = <SubscriptionEntity>[].obs;
  final plans = <PlanEntity>[].obs;
  final selectedPlanId = RxnInt();

  final currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    debugPrint('[SubscriptionController] loadData() iniciado');

    final results = await Future.wait<dynamic>([
      subscriptionRepository.getMySubscription(),
      subscriptionRepository.getSubscriptionHistory(),
      subscriptionRepository.getAvailablePlans(),
    ]);

    // Processar resultado da assinatura ativa
    results[0].fold(
      (failure) {
        debugPrint('[SubscriptionController] getMySubscription() erro -> ${failure.message}');
        errorMessage.value = failure.message;
      },
      (subscription) => activeSubscription.value = subscription,
    );

    // Processar resultado do histórico
    results[1].fold(
      (failure) {
        debugPrint('[SubscriptionController] getSubscriptionHistory() erro -> ${failure.message}');
        if (errorMessage.value == null) {
          errorMessage.value = failure.message;
        }
      },
      (subscriptionHistory) => history.assignAll(subscriptionHistory),
    );

    // Processar resultado dos planos
    results[2].fold(
      (failure) {
        debugPrint('[SubscriptionController] getAvailablePlans() erro -> ${failure.message}');
      },
      (availablePlans) {
        plans.assignAll(availablePlans);
        hasPlanCatalog.value = availablePlans.isNotEmpty;
      },
    );

    _syncSelectedPlan();

    // Sincronizar com storage local
    await subscriptionRepository.syncStoredUser(
      activeSubscription: activeSubscription.value,
      subscriptions: history,
    );

    isLoading.value = false;
    debugPrint('[SubscriptionController] loadData() finalizado');
  }

  Future<void> changePlan() async {
    final planId = selectedPlanId.value;
    if (planId == null) {
      _showFeedback(
        title: 'Plano necessario',
        message: 'Selecione um plano antes de continuar.',
        isError: true,
      );
      return;
    }

    await _runAction(
      action: () => subscriptionRepository.changePlan(planId),
      successMessage: 'Plano alterado com sucesso.',
    );
  }

  Future<void> cancelSubscription() async {
    await _runAction(
      action: subscriptionRepository.cancelSubscription,
      successMessage: 'Assinatura cancelada com sucesso.',
    );
  }

  Future<void> renewSubscription({bool autoRenew = true}) async {
    await _runAction(
      action: () => subscriptionRepository.renewSubscription(
        autoRenew: autoRenew,
      ),
      successMessage: autoRenew
          ? 'Renovacao automatica ativada com sucesso.'
          : 'Assinatura atualizada com sucesso.',
    );
  }

  String formatPrice(int priceCents) => currencyFormatter.format(priceCents / 100);

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Nao informado';
    }
    return dateFormatter.format(date.toLocal());
  }

  String formatStatus(String status) {
    const labels = {
      'ACTIVE': 'Ativa',
      'CANCELED': 'Cancelada',
      'EXPIRED': 'Expirada',
      'PENDING': 'Pendente',
      'TRIAL': 'Teste',
    };

    return labels[status.toUpperCase()] ?? status;
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF03A696);
      case 'CANCELED':
        return const Color(0xFFBF4124);
      case 'EXPIRED':
        return const Color(0xFFF2B366);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  bool isCurrentPlan(PlanEntity plan) {
    return activeSubscription.value?.plan?.id == plan.id;
  }

  Future<void> _runAction({
    required Future<dynamic> Function() action,
    required String successMessage,
  }) async {
    isActionLoading.value = true;

    final result = await action();
    result.fold(
      (failure) => _showFeedback(
        title: 'Erro',
        message: failure.message,
        isError: true,
      ),
      (_) async {
        await loadData();
        _showFeedback(title: 'Sucesso', message: successMessage);
      },
    );

    isActionLoading.value = false;
  }

  void _syncSelectedPlan() {
    final currentPlanId = activeSubscription.value?.plan?.id;
    if (currentPlanId != null) {
      selectedPlanId.value = currentPlanId;
      return;
    }

    if (plans.isNotEmpty) {
      selectedPlanId.value = plans.first.id;
    }
  }

  void _showFeedback({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFFBF4124).withOpacity(0.12)
          : const Color(0xFF03A696).withOpacity(0.12),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
