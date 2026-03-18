import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/bank_account_entity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_filled_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scale_button.dart';
import 'bank_accounts_controller.dart';

class BankAccountsView extends GetView<BankAccountsController> {
  const BankAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Contas e Carteira',
        subtitle: 'Gerencie seus saldos',
        leadingIcon: Icons.account_balance_wallet_rounded,
        actions: [
          IconButton(
            onPressed: () => _showAccountForm(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountForm(context),
        backgroundColor: AppColors.electricCyan,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Conta'),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.electricCyan),
            );
          }

          final error = controller.errorMessage.value;
          if (error != null) {
            return _ErrorState(
              message: error,
              onRetry: controller.loadBankAccounts,
            );
          }

          if (controller.bankAccounts.isEmpty) {
            return _EmptyState(onCreate: () => _showAccountForm(context));
          }

          return RefreshIndicator(
            color: AppColors.electricCyan,
            onRefresh: controller.loadBankAccounts,
            child: ListView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _SummaryCard(accounts: controller.activeAccounts),
                const SizedBox(height: 24),
                if (controller.activeAccounts.isNotEmpty) ...[
                  const _SectionHeader(title: 'ATIVAS'),
                  const SizedBox(height: 12),
                  ...controller.activeAccounts.map((account) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BankAccountCard(
                          account: account,
                          onTap: () => _showAccountForm(context, account: account),
                        ),
                      )),
                ],
                if (controller.inactiveAccounts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionHeader(title: 'INATIVAS'),
                  const SizedBox(height: 12),
                  ...controller.inactiveAccounts.map((account) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BankAccountCard(
                          account: account,
                          onTap: () => _showAccountForm(context, account: account),
                        ),
                      )),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAccountForm(BuildContext context, {BankAccountEntity? account}) {
    Get.bottomSheet(
      _BankAccountFormSheet(account: account, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({required this.account, required this.onTap});

  final BankAccountEntity account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final isActive = account.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: ScaleButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.electricCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _getIconForType(account.accountType),
                  color: AppColors.aqua,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.bankName,
                      style: TextStyle(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(account.currentBalance),
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.accountType.label,
                    style: TextStyle(
                      color: AppColors.aqua.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance_rounded;
      case AccountType.savings:
        return Icons.savings_rounded;
      case AccountType.wallet:
        return Icons.wallet_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.other:
        return Icons.help_outline_rounded;
    }
  }
}

class _BankAccountFormSheet extends StatefulWidget {
  const _BankAccountFormSheet({this.account, required this.controller});

  final BankAccountEntity? account;
  final BankAccountsController controller;

  @override
  State<_BankAccountFormSheet> createState() => _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends State<_BankAccountFormSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _bankNameController = TextEditingController(text: widget.account?.bankName ?? '');
    
    final initialValue = widget.account != null 
        ? (widget.account!.initialBalanceCents / 100.0).toStringAsFixed(2)
        : '';
    _balanceController = TextEditingController(text: initialValue);
    _selectedType = widget.account?.accountType ?? AccountType.checking;
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.account == null ? 'Nova Conta' : 'Editar Conta',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome da Conta',
                    hint: 'Ex.: Nubank Principal, Carteira...',
                    icon: Icons.label_important_rounded,
                    validator: (value) => value?.isEmpty ?? true ? 'Informe o nome.' : null,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _bankNameController,
                    label: 'Instituicao',
                    hint: 'Ex.: Itau, Nubank, Dinheiro...',
                    icon: Icons.account_balance_rounded,
                    validator: (value) => value?.isEmpty ?? true ? 'Informe o banco.' : null,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _balanceController,
                    label: 'Saldo Inicial',
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
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Informe o saldo.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tipo de Conta',
                    style: TextStyle(color: context.theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AccountType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.electricCyan : context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.white : context.theme.colorScheme.onSurface.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Text(
                            type.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : context.theme.colorScheme.onSurface.withValues(alpha: 0.60),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    final isLoading = widget.controller.isSubmitting.value;
                    if (widget.account == null) {
                      return CustomFilledButton(
                        text: 'SALVAR CONTA',
                        icon: Icons.add_rounded,
                        isLoading: isLoading,
                        onPressed: _handleSave,
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ScaleButton(
                            onTap: isLoading ? () {} : () => widget.controller.toggleAccountStatus(widget.account!),
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                color: (widget.account!.isActive ? AppColors.rose : AppColors.electricCyan).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (widget.account!.isActive ? AppColors.rose : AppColors.electricCyan).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  widget.account!.isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: widget.account!.isActive ? AppColors.rose : AppColors.electricCyan,
                                  size: 26,
                                ),
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

    final rawBalance = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final balanceCents = int.tryParse(rawBalance) ?? 0;

    if (widget.account == null) {
      await widget.controller.createBankAccount(
        name: _nameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountType: _selectedType,
        initialBalanceCents: balanceCents,
      );
    } else {
      await widget.controller.updateBankAccount(
        id: widget.account!.id,
        name: _nameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountType: _selectedType,
        initialBalanceCents: balanceCents,
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.accounts});
  final List<BankAccountEntity> accounts;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final total = accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.electricCyan.withValues(alpha: 0.2),
            context.theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Total',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(total),
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: 'Contas', value: accounts.length.toString()),
              const SizedBox(width: 24),
              _MiniStat(
                label: 'Positiva', 
                value: accounts.where((a) => a.currentBalance >= 0).length.toString(),
                color: AppColors.electricCyan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? context.theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.4),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.amber, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar contas',
              style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6)), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CustomFilledButton(text: 'TENTAR NOVAMENTE', onPressed: onRetry),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1), size: 80),
            const SizedBox(height: 24),
            Text(
              'Nenhuma conta cadastrada',
              style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Cadastre suas contas bancarias, carteira ou investimentos para gerenciar seu saldo.',
              style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomFilledButton(text: 'CADASTRAR MINHA PRIMEIRA CONTA', onPressed: onCreate),
          ],
        ),
      ),
    );
  }
}
