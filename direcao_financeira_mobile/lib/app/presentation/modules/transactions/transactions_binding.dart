import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'transactions_controller.dart';
import '../../../data/datasources/transaction_datasource.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import '../../../data/repositories/bank_account_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import '../../../data/repositories/credit_card_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import '../../../domain/repositories/i_category_repository.dart';
import '../../../domain/usecases/transaction_use_cases.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<Dio>();

    // Datasources
    Get.lazyPut<ITransactionDataSource>(() => TransactionRemoteDataSource(dio: dio));

    // Repositories
    Get.lazyPut<ITransactionRepository>(
      () => TransactionRepository(dataSource: Get.find<ITransactionDataSource>()),
    );
    Get.lazyPut<IBankAccountRepository>(() => BankAccountRepository(dio: dio));
    Get.lazyPut<ICreditCardRepository>(() => CreditCardRepository(dio: dio));
    // ICategoryRepository is already provided in CoreBinding

    // Use Cases
    Get.lazyPut(() => CreateTransactionUseCase(Get.find<ITransactionRepository>()));
    Get.lazyPut(() => GetTransactionsUseCase(Get.find<ITransactionRepository>()));

    Get.lazyPut<TransactionsController>(
      () => TransactionsController(
        createTransactionUseCase: Get.find<CreateTransactionUseCase>(),
        getTransactionsUseCase: Get.find<GetTransactionsUseCase>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        bankAccountRepository: Get.find<IBankAccountRepository>(),
        creditCardRepository: Get.find<ICreditCardRepository>(),
      ),
    );
  }
}
