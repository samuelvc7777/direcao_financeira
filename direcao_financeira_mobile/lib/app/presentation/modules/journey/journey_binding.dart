import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/datasources/i_journey_datasource.dart';
import '../../../data/datasources/journey_local_datasource.dart';
import '../../../data/datasources/journey_route_local_datasource.dart';
import '../../../data/datasources/journey_remote_datasource.dart';
import '../../../data/datasources/location_tracking_datasource.dart';
import '../../../data/datasources/i_ride_datasource.dart';
import '../../../data/datasources/ride_remote_datasource.dart';
import '../../../data/repositories/journey_repository_impl.dart';
import '../../../data/repositories/ride_repository_impl.dart';
import '../../../domain/repositories/i_journey_repository.dart';
import '../../../domain/repositories/i_ride_repository.dart';
import '../../../domain/usecases/journey_use_cases.dart';
import '../../../domain/usecases/get_rides_usecase.dart';
import 'journey_controller.dart';

class JourneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IJourneyDataSource>(
      () => JourneyRemoteDataSource(dio: Get.find<Dio>()),
    );
    Get.lazyPut<IJourneyLocalDataSource>(
      () => JourneyLocalDataSourceImpl(storage: Get.find<GetStorage>()),
    );
    Get.lazyPut<IJourneyRouteLocalDataSource>(
      JourneyRouteLocalDataSourceImpl.new,
      fenix: true,
    );
    Get.lazyPut<ILocationTrackingDataSource>(
      () => LocationTrackingDataSourceImpl(
        routeLocalDataSource: Get.find<IJourneyRouteLocalDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<IJourneyRepository>(
      () => JourneyRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
        routeLocalDataSource: Get.find(),
        locationTrackingDataSource: Get.find(),
        connectionController: Get.find(),
      ),
    );

    Get.lazyPut<IRideDataSource>(
      () => RideRemoteDataSource(dio: Get.find<Dio>()),
    );
    Get.lazyPut<IRideRepository>(() => RideRepositoryImpl(Get.find()));

    Get.lazyPut(() => GetActiveShiftUseCase(Get.find()));
    Get.lazyPut(() => GetDailyStatisticsUseCase(Get.find()));
    Get.lazyPut(() => GetShiftHistoryUseCase(Get.find()));
    Get.lazyPut(() => StartShiftUseCase(Get.find()));
    Get.lazyPut(() => PauseShiftUseCase(Get.find()));
    Get.lazyPut(() => ResumeShiftUseCase(Get.find()));
    Get.lazyPut(() => FinishShiftUseCase(Get.find()));
    Get.lazyPut(() => SyncPendingJourneyUseCase(Get.find()));
    Get.lazyPut(() => GetLocationTrackingStatusUseCase(Get.find()));
    Get.lazyPut(() => WatchLocationTrackingStatusUseCase(Get.find()));
    Get.lazyPut(() => GetShiftRouteUseCase(Get.find()));
    Get.lazyPut(() => GetRidesUseCase(Get.find()));

    Get.lazyPut<JourneyController>(
      () => JourneyController(
        getActiveShift: Get.find(),
        getDailyStatistics: Get.find(),
        getShiftHistory: Get.find(),
        startShiftUseCase: Get.find(),
        pauseShiftUseCase: Get.find(),
        resumeShiftUseCase: Get.find(),
        finishShiftUseCase: Get.find(),
        syncPendingJourneyUseCase: Get.find(),
        getLocationTrackingStatusUseCase: Get.find(),
        watchLocationTrackingStatusUseCase: Get.find(),
        getRidesUseCase: Get.find(),
      ),
    );
  }
}


