import 'package:get/get.dart';

import '../../../core/dashboard/dashboard_refresh_notifier.dart';
import '../../../core/network/realtime_client.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/usecases/auth_session_use_cases.dart';
import '../../../domain/usecases/bank_account_use_cases.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import 'home_controller.dart';
import 'home_tab_navigation.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetStoredUserUseCase>()) {
      Get.lazyPut(
        () => GetStoredUserUseCase(Get.find<IAuthRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LogoutUseCase>()) {
      Get.lazyPut(
        () => LogoutUseCase(Get.find<IAuthRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LoadBankAccountsUseCase>()) {
      Get.lazyPut(
        () => LoadBankAccountsUseCase(Get.find<IBankAccountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LoadCreditCardsUseCase>()) {
      Get.lazyPut(
        () => LoadCreditCardsUseCase(Get.find<ICreditCardRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetTransactionsUseCase>()) {
      Get.lazyPut(
        () => GetTransactionsUseCase(Get.find<ITransactionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HomeTabNavigation>()) {
      Get.lazyPut<HomeTabNavigation>(() => GetHomeTabNavigation(), fenix: true);
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(
          getStoredUserUseCase: Get.find<GetStoredUserUseCase>(),
          logoutUseCase: Get.find<LogoutUseCase>(),
          loadBankAccountsUseCase: Get.find<LoadBankAccountsUseCase>(),
          loadCreditCardsUseCase: Get.find<LoadCreditCardsUseCase>(),
          getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
          dashboardRefreshNotifier: Get.find<DashboardRefreshNotifier>(),
          homeTabNavigation: Get.find<HomeTabNavigation>(),
          realtimeClient: Get.find<RealtimeClient>(),
        ),
        fenix: true,
      );
    }
  }
}
