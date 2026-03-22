import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/bank_account_entity.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../transactions_controller.dart';

class TransactionFormView extends GetView<TransactionsController> {
  TransactionFormView({super.key}) : editingTransaction = Get.arguments is TransactionEntity ? Get.arguments as TransactionEntity : null {
    final arg = Get.arguments;
    if (editingTransaction != null) {
      final trans = editingTransaction!;
      selectedType.value = trans.type;
      amountController.text = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(trans.amountCents / 100);
      descriptionController.text = trans.description;
      isPaid.value = trans.status == TransactionStatus.cleared;
      selectedDate.value = trans.transactionDate;
      
      // Tenta encontrar conta e categoria nos observables do controller
      selectedAccount.value = controller.activeAccounts.firstWhereOrNull((a) => a.id == trans.bankAccountId);
      selectedCategory.value = controller.categories.firstWhereOrNull((c) => c.id == trans.categoryId);
    } else if (arg is TransactionType) {
      selectedType.value = arg;
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

  final Rx<TransactionType> selectedType = TransactionType.expense.obs;
  final RxBool isPaid = true.obs;
  final RxBool isAmountFocused = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final Rx<BankAccountEntity?> selectedAccount = Rx<BankAccountEntity?>(null);
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);

  void _toggleType(TransactionType type) {
    if (editingTransaction != null) return; // Nao permite trocar tipo na edicao
    if (selectedType.value == type) return;
    selectedType.value = type;
    selectedCategory.value = null; // Reseta a categoria pois a lista muda
    isPaid.value = true; // Reseta o status
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
          isEditing ? 'Editar Transação' : 'Nova Transação',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          final isExp = selectedType.value == TransactionType.expense;
          return Center(
            child: CircularProgressIndicator(
              color: isExp ? AppColors.rose : AppColors.emerald,
            ),
          );
        }

        final isExpense = selectedType.value == TransactionType.expense;
        final activeColor = isExpense ? AppColors.rose : AppColors.emerald;
        final statusLabel = isExpense ? 'Pago' : 'Recebido';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Type Selector Tabs (Saida | Entrada)
                if (!isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: _TypeTab(
                          label: 'Saída',
                          isSelected: isExpense,
                          activeColor: AppColors.rose,
                          onTap: () => _toggleType(TransactionType.expense),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TypeTab(
                          label: 'Entrada',
                          isSelected: !isExpense,
                          activeColor: AppColors.emerald,
                          onTap: () => _toggleType(TransactionType.income),
                        ),
                      ),
                    ],
                  ),
                if (!isEditing) const SizedBox(height: 48),

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
                    'DETALHES DA TRANSAÇÃO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPaid.value ? activeColor : Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpense ? 'Status do Pagamento' : 'Status do Recebimento',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPaid.value ? statusLabel : 'Pendente',
                              style: TextStyle(
                                color: isPaid.value ? activeColor : Colors.white.withValues(alpha: 0.7),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isPaid.value,
                        onChanged: (val) => isPaid.value = val,
                        activeColor: Colors.white,
                        activeTrackColor: activeColor,
                        inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
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

                // Account Selector
                _SelectionField<BankAccountEntity>(
                  label: 'Conta',
                  hint: 'Carteira',
                  icon: Icons.account_balance_wallet_outlined,
                  value: selectedAccount.value,
                  items: controller.activeAccounts,
                  itemLabelBuilder: (a) => a.name,
                  onChanged: (v) => selectedAccount.value = v,
                ),
                const SizedBox(height: 16),

                // Category Selector
                _SelectionField<CategoryEntity>(
                  label: 'Categoria',
                  hint: 'Toque para selecionar',
                  icon: Icons.category_outlined,
                  value: selectedCategory.value,
                  items: isExpense ? controller.expenseCategories : controller.incomeCategories,
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
                            isEditing ? 'Salvar Alterações' : 'Salvar Transação',
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
    if (selectedAccount.value == null) {
      Get.snackbar('Atenção', 'Selecione a conta.');
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
      await controller.updateTransaction(
        editingTransaction!.id,
        categoryId: selectedCategory.value!.id,
        description: descriptionController.text.trim().isEmpty 
            ? selectedCategory.value!.name 
            : descriptionController.text.trim(),
        amountCents: amountCents,
        transactionDate: selectedDate.value,
        scope: TransactionMutationScope.current, // Por enquanto unitario
      );
    } else {
      // MODO CRIACAO
      await controller.createTransaction(
        type: selectedType.value,
        assetType: AssetType.bankAccount,
        amountCents: amountCents,
        categoryId: selectedCategory.value!.id,
        description: descriptionController.text.trim().isEmpty 
            ? selectedCategory.value!.name 
            : descriptionController.text.trim(),
        transactionDate: selectedDate.value,
        bankAccountId: selectedAccount.value!.id,
        creditCardId: null,
      );
    }
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
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
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        itemLabelBuilder(item),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
