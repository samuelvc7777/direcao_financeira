import 'package:get/get.dart';
import '../../../data/datasources/traffic_light_local_datasource.dart';
import '../../../data/repositories/traffic_light_repository.dart';
import '../../../domain/repositories/i_traffic_light_repository.dart';
import '../../../domain/usecases/traffic_light_settings_use_cases.dart';
import 'traffic_light_settings_controller.dart';

class TrafficLightSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ITrafficLightLocalDataSource>(
      () => TrafficLightLocalDataSourceImpl(storage: Get.find()),
    );
    Get.lazyPut<ITrafficLightRepository>(
      () => TrafficLightRepositoryImpl(localDataSource: Get.find()),
    );
    Get.lazyPut(() => GetTrafficLightSettingsUseCase(Get.find()));
    Get.lazyPut(() => SaveTrafficLightSettingsUseCase(Get.find()));

    Get.lazyPut<TrafficLightSettingsController>(
      () => TrafficLightSettingsController(
        getSettingsUseCase: Get.find(),
        saveSettingsUseCase: Get.find(),
      ),
    );
  }
}
