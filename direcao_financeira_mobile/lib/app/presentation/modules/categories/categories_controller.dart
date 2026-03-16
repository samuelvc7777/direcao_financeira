import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/i_category_repository.dart';

class CategoriesController extends GetxController {
  CategoriesController({required this.categoryRepository});

  final ICategoryRepository categoryRepository;

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final categories = <CategoryEntity>[].obs;

  final colorOptions = const <String>[
    '#22c55e',
    '#038C8C',
    '#03A696',
    '#3b82f6',
    '#6366f1',
    '#f97316',
    '#ef4444',
    '#F2B366',
    '#eab308',
    '#ec4899',
  ];

  final iconOptions = const <String>[
    'briefcase',
    'fuel',
    'shopping-cart',
    'restaurant',
    'car',
    'wrench',
    'wallet',
    'credit-card',
    'chart-line',
    'home',
    'heart',
    'tag',
  ];

  List<CategoryEntity> get activeCategories =>
      categories.where((category) => category.isActive).toList();

  List<CategoryEntity> get incomeCategories =>
      activeCategories
          .where((category) => category.type == CategoryType.income)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<CategoryEntity> get expenseCategories =>
      activeCategories
          .where((category) => category.type == CategoryType.expense)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await categoryRepository.getCategories();
      categories.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    await _runSubmission(
      action: () => categoryRepository.createCategory(
        name: name,
        type: type,
        color: color,
        icon: icon,
      ),
      successMessage: 'Categoria criada com sucesso.',
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async {
    await _runSubmission(
      action: () => categoryRepository.updateCategory(
        id: id,
        name: name,
        type: type,
        color: color,
        icon: icon,
      ),
      successMessage: 'Categoria atualizada com sucesso.',
    );
  }

  Future<void> deactivateCategory(CategoryEntity category) async {
    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: const Color(0xFF022C35),
            title: const Text(
              'Desativar categoria',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'A categoria "${category.name}" sera desativada e deixara de aparecer nas opcoes normais.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
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
                  backgroundColor: const Color(0xFFBF4124),
                ),
                child: const Text('Desativar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      isSubmitting.value = true;
      await categoryRepository.deactivateCategory(category.id);
      await loadCategories();
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      _showFeedback('Sucesso', 'Categoria desativada com sucesso.');
    } catch (e) {
      _showFeedback(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  IconData iconForCode(String iconCode) {
    const iconMap = <String, IconData>{
      'briefcase': Icons.work_rounded,
      'fuel': Icons.local_gas_station_rounded,
      'shopping-cart': Icons.shopping_cart_rounded,
      'restaurant': Icons.restaurant_rounded,
      'car': Icons.directions_car_rounded,
      'wrench': Icons.build_rounded,
      'wallet': Icons.account_balance_wallet_rounded,
      'credit-card': Icons.credit_card_rounded,
      'chart-line': Icons.show_chart_rounded,
      'home': Icons.home_rounded,
      'heart': Icons.favorite_rounded,
      'tag': Icons.sell_rounded,
      'category': Icons.category_rounded,
    };

    return iconMap[iconCode] ?? Icons.category_rounded;
  }

  Color colorFromHex(String colorHex) {
    final normalized = colorHex.replaceFirst('#', '');
    if (normalized.length != 6) {
      return const Color(0xFF038C8C);
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }

  Future<void> _runSubmission({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    try {
      isSubmitting.value = true;
      await action();
      await loadCategories();
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      _showFeedback('Sucesso', successMessage);
    } catch (e) {
      _showFeedback(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showFeedback(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: isError
          ? Colors.red.withValues(alpha: 0.12)
          : Colors.green.withValues(alpha: 0.12),
      colorText: Colors.white,
    );
  }
}
