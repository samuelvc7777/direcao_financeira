import 'package:get/get.dart';

import '../../../core/config/app_environment.dart';
import '../../../data/services/address_autocomplete_service.dart';
import '../../../data/services/ride_route_estimator.dart';
import '../../../domain/usecases/create_detected_ride_usecase.dart';
import 'add_ride_controller.dart';

class AddRideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddRideController>(
      () => AddRideController(
        createDetectedRideUseCase: Get.find<CreateDetectedRideUseCase>(),
        addressAutocompleteService: AddressAutocompleteService(
          googleMapsApiKey: Get.find<AppEnvironment>().googleMapsApiKey,
        ),
        routeEstimator: RideRouteEstimator(
          googleMapsApiKey: Get.find<AppEnvironment>().googleMapsApiKey,
          openRouteServiceApiKey:
              Get.find<AppEnvironment>().openRouteServiceApiKey,
        ),
      ),
    );
  }
}
