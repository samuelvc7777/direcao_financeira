import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/datasources/transaction_datasource.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../domain/repositories/i_category_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../domain/usecases/transaction_use_cases.dart';
import 'transactions_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<Dio>();

    if (!Get.isRegistered<ITransactionDataSource>()) {
      Get.lazyPut<ITransactionDataSource>(
        () => TransactionRemoteDataSource(dio: dio),
      );
    }

    if (!Get.isRegistered<ITransactionRepository>()) {
      Get.lazyPut<ITransactionRepository>(
        () => TransactionRepository(dataSource: Get.find<ITransactionDataSource>()),
      );
    }

    if (!Get.isRegistered<CreateTransactionUseCase>()) {
      Get.lazyPut(
        () => CreateTransactionUseCase(Get.find<ITransactionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetTransactionsUseCase>()) {
      Get.lazyPut(
        () => GetTransactionsUseCase(Get.find<ITransactionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<UpdateTransactionUseCase>()) {
      Get.lazyPut(
        () => UpdateTransactionUseCase(Get.find<ITransactionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DeleteTransactionUseCase>()) {
      Get.lazyPut(
        () => DeleteTransactionUseCase(Get.find<ITransactionRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetCategoriesUseCase>()) {
      Get.lazyPut(() => GetCategoriesUseCase(Get.find<ICategoryRepository>()), fenix: true);
    }
    if (!Get.isRegistered<GetBankAccountsUseCase>()) {
      Get.lazyPut(() => GetBankAccountsUseCase(Get.find<IBankAccountRepository>()), fenix: true);
    }
    if (!Get.isRegistered<GetCreditCardsUseCase>()) {
      Get.lazyPut(() => GetCreditCardsUseCase(Get.find<ICreditCardRepository>()), fenix: true);
    }

    if (!Get.isRegistered<TransactionsController>()) {
      Get.lazyPut<TransactionsController>(
        () => TransactionsController(
          createTransactionUseCase: Get.find<CreateTransactionUseCase>(),
          updateTransactionUseCase: Get.find<UpdateTransactionUseCase>(),
          deleteTransactionUseCase: Get.find<DeleteTransactionUseCase>(),
          getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
          getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
          getBankAccountsUseCase: Get.find<GetBankAccountsUseCase>(),
          getCreditCardsUseCase: Get.find<GetCreditCardsUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
