import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/app_bubble/app_bubble_service.dart';
import 'package:direcao_financeira_mobile/app/core/accessibility/accessibility_service.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/core/network/journey_realtime_bridge.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/active_shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/finish_shift_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/journey_statistics_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/location_tracking_status_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/paged_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_route_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_journey_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/journey_use_cases.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/journey_runtime_coordinator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeJourneyRepository implements IJourneyRepository {
  final trackingController =
      StreamController<LocationTrackingStatusEntity>.broadcast();
  Either<Failure, LocationTrackingStatusEntity> trackingStatusResult = const Right(
    LocationTrackingStatusEntity(
      isTrackingActive: true,
      isLocationServiceEnabled: true,
      hasForegroundPermission: true,
      hasBackgroundPermission: true,
      isPreciseLocation: true,
      isPaused: false,
      totalDistanceMeters: 1000,
      idleTimeSeconds: 10,
    ),
  );
  Either<Failure, int> syncResult = const Right(2);

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  getLocationTrackingStatus() async => trackingStatusResult;

  @override
  Future<Either<Failure, int>> syncPendingShifts() async => syncResult;

  @override
  Stream<LocationTrackingStatusEntity> watchLocationTrackingStatus() =>
      trackingController.stream;

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  ensureReadyForShiftStart() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, FinishShiftResultEntity>> finishShift() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, ActiveShiftEntity?>> getActiveShift() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, JourneyStatisticsEntity>> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, PagedResultEntity<ShiftEntity>>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
    int offset = 0,
    int limit = 20,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, ShiftRouteEntity>> getShiftRoute({
    int? localShiftId,
    int? remoteShiftId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> pauseShift() async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> resumeShift() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> startShift() async => throw UnimplementedError();
}

class _FakeJourneyRealtimeBridge implements JourneyRealtimeBridge {
  @override
  final RxBool isOnline = true.obs;

  VoidCallback? onRideChanged;
  bool unbound = false;

  @override
  void bind({required VoidCallback onRideChanged}) {
    this.onRideChanged = onRideChanged;
  }

  @override
  void unbind() {
    unbound = true;
  }
}

class _FakeAccessibilityService implements AccessibilityService {
  @override
  final RxBool isServiceEnabled = true.obs;

  @override
  bool persistedTrafficLightActive = false;

  @override
  Future<void> requestAccessibilityPermission() async {}

  @override
  Future<void> setJourneyActive(bool isActive) async {}

  @override
  Future<void> setTrafficLightActive(bool isActive) async {
    persistedTrafficLightActive = isActive;
  }

  @override
  Future<void> syncSettingsWithNative() async {}
}

class _FakeAppBubbleService implements AppBubbleService {
  bool bubbleRunning = false;
  bool permissionGranted = true;

  @override
  Future<bool> isBubbleRunning() async => bubbleRunning;

  @override
  Future<bool> isOverlayPermissionGranted() async => permissionGranted;

  @override
  Future<void> openOverlayPermissionSettings() async {}

  @override
  Future<void> startBubble() async {
    bubbleRunning = true;
  }

  @override
  Future<void> stopBubble() async {
    bubbleRunning = false;
  }
}

void main() {
  group('JourneyRuntimeCoordinator', () {
    late _FakeJourneyRepository repository;
    late _FakeJourneyRealtimeBridge bridge;
    late _FakeAccessibilityService accessibilityService;
    late _FakeAppBubbleService appBubbleService;
    late JourneyRuntimeCoordinator coordinator;

    setUp(() {
      repository = _FakeJourneyRepository();
      bridge = _FakeJourneyRealtimeBridge();
      accessibilityService = _FakeAccessibilityService();
      appBubbleService = _FakeAppBubbleService();
      coordinator = JourneyRuntimeCoordinator(
        journeyRealtimeBridge: bridge,
        getLocationTrackingStatusUseCase: GetLocationTrackingStatusUseCase(
          repository,
        ),
        watchLocationTrackingStatusUseCase: WatchLocationTrackingStatusUseCase(
          repository,
        ),
        syncPendingJourneyUseCase: SyncPendingJourneyUseCase(repository),
        accessibilityService: accessibilityService,
        appBubbleService: appBubbleService,
      );
    });

    tearDown(() async {
      await repository.trackingController.close();
    });

    test('carrega status de tracking e sincroniza pendencias', () async {
      final status = await coordinator.loadTrackingStatus();
      final synced = await coordinator.syncPendingShifts();

      expect(status, isNotNull);
      expect(status!.totalDistanceMeters, 1000);
      expect(synced, 2);
    });

    test('toggleAssistant ativa e desativa o overlay', () async {
      final feedbacks = <String>[];

      await coordinator.toggleAssistant(
        isAssistantActive: false,
        onAssistantStateChanged: (_) {},
        onBusyStateChanged: (_) {},
        showSuccess: (title, message) => feedbacks.add('$title:$message'),
        showWarning: (title, message) => feedbacks.add('$title:$message'),
        showError: (title, message) => feedbacks.add('$title:$message'),
      );

      expect(appBubbleService.bubbleRunning, isTrue);
      expect(feedbacks.single, contains('Assistente ativado'));

      await coordinator.toggleAssistant(
        isAssistantActive: true,
        onAssistantStateChanged: (_) {},
        onBusyStateChanged: (_) {},
        showSuccess: (title, message) => feedbacks.add('$title:$message'),
        showWarning: (title, message) => feedbacks.add('$title:$message'),
        showError: (title, message) => feedbacks.add('$title:$message'),
      );

      expect(appBubbleService.bubbleRunning, isFalse);
    });
  });
}
