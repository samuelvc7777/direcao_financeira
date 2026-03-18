import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../preferences/app_preferences.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/bank_account_datasource.dart';
import '../../data/datasources/category_datasource.dart';
import '../../data/datasources/credit_card_datasource.dart';
import '../../data/datasources/subscription_datasource.dart';
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

class CoreBinding extends Bindings {
  @override
  void dependencies() {
    final storage = GetStorage();
    Get.put(storage, permanent: true);
    Get.put<AppPreferences>(
      GetStorageAppPreferences(storage: storage),
      permanent: true,
    );

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

    Get.put<IAuthRemoteDataSource>(
      AuthRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<IAuthLocalDataSource>(
      AuthLocalDataSource(storage: storage),
      permanent: true,
    );
    Get.put<IBankAccountDataSource>(
      BankAccountRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ICategoryDataSource>(
      CategoryRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ICreditCardDataSource>(
      CreditCardRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ISubscriptionRemoteDataSource>(
      SubscriptionRemoteDataSource(dio: dio),
      permanent: true,
    );
    Get.put<ISubscriptionLocalDataSource>(
      SubscriptionLocalDataSource(storage: storage),
      permanent: true,
    );
    Get.put<ITransactionDataSource>(
      TransactionRemoteDataSource(dio: dio),
      permanent: true,
    );

    Get.put<IAuthRepository>(
      AuthRepository(
        remoteDataSource: Get.find<IAuthRemoteDataSource>(),
        localDataSource: Get.find<IAuthLocalDataSource>(),
      ),
      permanent: true,
    );
    Get.put<IBankAccountRepository>(
      BankAccountRepository(dataSource: Get.find<IBankAccountDataSource>()),
      permanent: true,
    );
    Get.put<ICategoryRepository>(
      CategoryRepository(dataSource: Get.find<ICategoryDataSource>()),
      permanent: true,
    );
    Get.put<ICreditCardRepository>(
      CreditCardRepository(dataSource: Get.find<ICreditCardDataSource>()),
      permanent: true,
    );
    Get.put<ISubscriptionRepository>(
      SubscriptionRepository(
        remoteDataSource: Get.find<ISubscriptionRemoteDataSource>(),
        localDataSource: Get.find<ISubscriptionLocalDataSource>(),
      ),
      permanent: true,
    );
    Get.put<ITransactionRepository>(
      TransactionRepository(dataSource: Get.find<ITransactionDataSource>()),
      permanent: true,
    );
  }
}
