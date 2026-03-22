import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import 'home_controller.dart';
import 'widgets/accounts_section.dart';
import 'widgets/balance_card.dart';
import 'widgets/credit_cards_section.dart';
import 'widgets/expenses_chart_section.dart';
import 'widgets/goals_section.dart';
import 'widgets/month_selector.dart';
import 'widgets/recent_transactions_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Dashboard',
        subtitle: 'Resumo financeiro do mes',
        leadingIcon: Icons.dashboard_rounded,
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360
              ? 12.0
              : width < 430
              ? 16.0
              : 20.0;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                100,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      const MonthSelector(),
                      const BalanceCard(),
                      const AccountsSection(),
                      CreditCardsSection(controller: controller),
                      const ExpensesChartSection(),
                      RecentTransactionsSection(
                        onViewAllTransactions: controller.openTransactionsTab,
                      ),
                      const GoalsSection(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
