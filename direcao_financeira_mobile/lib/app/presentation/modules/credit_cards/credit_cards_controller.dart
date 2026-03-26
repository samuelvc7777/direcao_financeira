import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dashboard/dashboard_refresh_notifier.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';

class CreditCardsController extends GetxController {
  CreditCardsController({
    required this.loadCreditCardsUseCase,
    required this.createCreditCardUseCase,
    required this.updateCreditCardUseCase,
    required this.deactivateCreditCardUseCase,
    required this.reactivateCreditCardUseCase,
    required this.dashboardRefreshNotifier,
  });

  final LoadCreditCardsUseCase loadCreditCardsUseCase;
  final CreateCreditCardUseCase createCreditCardUseCase;
  final UpdateCreditCardUseCase updateCreditCardUseCase;
  final DeactivateCreditCardUseCase deactivateCreditCardUseCase;
  final ReactivateCreditCardUseCase reactivateCreditCardUseCase;
  final DashboardRefreshNotifier dashboardRefreshNotifier;

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final creditCards = <CreditCardEntity>[].obs;

  final colorOptions = const <String>[
    '#22c55e',
    '#06B6D4',
    '#038C8C',
    '#3b82f6',
    '#6366f1',
    '#8B5CF6',
    '#f97316',
    '#ef4444',
    '#eab308',
    '#ec4899',
  ];

  List<CreditCardEntity> get activeCards =>
      creditCards.where((card) => card.isActive).toList();

  List<CreditCardEntity> get inactiveCards =>
      creditCards.where((card) => !card.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    loadCreditCards();
  }

  Future<void> loadCreditCards() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await loadCreditCardsUseCase();

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => creditCards.assignAll(data),
    );

    isLoading.value = false;
  }

  Future<void> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async {
    await _runSubmission(
      action: () => createCreditCardUseCase(
        name: name,
        brand: brand,
        color: color,
        limitCents: limitCents,
        closingDay: closingDay,
        dueDay: dueDay,
        lastFourDigits: lastFourDigits,
      ),
      successMessage: 'Cartao de credito criado com sucesso.',
    );
  }

  Future<void> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async {
    await _runSubmission(
      action: () => updateCreditCardUseCase(
        id: id,
        name: name,
        brand: brand,
        color: color,
        limitCents: limitCents,
        closingDay: closingDay,
        dueDay: dueDay,
        lastFourDigits: lastFourDigits,
      ),
      successMessage: 'Cartao de credito atualizado com sucesso.',
    );
  }

  Future<void> toggleCardStatus(CreditCardEntity card) async {
    final isDeactivating = card.isActive;
    final actionName = isDeactivating ? 'desativar' : 'reativar';
    final actionNameCap = isDeactivating ? 'Desativar' : 'Reativar';

    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Get.theme.colorScheme.surface,
            title: Text(
              '$actionNameCap cartao',
              style: TextStyle(color: Get.theme.colorScheme.onSurface),
            ),
            content: Text(
              'O cartao "${card.name}" sera ${actionName}ado.',
              style: TextStyle(
                color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                style: FilledButton.styleFrom(
                  backgroundColor: isDeactivating
                      ? const Color(0xFFBF4124)
                      : const Color(0xFF03A696),
                ),
                child: Text(actionNameCap),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    isSubmitting.value = true;
    final result = isDeactivating
        ? await deactivateCreditCardUseCase(card.id)
        : await reactivateCreditCardUseCase(card.id);

    await result.fold(
      (failure) async => _showFeedback('Erro', failure.message, isError: true),
      (_) async {
        await loadCreditCards();
        dashboardRefreshNotifier.requestRefresh();
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        _showFeedback('Sucesso', 'Cartao ${actionName}ado com sucesso.');
      },
    );

    isSubmitting.value = false;
  }

  Future<void> _runSubmission({
    required Future<dynamic> Function() action,
    required String successMessage,
  }) async {
    isSubmitting.value = true;
    final result = await action();

    await result.fold(
      (failure) async => _showFeedback('Erro', failure.message, isError: true),
      (_) async {
        await loadCreditCards();
        dashboardRefreshNotifier.requestRefresh();
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        _showFeedback('Sucesso', successMessage);
      },
    );

    isSubmitting.value = false;
  }

  void _showFeedback(String title, String message, {bool isError = false}) {
    try {
      if (Get.testMode || Get.overlayContext == null) {
        debugPrint(
          '[CreditCardsController] Feedback suprimido: $title - $message',
        );
        return;
      }

      AppSnackbar.show(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: isError
            ? const Color(0xFFBF4124).withValues(alpha: 0.12)
            : const Color(0xFF03A696).withValues(alpha: 0.12),
        colorText: Get.theme.colorScheme.onSurface,
      );
    } catch (_) {
      debugPrint('[CreditCardsController] Feedback suprimido: $title - $message');
    }
  }

  Color colorFromHex(String colorHex) {
    final normalized = colorHex.replaceFirst('#', '');
    if (normalized.length != 6) {
      return const Color(0xFF8B5CF6);
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }
}
