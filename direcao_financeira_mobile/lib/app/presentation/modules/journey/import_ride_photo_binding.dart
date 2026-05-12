import 'package:get/get.dart';

import '../../../data/services/ride_route_estimator.dart';
import '../../../domain/services/movesj_history_screenshot_parser.dart';
import '../../../domain/usecases/create_detected_ride_usecase.dart';
import 'import_ride_photo_controller.dart';

class ImportRidePhotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImportRidePhotoController>(
      () => ImportRidePhotoController(
        createFinishedRideUseCase: Get.find<CreateFinishedRideUseCase>(),
        parser: const MoveSjHistoryScreenshotParser(),
        routeEstimator: RideRouteEstimator(),
      ),
    );
  }
}
