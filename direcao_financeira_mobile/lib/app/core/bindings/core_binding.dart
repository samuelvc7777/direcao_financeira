import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class CoreBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Storage
    final storage = GetStorage();
    Get.put(storage, permanent: true);

    // 2. Dio (Infra)
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.3.114:3000',
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
  }
}
