import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/portfolio_shared_widgets.dart';
import 'bank_accounts_controller.dart';
import 'widgets/bank_account_form_sheet.dart';
import 'widgets/bank_accounts_content.dart';

class BankAccountsView extends GetView<BankAccountsController> {
  const BankAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Minhas Contas',
        subtitle: 'Caixa, liquidez e reservas em uma visao mais premium',
        leadingIcon: Icons.account_balance_wallet_rounded,
        actions: [
          IconButton(
            onPressed: () => _showAccountForm(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Conta'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return PortfolioErrorState(
            title: 'Erro ao carregar contas',
            message: error,
            accentColor: controller.colorFromHex(controller.colorOptions[1]),
            onRetry: controller.loadBankAccounts,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadBankAccounts,
          child: BankAccountsContent(
            activeAccounts: controller.activeAccounts,
            inactiveAccounts: controller.inactiveAccounts,
            onCreatePressed: _showAccountForm,
            onAccountPressed: (account) =>
                _showAccountForm(accountId: account.id),
          ),
        );
      }),
    );
  }

  void _showAccountForm({int? accountId}) {
    final account = accountId == null
        ? null
        : controller.bankAccounts.firstWhereOrNull(
            (item) => item.id == accountId,
          );

    Get.bottomSheet(
      BankAccountFormSheet(account: account, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
