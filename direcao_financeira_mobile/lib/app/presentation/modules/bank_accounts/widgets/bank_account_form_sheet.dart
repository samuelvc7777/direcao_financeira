import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/bank_account_entity.dart';
import '../../../widgets/custom_filled_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/scale_button.dart';
import '../bank_accounts_controller.dart';

class BankAccountFormSheet extends StatefulWidget {
  const BankAccountFormSheet({
    super.key,
    this.account,
    required this.controller,
  });

  final BankAccountEntity? account;
  final BankAccountsController controller;

  @override
  State<BankAccountFormSheet> createState() => _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends State<BankAccountFormSheet> {
  static const _supportedAccountTypes = <AccountType>[
    AccountType.checking,
    AccountType.savings,
    AccountType.wallet,
  ];

  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _bankNameController = TextEditingController(
      text: widget.account?.bankName ?? '',
    );
    _balanceController = TextEditingController(
      text: widget.account == null
          ? ''
          : (widget.account!.initialBalanceCents / 100.0).toStringAsFixed(2),
    );
    _selectedType = widget.account?.accountType ?? AccountType.checking;
    _selectedColor = widget.account?.color ?? widget.controller.colorOptions[1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = widget.controller.colorFromHex(_selectedColor);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AccountPreviewHeader(
                    title: widget.account == null
                        ? 'Nova conta'
                        : 'Editar conta',
                    subtitle:
                        'Monte um cadastro com cara de produto premium e leitura instantanea.',
                    previewColor: previewColor,
                    accountName: _nameController.text.isEmpty
                        ? 'Conta principal'
                        : _nameController.text,
                    bankName: _bankNameController.text.isEmpty
                        ? 'Instituicao'
                        : _bankNameController.text,
                    accountType: _selectedType,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome da conta',
                    hint: 'Ex.: Nubank principal',
                    icon: Icons.label_important_rounded,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Informe o nome.' : null,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _bankNameController,
                    label: 'Instituicao',
                    hint: 'Ex.: Itau, Nubank, Dinheiro',
                    icon: Icons.account_balance_rounded,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Informe a instituicao.'
                        : null,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _balanceController,
                    label: 'Saldo inicial',
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
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Informe o saldo.' : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(title: 'Perfil da conta'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _supportedAccountTypes.map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type.label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedType = type),
                        selectedColor: previewColor.withValues(alpha: 0.18),
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        side: BorderSide(
                          color: isSelected
                              ? previewColor.withValues(alpha: 0.34)
                              : context.theme.colorScheme.onSurface.withValues(
                                  alpha: 0.08,
                                ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? previewColor
                              : context.theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(title: 'Assinatura visual'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.controller.colorOptions.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final colorHex = widget.controller.colorOptions[index];
                        final color = widget.controller.colorFromHex(colorHex);
                        final isSelected = _selectedColor == colorHex;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = colorHex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.alphaBlend(
                                    Colors.white.withValues(alpha: 0.18),
                                    color,
                                  ),
                                  color,
                                ],
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? context.theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: isSelected ? 2.5 : 0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: isSelected ? 0.34 : 0.16,
                                  ),
                                  blurRadius: isSelected ? 16 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: context.theme.colorScheme.surface,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    final isLoading = widget.controller.isSubmitting.value;
                    if (widget.account == null) {
                      return CustomFilledButton(
                        text: 'SALVAR CONTA',
                        icon: Icons.add_rounded,
                        isLoading: isLoading,
                        backgroundColor: previewColor,
                        onPressed: _handleSave,
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: ScaleButton(
                            onTap: isLoading
                                ? () {}
                                : () => widget.controller.toggleAccountStatus(
                                    widget.account!,
                                  ),
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                color:
                                    (widget.account!.isActive
                                            ? AppColors.rose
                                            : previewColor)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color:
                                      (widget.account!.isActive
                                              ? AppColors.rose
                                              : previewColor)
                                          .withValues(alpha: 0.28),
                                ),
                              ),
                              child: Icon(
                                widget.account!.isActive
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: widget.account!.isActive
                                    ? AppColors.rose
                                    : previewColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CustomFilledButton(
                            text: 'ATUALIZAR',
                            icon: Icons.check_rounded,
                            isLoading: isLoading,
                            backgroundColor: previewColor,
                            onPressed: _handleSave,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final rawBalance = _balanceController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final balanceCents = int.tryParse(rawBalance) ?? 0;

    if (widget.account == null) {
      await widget.controller.createBankAccount(
        name: _nameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        color: _selectedColor,
        accountType: _selectedType,
        initialBalanceCents: balanceCents,
      );
      return;
    }

    await widget.controller.updateBankAccount(
      id: widget.account!.id,
      name: _nameController.text.trim(),
      bankName: _bankNameController.text.trim(),
      color: _selectedColor,
      accountType: _selectedType,
      initialBalanceCents: balanceCents,
    );
  }
}

class _AccountPreviewHeader extends StatelessWidget {
  const _AccountPreviewHeader({
    required this.title,
    required this.subtitle,
    required this.previewColor,
    required this.accountName,
    required this.bankName,
    required this.accountType,
  });

  final String title;
  final String subtitle;
  final Color previewColor;
  final String accountName;
  final String bankName;
  final AccountType accountType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              previewColor.withValues(alpha: 0.22),
              Colors.white,
            ),
            Color.alphaBlend(
              previewColor.withValues(alpha: 0.06),
              context.theme.colorScheme.surface,
            ),
          ],
        ),
        border: Border.all(color: previewColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.58,
              ),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: previewColor.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _iconForType(accountType),
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      accountType.label.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  accountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bankName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.theme.colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}

IconData _iconForType(AccountType type) {
  switch (type) {
    case AccountType.checking:
      return Icons.account_balance_rounded;
    case AccountType.savings:
      return Icons.savings_rounded;
    case AccountType.wallet:
      return Icons.wallet_rounded;
    case AccountType.investment:
      return Icons.show_chart_rounded;
    case AccountType.other:
      return Icons.layers_clear_rounded;
  }
}
