import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../config/app_environment.dart';
import '../accessibility/accessibility_service.dart';
import '../network/realtime_feedback_controller.dart';
import '../session/session_coordinator.dart';
import 'core_binding.dart';
import 'provider_binding.dart';

class AppBinding extends Bindings {
  AppBinding({required this.environment, required this.storage});

  final AppEnvironment environment;
  final GetStorage storage;

  @override
  void dependencies() {
    CoreBinding(environment: environment, storage: storage).dependencies();
    ProviderBinding(environment: environment).dependencies();

    if (!Get.isRegistered<RealtimeFeedbackController>()) {
      Get.put<RealtimeFeedbackController>(
        RealtimeFeedbackController(realtimeClient: Get.find()),
        permanent: true,
      );
    }

    unawaited(_restoreSessionAndSyncNativeSettings());
  }

  Future<void> _restoreSessionAndSyncNativeSettings() async {
    await Get.find<SessionCoordinator>().restoreSession();
    if (Get.isRegistered<AccessibilityService>()) {
      await Get.find<AccessibilityService>().syncSettingsWithNative();
    }
  }
}
