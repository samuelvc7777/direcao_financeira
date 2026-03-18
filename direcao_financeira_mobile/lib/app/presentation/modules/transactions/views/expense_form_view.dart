import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../domain/entities/bank_account_entity.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/entities/credit_card_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_filled_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../transactions_controller.dart';

class ExpenseFormView extends StatefulWidget {
  const ExpenseFormView({super.key});

  @override
  State<ExpenseFormView> createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<ExpenseFormView> {
  final TransactionsController controller = Get.find<TransactionsController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AssetType _selectedAssetType = AssetType.bankAccount;
  BankAccountEntity? _selectedAccount;
  CreditCardEntity? _selectedCard;
  CategoryEntity? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Nova Saida',
        subtitle: 'Registre uma nova despesa',
        leadingIcon: Icons.arrow_downward_rounded,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.aqua));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.sp(context, 24)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _amountController,
                  label: 'Valor',
                  hint: 'R\$ 0,00',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ),
                  ],
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Informe o valor.';
                    final numValue = int.tryParse(v!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    if (numValue <= 0) return 'Valor deve ser maior que zero.';
                    return null;
                  },
                ),
                SizedBox(height: Responsive.vp(context, 2.5)),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descricao',
                  hint: 'Ex: Supermercado, Aluguel...',
                  icon: Icons.edit_note_rounded,
                  validator: (v) => v?.isEmpty ?? true ? 'Informe a descricao.' : null,
                ),
                SizedBox(height: Responsive.vp(context, 3)),
                Text(
                  'Pagar com',
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface,
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.vp(context, 1.5)),
                Row(
                  children: [
                    Expanded(
                      child: _AssetTab(
                        title: 'Conta',
                        isSelected: _selectedAssetType == AssetType.bankAccount,
                        onTap: () => setState(() {
                          _selectedAssetType = AssetType.bankAccount;
                          _selectedCard = null;
                        }),
                      ),
                    ),
                    SizedBox(width: Responsive.hp(context, 2)),
                    Expanded(
                      child: _AssetTab(
                        title: 'Cartao',
                        isSelected: _selectedAssetType == AssetType.creditCard,
                        onTap: () => setState(() {
                          _selectedAssetType = AssetType.creditCard;
                          _selectedAccount = null;
                        }),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.vp(context, 2)),
                if (_selectedAssetType == AssetType.bankAccount)
                  DropdownButtonFormField<BankAccountEntity>(
                    initialValue: _selectedAccount,
                    dropdownColor: context.theme.colorScheme.surface,
                    style: TextStyle(color: context.theme.colorScheme.onSurface),
                    decoration: _dropdownDecoration('Selecione uma conta'),
                    items: controller.activeAccounts.map((a) {
                      return DropdownMenuItem(value: a, child: Text(a.name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedAccount = v),
                    validator: (v) => v == null ? 'Selecione a conta' : null,
                  )
                else
                  DropdownButtonFormField<CreditCardEntity>(
                    initialValue: _selectedCard,
                    dropdownColor: context.theme.colorScheme.surface,
                    style: TextStyle(color: context.theme.colorScheme.onSurface),
                    decoration: _dropdownDecoration('Selecione um cartao'),
                    items: controller.activeCards.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCard = v),
                    validator: (v) => v == null ? 'Selecione o cartao' : null,
                  ),
                SizedBox(height: Responsive.vp(context, 3)),
                Text(
                  'Categoria',
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface,
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.vp(context, 1.5)),
                DropdownButtonFormField<CategoryEntity>(
                  initialValue: _selectedCategory,
                  dropdownColor: context.theme.colorScheme.surface,
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                  decoration: _dropdownDecoration('Selecione a categoria'),
                  items: controller.expenseCategories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Selecione a categoria' : null,
                ),
                SizedBox(height: Responsive.vp(context, 5)),
                CustomFilledButton(
                  text: 'SALVAR DESPESA',
                  icon: Icons.check_rounded,
                  isLoading: controller.isSubmitting.value,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.sp(context, 16),
        vertical: Responsive.sp(context, 16),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
        borderSide: BorderSide(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
        borderSide: BorderSide(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.sp(context, 16)),
        borderSide: const BorderSide(color: AppColors.royalBlue),
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3),
        fontSize: Responsive.sp(context, 14),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountCents = int.tryParse(rawAmount) ?? 0;

    await controller.createTransaction(
      type: TransactionType.expense,
      assetType: _selectedAssetType,
      amountCents: amountCents,
      categoryId: _selectedCategory!.id,
      description: _descriptionController.text.trim(),
      transactionDate: DateTime.now(),
      bankAccountId: _selectedAssetType == AssetType.bankAccount ? _selectedAccount!.id : null,
      creditCardId: _selectedAssetType == AssetType.creditCard ? _selectedCard!.id : null,
    );
  }
}

class _AssetTab extends StatelessWidget {
  const _AssetTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: Responsive.vp(context, 1.5)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue.withValues(alpha: 0.15) : context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Responsive.sp(context, 12)),
          border: Border.all(
            color: isSelected ? AppColors.royalBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? context.theme.colorScheme.onSurface : context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: Responsive.sp(context, 14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
