import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/entities/credit_card_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_filled_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../transactions_controller.dart';

class CreditCardFormView extends StatefulWidget {
  const CreditCardFormView({super.key});

  @override
  State<CreditCardFormView> createState() => _CreditCardFormViewState();
}

class _CreditCardFormViewState extends State<CreditCardFormView> {
  final TransactionsController controller = Get.find<TransactionsController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
        title: 'Nova Compra',
        subtitle: 'Registre um gasto no cartao',
        leadingIcon: Icons.credit_card_rounded,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDependencies.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.aqua));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descricao',
                  hint: 'Ex: Jantar, Cinema, Loja...',
                  icon: Icons.edit_note_rounded,
                  validator: (v) => v?.isEmpty ?? true ? 'Informe a descricao.' : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Cartao de Credito',
                  style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CreditCardEntity>(
                  value: _selectedCard,
                  dropdownColor: context.theme.colorScheme.surface,
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                  decoration: _dropdownDecoration('Selecione um cartao'),
                  items: controller.activeCards.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCard = v),
                  validator: (v) => v == null ? 'Selecione o cartao' : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Categoria',
                  style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoryEntity>(
                  value: _selectedCategory,
                  dropdownColor: context.theme.colorScheme.surface,
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                  decoration: _dropdownDecoration('Selecione a categoria'),
                  items: controller.expenseCategories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Selecione a categoria' : null,
                ),
                const SizedBox(height: 40),
                CustomFilledButton(
                  text: 'SALVAR COMPRA',
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
      fillColor: context.theme.colorScheme.onSurface.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: context.theme.colorScheme.onSurface.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: context.theme.colorScheme.onSurface.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.royalBlue),
      ),
      hintText: hint,
      hintStyle: TextStyle(color: context.theme.colorScheme.onSurface.withOpacity(0.3)),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountCents = int.tryParse(rawAmount) ?? 0;

    final success = await controller.createTransaction(
      type: TransactionType.expense,
      assetType: AssetType.creditCard,
      amountCents: amountCents,
      categoryId: _selectedCategory!.id,
      description: _descriptionController.text.trim(),
      transactionDate: DateTime.now(),
      creditCardId: _selectedCard!.id,
    );

    if (success) {
      Get.back();
    }
  }
}
