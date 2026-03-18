import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../data/repositories/credit_card_repository.dart';
import '../../../domain/repositories/i_credit_card_repository.dart';
import 'credit_cards_controller.dart';

class CreditCardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ICreditCardRepository>(
      () => CreditCardRepository(dio: Get.find<Dio>()),
    );
    Get.lazyPut<CreditCardsController>(
      () => CreditCardsController(creditCardRepository: Get.find<ICreditCardRepository>()),
    );
  }
}
