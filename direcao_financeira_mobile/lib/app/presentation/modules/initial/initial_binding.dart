import 'package:get/get.dart';
import 'initial_controller.dart';
import '../home/home_controller.dart';
import '../settings/settings_controller.dart';
import '../transactions/transactions_controller.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/repositories/i_category_repository.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Injeta o controlador do modulo Initial
    Get.lazyPut<InitialController>(() => InitialController());

    // Controladores das abas (Dependências carregadas via CoreBinding)
    Get.lazyPut<HomeController>(
      () => HomeController(
        authRepository: Get.find<IAuthRepository>(),
        bankAccountRepository: Get.find<IBankAccountRepository>(),
        creditCardRepository: Get.find<ICreditCardRepository>(),
        getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
      ),
    );
    Get.lazyPut<TransactionsController>(
      () => TransactionsController(
        createTransactionUseCase: Get.find<CreateTransactionUseCase>(),
        getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        bankAccountRepository: Get.find<IBankAccountRepository>(),
        creditCardRepository: Get.find<ICreditCardRepository>(),
      ),
    );
    Get.lazyPut<SettingsController>(
      () => SettingsController(authRepository: Get.find<IAuthRepository>()),
    );
  }
}
