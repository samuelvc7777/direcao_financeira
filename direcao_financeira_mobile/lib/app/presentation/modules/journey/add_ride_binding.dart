import 'package:get/get.dart';

import '../../../domain/usecases/create_detected_ride_usecase.dart';
import 'add_ride_controller.dart';

class AddRideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddRideController>(
      () => AddRideController(
        createDetectedRideUseCase: Get.find<CreateDetectedRideUseCase>(),
      ),
    );
  }
}
