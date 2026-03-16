import 'package:get/get.dart';

import '../../../domain/repositories/i_category_repository.dart';
import 'categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
    );
  }
}
