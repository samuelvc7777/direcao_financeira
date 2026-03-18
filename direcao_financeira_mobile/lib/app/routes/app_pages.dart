import 'package:get/get.dart';
import '../presentation/modules/login/login_view.dart';
import '../presentation/modules/login/login_binding.dart';
import '../presentation/modules/home/home_view.dart';
import '../presentation/modules/home/home_binding.dart';
import '../presentation/modules/register/register_view.dart';
import '../presentation/modules/register/register_binding.dart';
import '../presentation/modules/initial/initial_view.dart';
import '../presentation/modules/initial/initial_binding.dart';
import '../presentation/modules/settings/settings_binding.dart';
import '../presentation/modules/settings/settings_view.dart';
import '../presentation/modules/subscription/subscription_binding.dart';
import '../presentation/modules/subscription/subscription_view.dart';
import '../presentation/modules/categories/categories_binding.dart';
import '../presentation/modules/categories/categories_view.dart';

import '../presentation/modules/bank_accounts/bank_accounts_binding.dart';
import '../presentation/modules/bank_accounts/bank_accounts_view.dart';
import '../presentation/modules/credit_cards/credit_cards_binding.dart';
import '../presentation/modules/credit_cards/credit_cards_view.dart';
import '../presentation/modules/transactions/transactions_binding.dart';
import '../presentation/modules/transactions/views/expense_form_view.dart';
import '../presentation/modules/transactions/views/income_form_view.dart';
import '../presentation/modules/transactions/views/credit_card_form_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String initial = '/initial';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String categories = '/categories';
  static const String bankAccounts = '/bank-accounts';
  static const String creditCards = '/credit-cards';
  static const String transactionExpense = '/transactions/expense';
  static const String transactionIncome = '/transactions/income';
  static const String transactionCreditCard = '/transactions/credit-card';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.initial,
      page: () => const InitialView(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.bankAccounts,
      page: () => const BankAccountsView(),
      binding: BankAccountsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.creditCards,
      page: () => const CreditCardsView(),
      binding: CreditCardsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.transactionExpense,
      page: () => const ExpenseFormView(),
      binding: TransactionsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.transactionIncome,
      page: () => const IncomeFormView(),
      binding: TransactionsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.transactionCreditCard,
      page: () => const CreditCardFormView(),
      binding: TransactionsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
