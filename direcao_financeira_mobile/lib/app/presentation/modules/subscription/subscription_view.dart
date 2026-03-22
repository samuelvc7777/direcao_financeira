import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/plan_entity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_filled_button.dart';
import 'subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petrol,
      appBar: const CustomAppBar(title: 'Minha Assinatura'),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.petrol, AppColors.backgroundDark],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.aqua),
            );
          }

          final error = controller.errorMessage.value;
          if (error != null) {
            return _ErrorState(message: error, onRetry: controller.loadData);
          }

          return RefreshIndicator(
            color: AppColors.teal,
            onRefresh: controller.loadData,
            child: ListView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _CurrentSubscriptionCard(controller: controller),
                const SizedBox(height: 20),
                _PlansSection(controller: controller),
                const SizedBox(height: 20),
                _HistorySection(controller: controller),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CurrentSubscriptionCard extends StatelessWidget {
  const _CurrentSubscriptionCard({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final subscription = controller.activeSubscription.value;

    if (subscription == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nenhuma assinatura ativa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ative ou renove seu plano para continuar com os recursos premium.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.5,
              ),
            ),
            if (controller.usesPlayStoreBilling) ...[
              const SizedBox(height: 14),
              Text(
                'No Android, o checkout agora acontece pela Google Play.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Obx(
              () => CustomFilledButton(
                text: controller.usesPlayStoreBilling
                    ? controller.ctaLabelForSelectedPlan()
                    : 'RENOVAR ASSINATURA',
                isLoading:
                    controller.isPurchaseLoading.value ||
                    controller.isStoreSyncingPurchase.value ||
                    controller.isActionLoading.value,
                onPressed: controller.usesPlayStoreBilling
                    ? controller.purchaseSelectedPlan
                    : () => controller.renewSubscription(autoRenew: true),
              ),
            ),
          ],
        ),
      );
    }

    final plan = subscription.plan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _parsePlanColor(plan?.color).withValues(alpha: 0.2),
            AppColors.surfaceDark.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: controller
                      .statusColor(subscription.status)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  controller.formatStatus(subscription.status),
                  style: TextStyle(
                    color: controller.statusColor(subscription.status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                plan?.name ?? 'Plano atual',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan?.description ?? 'Sem descricao disponivel.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoBadge(
                icon: Icons.payments_outlined,
                label: 'Preco',
                value: plan == null
                    ? controller.formatPrice(0)
                    : controller.planPriceLabel(plan),
              ),
              _InfoBadge(
                icon: Icons.event_outlined,
                label: 'Validade',
                value: controller.formatDate(subscription.endDate),
              ),
              _InfoBadge(
                icon: Icons.autorenew_rounded,
                label: 'Renovacao',
                value: subscription.autoRenew ? 'Automatica' : 'Manual',
              ),
            ],
          ),
          if (controller.usesPlayStoreBilling) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shop_2_outlined, color: AppColors.aqua),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Compras e renovacoes no Android passam pela Google Play.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CustomFilledButton(
                    text: controller.usesPlayStoreBilling
                        ? 'RENOVAR NA PLAY'
                        : subscription.autoRenew
                        ? 'ATUALIZAR'
                        : 'RENOVAR',
                    isLoading:
                        controller.isPurchaseLoading.value ||
                        controller.isStoreSyncingPurchase.value ||
                        controller.isActionLoading.value,
                    onPressed: controller.usesPlayStoreBilling
                        ? controller.purchaseSelectedPlan
                        : () => controller.renewSubscription(
                            autoRenew: !subscription.autoRenew,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFilledButton(
                    text: 'CANCELAR',
                    backgroundColor: AppColors.rust,
                    isLoading: controller.isActionLoading.value,
                    onPressed: controller.cancelSubscription,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansSection extends StatelessWidget {
  const _PlansSection({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasPlanCatalog.value) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Troca de plano',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A API deste ambiente nao retornou uma lista de planos disponiveis.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.usesPlayStoreBilling
                ? 'Selecione um plano para comprar ou renovar pela Google Play.'
                : 'Selecione uma opcao para atualizar sua assinatura.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          if (controller.usesPlayStoreBilling) ...[
            const SizedBox(height: 14),
            _StoreInfoBanner(controller: controller),
          ],
          const SizedBox(height: 16),
          ...controller.plans.map(
            (plan) => Obx(
              () => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => controller.selectedPlanId.value = plan.id,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: controller.selectedPlanId.value == plan.id
                          ? _parsePlanColor(plan.color).withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.selectedPlanId.value == plan.id
                            ? _parsePlanColor(plan.color)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PlanTileContent(
                            controller: controller,
                            plan: plan,
                          ),
                        ),
                        _PlanSelectionIndicator(
                          isSelected:
                              controller.selectedPlanId.value == plan.id,
                          color: _parsePlanColor(plan.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomFilledButton(
              text: controller.ctaLabelForSelectedPlan(),
              icon: controller.usesPlayStoreBilling
                  ? Icons.shop_2_outlined
                  : null,
              isLoading:
                  controller.isActionLoading.value ||
                  controller.isPurchaseLoading.value ||
                  controller.isStoreSyncingPurchase.value,
              onPressed: controller.purchaseSelectedPlan,
            ),
          ),
          if (controller.usesPlayStoreBilling) ...[
            const SizedBox(height: 12),
            Obx(
              () => CustomFilledButton(
                text: 'RESTAURAR COMPRAS',
                backgroundColor: AppColors.surfaceDark,
                isLoading: controller.isRestoringPurchases.value,
                onPressed: controller.restorePurchases,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanTileContent extends StatelessWidget {
  const _PlanTileContent({required this.controller, required this.plan});

  final SubscriptionController controller;
  final PlanEntity plan;

  @override
  Widget build(BuildContext context) {
    final hasStoreProduct = controller.hasStoreProductForPlan(plan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                plan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (controller.isCurrentPlan(plan))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.aqua.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Atual',
                  style: TextStyle(
                    color: AppColors.aqua,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          plan.description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${controller.planPriceLabel(plan)} / ${plan.durationDays} dias',
              style: const TextStyle(
                color: AppColors.sand,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (controller.usesPlayStoreBilling)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasStoreProduct
                      ? AppColors.teal.withValues(alpha: 0.16)
                      : AppColors.rust.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasStoreProduct ? 'Google Play' : 'Sem productId',
                  style: TextStyle(
                    color: hasStoreProduct ? AppColors.aqua : AppColors.sand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StoreInfoBanner extends StatelessWidget {
  const _StoreInfoBanner({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shop_2_outlined, color: AppColors.aqua, size: 18),
              SizedBox(width: 10),
              Text(
                'Google Play conectada',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (controller.isStoreCatalogLoading.value) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              minHeight: 4,
              color: AppColors.aqua,
              backgroundColor: Colors.white24,
            ),
          ],
          if (controller.storeErrorMessage.value != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.storeErrorMessage.value!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historico',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (controller.history.isEmpty)
            Text(
              'Nenhum historico de assinatura encontrado.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
            ),
          ...controller.history.map(
            (subscription) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.statusColor(subscription.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.plan?.name ?? 'Plano sem nome',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.formatStatus(subscription.status)} • ${controller.formatPrice(subscription.plan?.priceCents ?? 0)}',
                          style: const TextStyle(color: AppColors.sand),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inicio: ${controller.formatDate(subscription.startDate)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                        Text(
                          'Fim: ${controller.formatDate(subscription.endDate)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 148),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.aqua, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSelectionIndicator extends StatelessWidget {
  const _PlanSelectionIndicator({
    required this.isSelected,
    required this.color,
  });

  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color : Colors.transparent,
        border: Border.all(
          color: isSelected ? color : Colors.white.withValues(alpha: 0.24),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.sand, size: 42),
            const SizedBox(height: 16),
            const Text(
              'Nao foi possivel carregar sua assinatura.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 220,
              child: CustomFilledButton(
                text: 'TENTAR NOVAMENTE',
                onPressed: () => onRetry(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({Gradient? gradient}) {
  return BoxDecoration(
    gradient: gradient,
    color: gradient == null
        ? AppColors.surfaceDark.withValues(alpha: 0.92)
        : null,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );
}

Color _parsePlanColor(String? colorHex) {
  final normalized = (colorHex ?? '').replaceFirst('#', '');
  if (normalized.length != 6) {
    return AppColors.teal;
  }

  return Color(int.parse('FF$normalized', radix: 16));
}
