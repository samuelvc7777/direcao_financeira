import 'package:get/get.dart';

import '../../../core/accessibility/accessibility_service.dart';
import '../../../core/network/journey_realtime_bridge.dart';
import '../../../domain/usecases/get_rides_usecase.dart';
import '../../../domain/usecases/journey_use_cases.dart';
import 'journey_controller.dart';

class JourneyBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<JourneyRealtimeBridge>()) {
      Get.lazyPut<JourneyRealtimeBridge>(
        () => DefaultJourneyRealtimeBridge(realtimeClient: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(() => GetActiveShiftUseCase(Get.find()));
    Get.lazyPut(() => GetDailyStatisticsUseCase(Get.find()));
    Get.lazyPut(() => GetShiftHistoryUseCase(Get.find()));
    Get.lazyPut(() => StartShiftUseCase(Get.find()));
    Get.lazyPut(() => PauseShiftUseCase(Get.find()));
    Get.lazyPut(() => ResumeShiftUseCase(Get.find()));
    Get.lazyPut(() => FinishShiftUseCase(Get.find()));
    Get.lazyPut(() => SyncPendingJourneyUseCase(Get.find()));
    Get.lazyPut(() => EnsureReadyForShiftStartUseCase(Get.find()));
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
        ensureReadyForShiftStartUseCase: Get.find(),
        getLocationTrackingStatusUseCase: Get.find(),
        watchLocationTrackingStatusUseCase: Get.find(),
        getRidesUseCase: Get.find(),
        journeyRealtimeBridge: Get.find<JourneyRealtimeBridge>(),
        accessibilityService: Get.find<AccessibilityService>(),
      ),
    );
  }
}
