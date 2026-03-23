import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/datasources/journey_route_local_datasource.dart';
import '../../data/models/active_shift_model.dart';
import '../../data/models/tracked_route_point_model.dart';

const _journeyActiveShiftKey = 'journey_local_active_shift';
const _notificationChannelId = 'journey_location_tracking';
const _notificationId = 4812;
const _minimumTrackedSpeedKmH = 10.0;
const _minimumTrackedSpeedMetersPerSecond = _minimumTrackedSpeedKmH / 3.6;

Future<void> initializeLocationTrackingService(GetStorage storage) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _createTrackingNotificationChannel();

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: journeyLocationTrackingServiceOnStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: _notificationChannelId,
      initialNotificationTitle: 'Turno em andamento',
      initialNotificationContent: 'Preparando rastreamento da rota',
      foregroundServiceNotificationId: _notificationId,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: journeyLocationTrackingServiceOnStart,
    ),
  );

  await restoreLocationTrackingServiceFromStorage(storage);
}

Future<void> restoreLocationTrackingServiceFromStorage(
  GetStorage storage,
) async {
  final rawShift = storage.read(_journeyActiveShiftKey);
  if (rawShift is! Map) {
    await LocationTrackingService.stopTracking(markFinished: false);
    return;
  }

  final shift = ActiveShiftModel.fromJson(Map<String, dynamic>.from(rawShift));
  if (shift.isPaused) {
    await LocationTrackingService.stopTracking(markFinished: false);
    return;
  }

  await LocationTrackingService.startTracking(
    localShiftId: shift.id,
    startedAt: shift.startTime,
  );
}

class LocationTrackingService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Stream<Map<String, dynamic>> watchStatus() {
    return _service.on('tracking_status').map((event) {
      if (event == null) {
        return <String, dynamic>{};
      }
      return Map<String, dynamic>.from(event);
    });
  }

  static Future<bool> isRunning() => _service.isRunning();

  static Future<void> startTracking({
    required int localShiftId,
    required DateTime startedAt,
  }) async {
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    _service.invoke('start_tracking', {
      'local_shift_id': localShiftId,
      'started_at': startedAt.toUtc().toIso8601String(),
    });
  }

  static Future<void> resumeTracking({
    required int localShiftId,
    required DateTime startedAt,
  }) async {
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    _service.invoke('resume_tracking', {
      'local_shift_id': localShiftId,
      'started_at': startedAt.toUtc().toIso8601String(),
    });
  }

  static Future<void> pauseTracking() async {
    if (!await _service.isRunning()) {
      return;
    }

    _service.invoke('pause_tracking');
  }

  static Future<void> stopTracking({
    bool markFinished = true,
    DateTime? endedAt,
  }) async {
    if (!await _service.isRunning()) {
      return;
    }

    _service.invoke('stop_tracking', {
      'mark_finished': markFinished,
      if (endedAt != null) 'ended_at': endedAt.toUtc().toIso8601String(),
    });
  }
}

Future<void> _createTrackingNotificationChannel() async {
  const channel = AndroidNotificationChannel(
    _notificationChannelId,
    'Rastreamento de turno',
    description: 'Notificacoes do rastreamento de localizacao da jornada.',
    importance: Importance.low,
  );

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
void journeyLocationTrackingServiceOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final routeDataSource = JourneyRouteLocalDataSourceImpl();
  StreamSubscription<Position>? positionSubscription;
  int? currentLocalShiftId;
  DateTime? currentStartedAt;
  bool isPaused = false;

  Future<void> emitStatus({
    String? issueMessage,
    bool? isTrackingActive,
    double? totalDistanceMeters,
  }) async {
    final payload = await _buildTrackingStatusPayload(
      localShiftId: currentLocalShiftId,
      isPaused: isPaused,
      issueMessage: issueMessage,
      overrideTrackingActive: isTrackingActive,
      overrideTotalDistanceMeters: totalDistanceMeters,
      routeDataSource: routeDataSource,
    );

    service.invoke('tracking_status', payload);

    if (service is AndroidServiceInstance) {
      final distanceKm =
          ((payload['totalDistanceMeters'] as num?)?.toDouble() ?? 0) / 1000;
      final content =
          payload['issueMessage'] as String? ??
          '${distanceKm.toStringAsFixed(1)} km monitorados';
      await service.setForegroundNotificationInfo(
        title: 'Turno em andamento',
        content: content,
      );
    }
  }

  Future<void> cancelTrackingStream() async {
    await positionSubscription?.cancel();
    positionSubscription = null;
  }

  Future<void> startTrackingStream() async {
    await cancelTrackingStream();

    if (currentLocalShiftId == null || currentStartedAt == null) {
      await emitStatus(
        issueMessage: 'Nao foi possivel identificar o turno para rastrear.',
        isTrackingActive: false,
      );
      return;
    }

    final validationPayload = await _buildTrackingStatusPayload(
      localShiftId: currentLocalShiftId,
      isPaused: isPaused,
      routeDataSource: routeDataSource,
    );

    if (validationPayload['issueMessage'] != null) {
      await emitStatus(
        issueMessage: validationPayload['issueMessage'] as String,
        isTrackingActive: false,
      );
      return;
    }

    await routeDataSource.ensureRoute(
      localShiftId: currentLocalShiftId!,
      startedAt: currentStartedAt!,
    );

    final locationSettings = _buildLocationSettings();
    positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) async {
            if (position.speed < _minimumTrackedSpeedMetersPerSecond) {
              final currentRoute = await routeDataSource.getRouteByLocalShiftId(
                currentLocalShiftId!,
                includePoints: false,
              );

              await emitStatus(
                isTrackingActive: true,
                totalDistanceMeters: currentRoute?.totalDistanceMeters ?? 0,
              );
              return;
            }

            final updatedRoute = await routeDataSource.appendPoint(
              localShiftId: currentLocalShiftId!,
              point: TrackedRoutePointModel(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracyMeters: position.accuracy,
                recordedAt: position.timestamp.toLocal(),
              ),
            );

            await emitStatus(
              isTrackingActive: true,
              totalDistanceMeters: updatedRoute?.totalDistanceMeters ?? 0,
            );
          },
          onError: (error) async {
            await emitStatus(
              issueMessage:
                  'Nao foi possivel continuar rastreando a localizacao do turno.',
              isTrackingActive: false,
            );
          },
        );

    await emitStatus(isTrackingActive: true);
  }

  service.on('start_tracking').listen((event) async {
    if (event == null) {
      return;
    }

    currentLocalShiftId = event['local_shift_id'] as int?;
    final startedAtRaw = event['started_at'] as String?;
    currentStartedAt = startedAtRaw != null
        ? DateTime.tryParse(startedAtRaw)?.toLocal()
        : null;
    isPaused = false;

    await startTrackingStream();
  });

  service.on('resume_tracking').listen((event) async {
    if (event == null) {
      return;
    }

    currentLocalShiftId = event['local_shift_id'] as int?;
    final startedAtRaw = event['started_at'] as String?;
    currentStartedAt = startedAtRaw != null
        ? DateTime.tryParse(startedAtRaw)?.toLocal()
        : currentStartedAt;
    isPaused = false;

    await startTrackingStream();
  });

  service.on('pause_tracking').listen((_) async {
    isPaused = true;
    await cancelTrackingStream();
    await emitStatus(
      issueMessage: 'Rastreamento pausado.',
      isTrackingActive: false,
    );
    service.stopSelf();
  });

  service.on('stop_tracking').listen((event) async {
    await cancelTrackingStream();

    final markFinished = event?['mark_finished'] != false;
    final endedAtRaw = event?['ended_at'] as String?;
    final endedAt = endedAtRaw != null
        ? DateTime.tryParse(endedAtRaw)?.toLocal()
        : DateTime.now();

    if (markFinished && currentLocalShiftId != null && endedAt != null) {
      try {
        final finalPosition = await Geolocator.getCurrentPosition(
          locationSettings: _buildLocationSettings(),
        );
        await routeDataSource.appendPoint(
          localShiftId: currentLocalShiftId!,
          point: TrackedRoutePointModel(
            latitude: finalPosition.latitude,
            longitude: finalPosition.longitude,
            accuracyMeters: finalPosition.accuracy,
            recordedAt: finalPosition.timestamp.toLocal(),
          ),
          forceRecord: true,
        );
      } catch (_) {}

      await routeDataSource.markRouteFinished(
        localShiftId: currentLocalShiftId!,
        endedAt: endedAt,
      );
    }

    await emitStatus(isTrackingActive: false);
    service.stopSelf();
  });
}

Future<Map<String, dynamic>> _buildTrackingStatusPayload({
  required IJourneyRouteLocalDataSource routeDataSource,
  required int? localShiftId,
  required bool isPaused,
  String? issueMessage,
  bool? overrideTrackingActive,
  double? overrideTotalDistanceMeters,
}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  final permission = await Geolocator.checkPermission();
  final accuracyStatus = await Geolocator.getLocationAccuracy();
  final hasForegroundPermission =
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
  final hasBackgroundPermission = permission == LocationPermission.always;
  final isPreciseLocation = accuracyStatus == LocationAccuracyStatus.precise;

  final route = localShiftId != null
      ? await routeDataSource.getRouteByLocalShiftId(
          localShiftId,
          includePoints: false,
        )
      : null;
  final totalDistanceMeters =
      overrideTotalDistanceMeters ?? route?.totalDistanceMeters ?? 0;

  final computedIssueMessage =
      issueMessage ??
      _buildTrackingIssueMessage(
        serviceEnabled: serviceEnabled,
        hasForegroundPermission: hasForegroundPermission,
        hasBackgroundPermission: hasBackgroundPermission,
        isPreciseLocation: isPreciseLocation,
      );

  final isTrackingActive =
      overrideTrackingActive ??
      (computedIssueMessage == null && !isPaused && localShiftId != null);

  return {
    'isTrackingActive': isTrackingActive,
    'isLocationServiceEnabled': serviceEnabled,
    'hasForegroundPermission': hasForegroundPermission,
    'hasBackgroundPermission': hasBackgroundPermission,
    'isPreciseLocation': isPreciseLocation,
    'isPaused': isPaused,
    'totalDistanceMeters': totalDistanceMeters,
    'issueMessage': computedIssueMessage,
  };
}

String? _buildTrackingIssueMessage({
  required bool serviceEnabled,
  required bool hasForegroundPermission,
  required bool hasBackgroundPermission,
  required bool isPreciseLocation,
}) {
  if (!serviceEnabled) {
    return 'Ative o GPS do aparelho para continuar rastreando o turno.';
  }

  if (!hasForegroundPermission) {
    return 'Permita a localizacao do app para iniciar o rastreamento do turno.';
  }

  if (!isPreciseLocation) {
    return 'Troque a localizacao aproximada para precisa para rastrear o turno.';
  }

  if (!hasBackgroundPermission) {
    return 'Permita localizacao o tempo todo para continuar o turno com o app fechado.';
  }

  return null;
}

LocationSettings _buildLocationSettings() {
  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25,
      intervalDuration: const Duration(seconds: 5),
      forceLocationManager: false,
    );
  }

  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 25,
  );
}
