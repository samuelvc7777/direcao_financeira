import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/datasources/transaction_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/bank_account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/credit_card_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_bank_account_repository.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/repositories/i_credit_card_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/usecases/transaction_use_cases.dart';

class CoreBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Storage
    final storage = GetStorage();
    Get.put(storage, permanent: true);

    // 2. Dio (Infra)
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://100.88.15.104:3000',
        connectTimeout: const Duration(seconds: 5),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.read('token');
          if (token is String && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    Get.put(dio, permanent: true);

    // 3. Repositório (Data)
    Get.put<IAuthRepository>(
      AuthRepository(dio: dio, storage: storage),
      permanent: true,
    );
    Get.put<ISubscriptionRepository>(
      SubscriptionRepository(dio: dio, storage: storage),
      permanent: true,
    );
    Get.put<ICategoryRepository>(CategoryRepository(dio: dio), permanent: true);
    Get.put<IBankAccountRepository>(BankAccountRepository(dio: dio), permanent: true);
    Get.put<ICreditCardRepository>(CreditCardRepository(dio: dio), permanent: true);

    // 4. Transações (Data & Domain)
    Get.put<ITransactionDataSource>(TransactionRemoteDataSource(dio: dio), permanent: true);
    Get.put<ITransactionRepository>(
      TransactionRepository(dataSource: Get.find<ITransactionDataSource>()),
      permanent: true,
    );
    
    // Use Cases Globais
    Get.put(CreateTransactionUseCase(Get.find<ITransactionRepository>()), permanent: true);
    Get.put(GetTransactionsUseCase(Get.find<ITransactionRepository>()), permanent: true);
  }
}
