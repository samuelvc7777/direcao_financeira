import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_filled_button.dart';
import '../../widgets/custom_text_field.dart';
import 'categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petrol,
      appBar: CustomAppBar(
        title: 'Categorias',
        subtitle: 'Entradas e saidas personalizadas',
        leadingIcon: Icons.category_rounded,
        actions: [
          IconButton(
            onPressed: () => _showCategoryForm(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(context),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Categoria'),
      ),
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
            return _ErrorState(
              message: error,
              onRetry: controller.loadCategories,
            );
          }

          if (controller.activeCategories.isEmpty) {
            return _EmptyState(onCreate: () => _showCategoryForm(context));
          }

          return RefreshIndicator(
            color: AppColors.teal,
            onRefresh: controller.loadCategories,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _SummaryCard(controller: controller),
                const SizedBox(height: 20),
                _CategorySection(
                  title: 'Entradas',
                  subtitle: 'Categorias de ganhos e recebimentos',
                  categories: controller.incomeCategories,
                  emptyMessage: 'Nenhuma categoria de entrada ativa.',
                  controller: controller,
                  onTap: (category) =>
                      _showCategoryForm(context, category: category),
                ),
                const SizedBox(height: 20),
                _CategorySection(
                  title: 'Saidas',
                  subtitle: 'Categorias de custos e despesas',
                  categories: controller.expenseCategories,
                  emptyMessage: 'Nenhuma categoria de saida ativa.',
                  controller: controller,
                  onTap: (category) =>
                      _showCategoryForm(context, category: category),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showCategoryForm(BuildContext context, {CategoryEntity? category}) {
    Get.bottomSheet(
      _CategoryFormSheet(category: category, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.category, required this.controller});

  final CategoryEntity? category;
  final CategoriesController controller;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late CategoryType _selectedType;
  late String _selectedColor;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? CategoryType.expense;
    _selectedColor =
        widget.category?.color ?? widget.controller.colorOptions.first;
    _selectedIcon =
        widget.category?.icon ?? widget.controller.iconOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.category == null
                        ? 'Nova categoria'
                        : 'Editar categoria',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Defina nome, tipo, cor e icone da categoria.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome',
                    hint: 'Ex.: Combustivel',
                    icon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome da categoria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Tipo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TypeChip(
                        title: 'Entrada',
                        icon: Icons.trending_up_rounded,
                        isSelected: _selectedType == CategoryType.income,
                        accentColor: AppColors.aqua,
                        onTap: () => setState(() {
                          _selectedType = CategoryType.income;
                        }),
                      ),
                      const SizedBox(width: 12),
                      _TypeChip(
                        title: 'Saida',
                        icon: Icons.trending_down_rounded,
                        isSelected: _selectedType == CategoryType.expense,
                        accentColor: AppColors.rust,
                        onTap: () => setState(() {
                          _selectedType = CategoryType.expense;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cor',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.controller.colorOptions
                        .map(
                          (colorHex) => GestureDetector(
                            onTap: () => setState(() {
                              _selectedColor = colorHex;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: widget.controller.colorFromHex(colorHex),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColor == colorHex
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.18),
                                  width: _selectedColor == colorHex ? 3 : 1,
                                ),
                              ),
                              child: _selectedColor == colorHex
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Icone',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.controller.iconOptions
                        .map(
                          (iconCode) => GestureDetector(
                            onTap: () => setState(() {
                              _selectedIcon = iconCode;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: _selectedIcon == iconCode
                                    ? widget.controller
                                          .colorFromHex(_selectedColor)
                                          .withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _selectedIcon == iconCode
                                      ? widget.controller.colorFromHex(
                                          _selectedColor,
                                        )
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Icon(
                                widget.controller.iconForCode(iconCode),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => CustomFilledButton(
                      text: widget.category == null
                          ? 'SALVAR CATEGORIA'
                          : 'ATUALIZAR CATEGORIA',
                      isLoading: widget.controller.isSubmitting.value,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        if (widget.category == null) {
                          await widget.controller.createCategory(
                            name: _nameController.text.trim(),
                            type: _selectedType,
                            color: _selectedColor,
                            icon: _selectedIcon,
                          );
                        } else {
                          await widget.controller.updateCategory(
                            id: widget.category!.id,
                            name: _nameController.text.trim(),
                            type: _selectedType,
                            color: _selectedColor,
                            icon: _selectedIcon,
                          );
                        }
                      },
                    ),
                  ),
                  if (widget.category != null) ...[
                    const SizedBox(height: 12),
                    Obx(
                      () => CustomFilledButton(
                        text: 'DESATIVAR CATEGORIA',
                        backgroundColor: AppColors.rust,
                        isLoading: widget.controller.isSubmitting.value,
                        onPressed: () => widget.controller.deactivateCategory(
                          widget.category!,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.62),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isSelected ? 1 : 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});

  final CategoriesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.teal.withValues(alpha: 0.22),
            AppColors.surfaceDark.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.category_rounded,
              color: AppColors.sand,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categorias ativas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.incomeCategories.length} entradas • ${controller.expenseCategories.length} saidas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
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

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.subtitle,
    required this.categories,
    required this.emptyMessage,
    required this.controller,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<CategoryEntity> categories;
  final String emptyMessage;
  final CategoriesController controller;
  final ValueChanged<CategoryEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.66),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: categories.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(
                    categories.length,
                    (index) => _CategoryTile(
                      category: categories[index],
                      controller: controller,
                      isLast: index == categories.length - 1,
                      onTap: () => onTap(categories[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.controller,
    required this.onTap,
    required this.isLast,
  });

  final CategoryEntity category;
  final CategoriesController controller;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accentColor = controller.colorFromHex(category.color);

    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(0),
        bottom: isLast ? const Radius.circular(24) : Radius.zero,
      ),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.95),
                        accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Icon(
                    controller.iconForCode(category.icon),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.type.label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.64),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withValues(alpha: 0.52),
                ),
              ],
            ),
            if (!isLast) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            ],
          ],
        ),
      ),
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
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.sand,
              size: 44,
            ),
            const SizedBox(height: 14),
            const Text(
              'Nao foi possivel carregar as categorias.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.aqua.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_rounded,
                color: AppColors.aqua,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhuma categoria ativa ainda.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Crie categorias de entrada e saida para organizar melhor suas financas.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 240,
              child: CustomFilledButton(
                text: 'CRIAR PRIMEIRA CATEGORIA',
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
