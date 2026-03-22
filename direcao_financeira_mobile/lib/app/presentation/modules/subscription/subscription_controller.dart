import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/store_product_entity.dart';
import '../../../domain/entities/store_purchase_event_entity.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/repositories/i_subscription_repository.dart';
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
    required this.isStoreAvailableUseCase,
    required this.getStoreProductsUseCase,
    required this.buyStoreProductUseCase,
    required this.restorePurchasesUseCase,
    required this.completePurchaseUseCase,
    required this.subscriptionRepository,
  });

  final GetMySubscriptionUseCase getMySubscriptionUseCase;
  final GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase;
  final GetAvailablePlansUseCase getAvailablePlansUseCase;
  final ChangePlanUseCase changePlanUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;
  final RenewSubscriptionUseCase renewSubscriptionUseCase;
  final SyncStoredUserSubscriptionUseCase syncStoredUserSubscriptionUseCase;
  final IsStoreAvailableUseCase isStoreAvailableUseCase;
  final GetStoreProductsUseCase getStoreProductsUseCase;
  final BuyStoreProductUseCase buyStoreProductUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final CompletePurchaseUseCase completePurchaseUseCase;
  final ISubscriptionRepository subscriptionRepository;

  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final hasPlanCatalog = true.obs;
  final errorMessage = RxnString();
  final activeSubscription = Rxn<SubscriptionEntity>();
  final history = <SubscriptionEntity>[].obs;
  final plans = <PlanEntity>[].obs;
  final selectedPlanId = RxnInt();

  final isStoreAvailable = false.obs;
  final isStoreCatalogLoading = false.obs;
  final isPurchaseLoading = false.obs;
  final isRestoringPurchases = false.obs;
  final isStoreSyncingPurchase = false.obs;
  final storeErrorMessage = RxnString();
  final pendingPurchaseProductId = RxnString();
  final storeProductsById = <String, StoreProductEntity>{}.obs;

  StreamSubscription<StorePurchaseEventEntity>? _purchaseSubscription;

  final currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  final dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');

  bool get usesPlayStoreBilling => isStoreAvailable.value;

  @override
  void onInit() {
    super.onInit();
    _listenToPurchaseUpdates();
    loadData();
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
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

    historyResult.fold((failure) {
      if (errorMessage.value == null) {
        errorMessage.value = failure.message;
      }
    }, (subscriptionHistory) => history.assignAll(subscriptionHistory));

    plansResult.fold((_) => hasPlanCatalog.value = false, (availablePlans) {
      plans.assignAll(availablePlans);
      hasPlanCatalog.value = availablePlans.isNotEmpty;
    });

    _syncSelectedPlan();
    await _loadStoreCatalog();
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

  Future<void> purchaseSelectedPlan() async {
    final plan = selectedPlan;
    if (plan == null) {
      _showFeedback(
        title: 'Plano necessario',
        message: 'Selecione um plano antes de continuar.',
        isError: true,
      );
      return;
    }

    if (!usesPlayStoreBilling) {
      await changePlan();
      return;
    }

    final product = storeProductForPlan(plan);
    if (product == null) {
      _showFeedback(
        title: 'Produto indisponivel',
        message:
            'Este plano ainda nao foi encontrado na Play Store. Verifique se o productId publicado e igual ao code do plano.',
        isError: true,
      );
      return;
    }

    isPurchaseLoading.value = true;
    pendingPurchaseProductId.value = product.productId;

    final result = await buyStoreProductUseCase(
      productId: product.productId,
      applicationUserName: activeSubscription.value?.id.toString(),
    );

    result.fold(
      (failure) {
        pendingPurchaseProductId.value = null;
        _showFeedback(title: 'Erro', message: failure.message, isError: true);
      },
      (_) => _showFeedback(
        title: 'Play Store',
        message: 'Confirme a compra para concluir a assinatura.',
      ),
    );

    isPurchaseLoading.value = false;
  }

  Future<void> restorePurchases() async {
    isRestoringPurchases.value = true;

    final result = await restorePurchasesUseCase();
    result.fold(
      (failure) =>
          _showFeedback(title: 'Erro', message: failure.message, isError: true),
      (_) => _showFeedback(
        title: 'Play Store',
        message: 'Buscando compras anteriores para restaurar sua assinatura.',
      ),
    );

    isRestoringPurchases.value = false;
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

  PlanEntity? get selectedPlan {
    final planId = selectedPlanId.value;
    if (planId == null) {
      return null;
    }

    for (final plan in plans) {
      if (plan.id == planId) {
        return plan;
      }
    }

    return null;
  }

  StoreProductEntity? storeProductForPlan(PlanEntity plan) {
    return storeProductsById[plan.code];
  }

  String planPriceLabel(PlanEntity plan) {
    return storeProductForPlan(plan)?.priceLabel ??
        formatPrice(plan.priceCents);
  }

  bool hasStoreProductForPlan(PlanEntity plan) {
    return storeProductForPlan(plan) != null;
  }

  String ctaLabelForSelectedPlan() {
    final plan = selectedPlan;
    if (plan == null) {
      return 'SELECIONE UM PLANO';
    }

    if (!usesPlayStoreBilling) {
      return 'ALTERAR PLANO';
    }

    return isCurrentPlan(plan)
        ? 'RENOVAR NA PLAY STORE'
        : 'ASSINAR NA PLAY STORE';
  }

  String formatPrice(int priceCents) =>
      currencyFormatter.format(priceCents / 100);

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

  Future<void> _loadStoreCatalog() async {
    storeErrorMessage.value = null;
    storeProductsById.clear();

    final storeAvailabilityResult = await isStoreAvailableUseCase();
    final storeAvailable = storeAvailabilityResult.fold(
      (_) => false,
      (value) => value,
    );
    isStoreAvailable.value = storeAvailable;

    if (!storeAvailable) {
      return;
    }

    final productIds = plans
        .map((plan) => plan.code)
        .where((code) => code.trim().isNotEmpty)
        .toSet();
    if (productIds.isEmpty) {
      storeErrorMessage.value =
          'Nenhum plano possui code configurado para a Play Store.';
      return;
    }

    isStoreCatalogLoading.value = true;
    final productsResult = await getStoreProductsUseCase(productIds);
    productsResult.fold(
      (failure) => storeErrorMessage.value = failure.message,
      (products) {
        storeProductsById.assignAll({
          for (final product in products) product.productId: product,
        });

        if (products.isEmpty) {
          storeErrorMessage.value =
              'Nenhum produto retornou da Play Store para os codes atuais.';
        }
      },
    );
    isStoreCatalogLoading.value = false;
  }

  void _listenToPurchaseUpdates() {
    _purchaseSubscription = subscriptionRepository.purchaseUpdates.listen((
      event,
    ) async {
      switch (event.status) {
        case StorePurchaseStatus.pending:
          pendingPurchaseProductId.value = event.productId;
          _showFeedback(
            title: 'Compra em andamento',
            message: 'Aguardando confirmacao da Play Store.',
          );
          break;
        case StorePurchaseStatus.purchased:
        case StorePurchaseStatus.restored:
          await _syncPurchaseWithSubscription(event);
          break;
        case StorePurchaseStatus.canceled:
          pendingPurchaseProductId.value = null;
          _showFeedback(
            title: 'Compra cancelada',
            message: 'A compra foi cancelada antes da confirmacao.',
            isError: true,
          );
          break;
        case StorePurchaseStatus.error:
          pendingPurchaseProductId.value = null;
          _showFeedback(
            title: 'Erro na compra',
            message: event.errorMessage ?? 'Falha ao processar a compra.',
            isError: true,
          );
          break;
      }
    });
  }

  Future<void> _syncPurchaseWithSubscription(
    StorePurchaseEventEntity event,
  ) async {
    if (event.productId.isEmpty || isStoreSyncingPurchase.value) {
      return;
    }

    final plan = _findPlanByProductId(event.productId);
    if (plan == null) {
      _showFeedback(
        title: 'Produto desconhecido',
        message:
            'A compra retornou da Play Store, mas nenhum plano com esse code foi encontrado no app.',
        isError: true,
      );
      return;
    }

    isStoreSyncingPurchase.value = true;
    pendingPurchaseProductId.value = event.productId;

    final result = isCurrentPlan(plan)
        ? await renewSubscriptionUseCase(autoRenew: true)
        : await changePlanUseCase(plan.id);

    await result.fold(
      (failure) async {
        _showFeedback(
          title: 'Compra recebida',
          message:
              '${failure.message} A compra voltou da Play Store, mas a sincronizacao com a API nao foi concluida.',
          isError: true,
        );
      },
      (_) async {
        await completePurchaseUseCase(event.productId);
        await loadData();
        _showFeedback(
          title: 'Sucesso',
          message: event.status == StorePurchaseStatus.restored
              ? 'Compra restaurada e assinatura sincronizada com sucesso.'
              : 'Compra confirmada e assinatura atualizada com sucesso.',
        );
      },
    );

    isStoreSyncingPurchase.value = false;
    pendingPurchaseProductId.value = null;
  }

  PlanEntity? _findPlanByProductId(String productId) {
    for (final plan in plans) {
      if (plan.code == productId) {
        return plan;
      }
    }

    return null;
  }

  Future<void> _runAction({
    required Future<dynamic> Function() action,
    required String successMessage,
  }) async {
    isActionLoading.value = true;

    final result = await action();
    result.fold(
      (failure) =>
          _showFeedback(title: 'Erro', message: failure.message, isError: true),
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
