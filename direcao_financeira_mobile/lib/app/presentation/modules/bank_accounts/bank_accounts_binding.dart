import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../data/repositories/bank_account_repository.dart';
import '../../../domain/repositories/i_bank_account_repository.dart';
import 'bank_accounts_controller.dart';

class BankAccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IBankAccountRepository>(
      () => BankAccountRepository(dio: Get.find<Dio>()),
    );
    Get.lazyPut<BankAccountsController>(
      () => BankAccountsController(bankAccountRepository: Get.find<IBankAccountRepository>()),
    );
  }
}
