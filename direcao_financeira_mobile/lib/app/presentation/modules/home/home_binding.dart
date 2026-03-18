import 'package:get/get.dart';

import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/usecases/auth_session_use_cases.dart';
import '../../../domain/usecases/bank_account_use_cases.dart';
import '../../../domain/usecases/credit_card_use_cases.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import '../transactions/transactions_binding.dart';
import '../transactions/transactions_controller.dart';
import 'home_controller.dart';

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

    if (!Get.isRegistered<TransactionsController>()) {
      TransactionsBinding().dependencies();
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(
          getStoredUserUseCase: Get.find<GetStoredUserUseCase>(),
          logoutUseCase: Get.find<LogoutUseCase>(),
          loadBankAccountsUseCase: Get.find<LoadBankAccountsUseCase>(),
          loadCreditCardsUseCase: Get.find<LoadCreditCardsUseCase>(),
          getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
