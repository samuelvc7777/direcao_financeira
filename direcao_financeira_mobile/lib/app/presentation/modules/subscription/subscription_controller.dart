import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/usecases/subscription_use_cases.dart';

class SubscriptionController extends GetxController {
  SubscriptionController({
    required this.getMySubscriptionUseCase,
    required this.getSubscriptionHistoryUseCase,
    required this.getAvailablePlansUseCase,
    required this.changePlanUseCase,
    required this.cancelSubscriptionUseCase,
    required this.renewSubscriptionUseCase,
    required this.syncStoredUserSubscriptionUseCase,
  });

  final GetMySubscriptionUseCase getMySubscriptionUseCase;
  final GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase;
  final GetAvailablePlansUseCase getAvailablePlansUseCase;
  final ChangePlanUseCase changePlanUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;
  final RenewSubscriptionUseCase renewSubscriptionUseCase;
  final SyncStoredUserSubscriptionUseCase syncStoredUserSubscriptionUseCase;

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

    final activeSubscriptionFuture = getMySubscriptionUseCase();
    final historyFuture = getSubscriptionHistoryUseCase();
    final plansFuture = getAvailablePlansUseCase();

    final activeResult = await activeSubscriptionFuture;
    final historyResult = await historyFuture;
    final plansResult = await plansFuture;

    activeResult.fold(
      (failure) => errorMessage.value = failure.message,
      (subscription) => activeSubscription.value = subscription,
    );

    historyResult.fold(
      (failure) {
        if (errorMessage.value == null) {
          errorMessage.value = failure.message;
        }
      },
      (subscriptionHistory) => history.assignAll(subscriptionHistory),
    );

    plansResult.fold(
      (_) => hasPlanCatalog.value = false,
      (availablePlans) {
        plans.assignAll(availablePlans);
        hasPlanCatalog.value = availablePlans.isNotEmpty;
      },
    );

    _syncSelectedPlan();
    await syncStoredUserSubscriptionUseCase(
      activeSubscription: activeSubscription.value,
      subscriptions: history,
    );

    isLoading.value = false;
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
      action: () => changePlanUseCase(planId),
      successMessage: 'Plano alterado com sucesso.',
    );
  }

  Future<void> cancelSubscription() async {
    await _runAction(
      action: cancelSubscriptionUseCase.call,
      successMessage: 'Assinatura cancelada com sucesso.',
    );
  }

  Future<void> renewSubscription({bool autoRenew = true}) async {
    await _runAction(
      action: () => renewSubscriptionUseCase(autoRenew: autoRenew),
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
          ? const Color(0xFFBF4124).withValues(alpha: 0.12)
          : const Color(0xFF03A696).withValues(alpha: 0.12),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
