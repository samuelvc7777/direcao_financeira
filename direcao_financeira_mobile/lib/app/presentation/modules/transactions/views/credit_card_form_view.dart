import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/credit_card_entity.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../transactions_controller.dart';

class CreditCardFormView extends GetView<TransactionsController> {
  CreditCardFormView({super.key}) : editingTransaction = Get.arguments is TransactionEntity ? Get.arguments as TransactionEntity : null {
    final arg = Get.arguments;
    if (editingTransaction != null) {
      final trans = editingTransaction!;
      amountController.text = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(trans.amountCents / 100);
      descriptionController.text = trans.description;
      selectedDate.value = trans.transactionDate;
      installmentCount.value = trans.installmentCount ?? 1;
      
      selectedCard.value = controller.activeCards.firstWhereOrNull((c) => c.id == trans.creditCardId);
      selectedCategory.value = controller.categories.firstWhereOrNull((c) => c.id == trans.categoryId);
    }

    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  
  final TransactionEntity? editingTransaction;

  final RxBool isAmountFocused = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt installmentCount = 1.obs;

  final Rx<CreditCardEntity?> selectedCard = Rx<CreditCardEntity?>(null);
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);

  void _incrementInstallments() {
    if (editingTransaction != null) return;
    if (installmentCount.value < 48) {
      installmentCount.value++;
    }
  }

  void _decrementInstallments() {
    if (editingTransaction != null) return;
    if (installmentCount.value > 1) {
      installmentCount.value--;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = editingTransaction != null;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEditing ? 'Editar Compra' : 'Nova Compra',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.violet),
          );
        }

        const activeColor = AppColors.violet;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TypeTab(
                        label: isEditing ? 'Editar Cartão' : 'Cartão de Crédito',
                        icon: Icons.credit_card_rounded,
                        activeColor: activeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Amount Input
                TextFormField(
                  controller: amountController,
                  focusNode: amountFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'R\$ 0,00',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ),
                  ],
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Informe o valor.';
                    final numValue = int.tryParse(v!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    if (numValue <= 0) return 'Maior que zero.';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (isAmountFocused.value) {
                      amountFocusNode.unfocus();
                    } else {
                      amountFocusNode.requestFocus();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isAmountFocused.value ? 'Toque para sair' : 'Toque para digitar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isAmountFocused.value ? Icons.keyboard_hide_outlined : Icons.keyboard_alt_outlined,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Details Section Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DETALHES DA COMPRA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Installments Row (Disabled in Edit for now or handled carefully)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.view_agenda_rounded,
                          color: activeColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parcelamento',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEditing ? 'Parcela atual' : 'Quantidade de vezes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditing)
                        Text(
                          '${editingTransaction!.installmentNumber}/${editingTransaction!.installmentCount}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _decrementInstallments,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Colors.transparent,
                                  child: Icon(
                                    Icons.remove_rounded,
                                    color: Colors.white.withValues(alpha: installmentCount.value > 1 ? 0.8 : 0.2),
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${installmentCount.value}x',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _incrementInstallments,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: Colors.transparent,
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.white.withValues(alpha: installmentCount.value < 48 ? 0.8 : 0.2),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date Selector
                Row(
                  children: [
                    Expanded(
                      child: _DateChip(
                        label: 'Hoje',
                        isSelected: _isSameDay(selectedDate.value, DateTime.now()),
                        activeColor: activeColor,
                        onTap: () => selectedDate.value = DateTime.now(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateChip(
                        label: 'Ontem',
                        isSelected: _isSameDay(selectedDate.value, DateTime.now().subtract(const Duration(days: 1))),
                        activeColor: activeColor,
                        onTap: () => selectedDate.value = DateTime.now().subtract(const Duration(days: 1)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateChip(
                        label: 'Data',
                        icon: Icons.calendar_today_outlined,
                        isSelected: !_isSameDay(selectedDate.value, DateTime.now()) && 
                                    !_isSameDay(selectedDate.value, DateTime.now().subtract(const Duration(days: 1))),
                        activeColor: activeColor,
                        onTap: () => _pickDate(context, activeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Credit Card Selector
                _SelectionField<CreditCardEntity>(
                  label: 'Cartão',
                  hint: 'Toque para selecionar',
                  icon: Icons.credit_card_rounded,
                  value: selectedCard.value,
                  items: controller.activeCards,
                  itemLabelBuilder: (c) => c.name,
                  onChanged: (v) => selectedCard.value = v,
                ),
                const SizedBox(height: 16),

                // Category Selector
                _SelectionField<CategoryEntity>(
                  label: 'Categoria',
                  hint: 'Toque para selecionar',
                  icon: Icons.category_outlined,
                  value: selectedCategory.value,
                  items: controller.expenseCategories,
                  itemLabelBuilder: (c) => c.name,
                  onChanged: (v) => selectedCategory.value = v,
                ),
                const SizedBox(height: 16),

                // Description Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: descriptionController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Descrição (opcional)',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEditing ? 'Salvar Alterações' : 'Salvar Compra',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate(BuildContext context, Color activeColor) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: activeColor,
              onPrimary: Colors.white,
              surface: AppColors.midnight,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCard.value == null) {
      Get.snackbar('Atenção', 'Selecione o cartão.');
      return;
    }
    if (selectedCategory.value == null) {
      Get.snackbar('Atenção', 'Selecione a categoria.');
      return;
    }

    final rawAmount = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountCents = int.tryParse(rawAmount) ?? 0;

    if (editingTransaction != null) {
      // MODO EDICAO
      // Se for parcelado, perguntamos o escopo antes de enviar
      if (editingTransaction!.installmentGroupId != null) {
        _showScopeDialog(amountCents);
      } else {
        await controller.updateTransaction(
          editingTransaction!.id,
          categoryId: selectedCategory.value!.id,
          description: descriptionController.text.trim().isEmpty 
              ? selectedCategory.value!.name 
              : descriptionController.text.trim(),
          amountCents: amountCents,
          transactionDate: selectedDate.value,
          scope: TransactionMutationScope.current,
        );
      }
    } else {
      // MODO CRIACAO
      await controller.createTransaction(
        type: TransactionType.expense,
        assetType: AssetType.creditCard,
        amountCents: amountCents,
        categoryId: selectedCategory.value!.id,
        description: descriptionController.text.trim().isEmpty 
            ? selectedCategory.value!.name 
            : descriptionController.text.trim(),
        transactionDate: selectedDate.value,
        creditCardId: selectedCard.value!.id,
        installmentCount: installmentCount.value,
      );
    }
  }

  void _showScopeDialog(int amountCents) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.midnight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Editar Parcelamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Deseja aplicar as mudanças apenas nesta parcela ou em todas?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performUpdate(amountCents, TransactionMutationScope.all);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.violet.withValues(alpha: 0.2), foregroundColor: AppColors.violet),
            child: const Text('Todas'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performUpdate(amountCents, TransactionMutationScope.current);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.violet),
            child: const Text('Apenas esta'),
          ),
        ],
      ),
    );
  }

  void _performUpdate(int amountCents, TransactionMutationScope scope) {
    controller.updateTransaction(
      editingTransaction!.id,
      categoryId: selectedCategory.value!.id,
      description: descriptionController.text.trim().isEmpty 
          ? selectedCategory.value!.name 
          : descriptionController.text.trim(),
      amountCents: amountCents,
      transactionDate: selectedDate.value,
      scope: scope,
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.icon,
    required this.activeColor,
  });

  final String label;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: activeColor, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: activeColor, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionField<T> extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.4)),
          dropdownColor: AppColors.midnight,
          hint: Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 22),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(hint, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(itemLabelBuilder(item), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabelBuilder(item), style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
