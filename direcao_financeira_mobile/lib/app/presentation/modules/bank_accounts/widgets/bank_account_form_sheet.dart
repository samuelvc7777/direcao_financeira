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

  bool get _isEditing => widget.account != null;

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
    final colorScheme = context.theme.colorScheme;
    final accentColor = widget.controller.colorFromHex(_selectedColor);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormHero(
                        accentColor: accentColor,
                        icon: _iconForType(_selectedType),
                        eyebrow: _isEditing ? 'EDITAR CONTA' : 'NOVA CONTA',
                        title: _nameController.text.trim().isEmpty
                            ? 'Sua conta vai nascer aqui'
                            : _nameController.text.trim(),
                        subtitle: _bankNameController.text.trim().isEmpty
                            ? 'Escolha os dados principais e monte um cadastro limpo e elegante.'
                            : _bankNameController.text.trim(),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionCard(
                              title: 'Identidade',
                              subtitle:
                                  'Os dados principais para reconhecer a conta no app.',
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _nameController,
                                    label: 'Nome da conta',
                                    hint: 'Ex.: Caixa do dia',
                                    icon: Icons.label_important_rounded,
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'Informe o nome.'
                                        : null,
                                    onChanged: (_) => setState(() {}),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: _bankNameController,
                                    label: 'Instituicao',
                                    hint: 'Ex.: Nubank, Itau, Dinheiro',
                                    icon: Icons.account_balance_rounded,
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'Informe a instituicao.'
                                        : null,
                                    onChanged: (_) => setState(() {}),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 16),
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
                                        value?.trim().isEmpty ?? true
                                        ? 'Informe o saldo.'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Perfil',
                              subtitle:
                                  'Defina como essa conta deve aparecer na sua organizacao.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tipo de conta',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _supportedAccountTypes.map((
                                      type,
                                    ) {
                                      return _TypePill(
                                        label: type.label,
                                        icon: _iconForType(type),
                                        isSelected: _selectedType == type,
                                        accentColor: accentColor,
                                        onTap: () => setState(
                                          () => _selectedType = type,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Cor',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.controller.colorOptions
                                        .map((colorHex) {
                                          final color = widget.controller
                                              .colorFromHex(colorHex);
                                          final isSelected =
                                              _selectedColor == colorHex;

                                          return _ColorTile(
                                            color: color,
                                            isSelected: isSelected,
                                            onTap: () => setState(
                                              () => _selectedColor = colorHex,
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              final isLoading =
                                  widget.controller.isSubmitting.value;

                              if (!_isEditing) {
                                return CustomFilledButton(
                                  text: 'CRIAR CONTA',
                                  icon: Icons.check_rounded,
                                  isLoading: isLoading,
                                  backgroundColor: accentColor,
                                  onPressed: _handleSave,
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ScaleButton(
                                      onTap: isLoading
                                          ? () {}
                                          : () => widget.controller
                                                .toggleAccountStatus(
                                                  widget.account!,
                                                ),
                                      child: Container(
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color:
                                              (widget.account!.isActive
                                                      ? AppColors.rose
                                                      : accentColor)
                                                  .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color:
                                                (widget.account!.isActive
                                                        ? AppColors.rose
                                                        : accentColor)
                                                    .withValues(alpha: 0.28),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            widget.account!.isActive
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: widget.account!.isActive
                                                ? AppColors.rose
                                                : accentColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: CustomFilledButton(
                                      text: 'SALVAR ALTERACOES',
                                      icon: Icons.check_rounded,
                                      isLoading: isLoading,
                                      backgroundColor: accentColor,
                                      onPressed: _handleSave,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawBalance = _balanceController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final balanceCents = int.tryParse(rawBalance) ?? 0;

    if (!_isEditing) {
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

class _FormHero extends StatelessWidget {
  const _FormHero({
    required this.accentColor,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final Color accentColor;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.18),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            eyebrow,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.62),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.58),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.14)
              : colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : colorScheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? accentColor
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? accentColor
                    : colorScheme.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.onSurface
                : Colors.transparent,
            width: isSelected ? 2.4 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.36),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: context.theme.colorScheme.surface,
              )
            : null,
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
      return Icons.account_balance_wallet_rounded;
    case AccountType.investment:
      return Icons.show_chart_rounded;
    case AccountType.other:
      return Icons.layers_clear_rounded;
  }
}
