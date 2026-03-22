import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/connection_controller.dart';
import '../../domain/entities/active_shift_entity.dart';
import '../../domain/entities/finish_shift_result_entity.dart';
import '../../domain/entities/journey_statistics_entity.dart';
import '../../domain/entities/location_tracking_status_entity.dart';
import '../../domain/entities/shift_route_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../../domain/repositories/i_journey_repository.dart';
import '../datasources/i_journey_datasource.dart';
import '../datasources/journey_local_datasource.dart';
import '../datasources/journey_route_local_datasource.dart';
import '../datasources/location_tracking_datasource.dart';
import '../models/active_shift_model.dart';

class JourneyRepositoryImpl implements IJourneyRepository {
  JourneyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.routeLocalDataSource,
    required this.locationTrackingDataSource,
    required this.connectionController,
  });

  final IJourneyDataSource remoteDataSource;
  final IJourneyLocalDataSource localDataSource;
  final IJourneyRouteLocalDataSource routeLocalDataSource;
  final ILocationTrackingDataSource locationTrackingDataSource;
  final ConnectionController connectionController;
  Future<int>? _syncPendingShiftsFuture;

  String _handleDioError(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        final message = responseData['message'];
        if (message is List) {
          return message.join(', ');
        }
        return message.toString();
      }
      return error.message ?? 'Erro de conexao com o servidor.';
    }

    return error.toString();
  }

  @override
  Future<Either<Failure, ActiveShiftEntity?>> getActiveShift() async {
    try {
      final localShift = await localDataSource.getActiveShift();
      if (localShift != null) {
        return Right(await _enrichLocalActiveShift(localShift));
      }

      if (connectionController.isOnline.value) {
        await _syncPendingShiftsInternal();
      }

      final activeShift = await remoteDataSource.getActiveShift();
      if (activeShift != null) {
        await localDataSource.saveActiveShift(activeShift);
      }

      return Right(activeShift);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, JourneyStatisticsEntity>> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async {
    try {
      final statistics = await remoteDataSource.getDailyStatistics(
        filter: filter,
        date: date,
        endDate: endDate,
      );
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, List<ShiftEntity>>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async {
    try {
      if (connectionController.isOnline.value) {
        await _syncPendingShiftsInternal();
      }

      final shifts = await remoteDataSource.getShiftHistory(
        filter: filter,
        date: date,
        endDate: endDate,
      );
      final merged = await _mergePendingShiftHistory(shifts);
      return Right(merged);
    } catch (e) {
      final pendingShifts = await localDataSource.getPendingFinishedShifts();
      if (pendingShifts.isNotEmpty) {
        return Right(await _mergePendingShiftHistory(const []));
      }
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> startShift() async {
    try {
      final trackingStatus =
          await locationTrackingDataSource.ensureReadyForShiftStart();
      if (trackingStatus.issueMessage != null) {
        return Left(ValidationFailure(trackingStatus.issueMessage!));
      }

      final shift = await localDataSource.startShift();
      await routeLocalDataSource.ensureRoute(
        localShiftId: shift.id,
        startedAt: shift.startTime,
      );

      try {
        await locationTrackingDataSource.startTracking(
          localShiftId: shift.id,
          startedAt: shift.startTime,
        );
      } catch (e) {
        await localDataSource.clearActiveShift();
        await routeLocalDataSource.deleteRoute(shift.id);
        return Left(ServerFailure(_handleDioError(e)));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> pauseShift() async {
    try {
      final pausedShift = await localDataSource.pauseShift();

      try {
        await locationTrackingDataSource.pauseTracking();
      } catch (e) {
        await localDataSource.resumeShift();
        return Left(ServerFailure(_handleDioError(e)));
      }

      await routeLocalDataSource.ensureRoute(
        localShiftId: pausedShift.id,
        startedAt: pausedShift.startTime,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resumeShift() async {
    try {
      final trackingStatus =
          await locationTrackingDataSource.ensureReadyForShiftStart();
      if (trackingStatus.issueMessage != null) {
        return Left(ValidationFailure(trackingStatus.issueMessage!));
      }

      final resumedShift = await localDataSource.resumeShift();

      try {
        await locationTrackingDataSource.resumeTracking(
          localShiftId: resumedShift.id,
          startedAt: resumedShift.startTime,
        );
      } catch (e) {
        await localDataSource.pauseShift();
        return Left(ServerFailure(_handleDioError(e)));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, FinishShiftResultEntity>> finishShift() async {
    try {
      final activeShift = await localDataSource.getActiveShift();
      if (activeShift == null) {
        return Left(ServerFailure('Nao ha turno ativo para finalizar.'));
      }

      final endTime = DateTime.now();

      if (!activeShift.isPaused) {
        await locationTrackingDataSource.stopTracking(endedAt: endTime);
      }

      final route = await routeLocalDataSource.getRouteByLocalShiftId(
        activeShift.id,
        includePoints: false,
      );
      final totalDrivenKm = route?.totalDistanceKm ?? 0;

      final pendingShift = await localDataSource.finishShift(
        totalDrivenKm: totalDrivenKm,
      );
      await routeLocalDataSource.markRouteFinished(
        localShiftId: activeShift.id,
        endedAt: pendingShift.endTime,
      );

      final syncedCount = connectionController.isOnline.value
          ? await _syncPendingShiftsInternal()
          : 0;
      final pendingCount =
          (await localDataSource.getPendingFinishedShifts()).length;

      return Right(
        FinishShiftResultEntity(
          synced: pendingCount == 0 && syncedCount > 0,
          pendingSyncCount: pendingCount,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingShifts() async {
    try {
      final syncedCount = await _syncPendingShiftsInternal();
      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  getLocationTrackingStatus() async {
    try {
      final activeShift = await localDataSource.getActiveShift();
      final status = await locationTrackingDataSource.getCurrentStatus(
        localShiftId: activeShift?.id,
        isPaused: activeShift?.isPaused ?? false,
      );
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  @override
  Stream<LocationTrackingStatusEntity> watchLocationTrackingStatus() {
    return locationTrackingDataSource.watchStatus();
  }

  @override
  Future<Either<Failure, ShiftRouteEntity>> getShiftRoute({
    int? localShiftId,
    int? remoteShiftId,
  }) async {
    try {
      if (localShiftId != null) {
        final localRoute = await routeLocalDataSource.getRouteByLocalShiftId(
          localShiftId,
        );
        if (localRoute != null) {
          return Right(localRoute);
        }
      }

      if (remoteShiftId != null) {
        final cachedRoute = await routeLocalDataSource.getRouteByRemoteShiftId(
          remoteShiftId,
        );
        if (cachedRoute != null) {
          return Right(cachedRoute);
        }

        if (!connectionController.isOnline.value) {
          return Left(
            NetworkFailure(
              'Sem internet para carregar a rota sincronizada deste turno.',
            ),
          );
        }

        final remoteRoute = await remoteDataSource.getShiftRoute(remoteShiftId);
        return Right(remoteRoute);
      }

      return Left(
        ValidationFailure('O turno informado nao possui identificador de rota.'),
      );
    } catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    }
  }

  Future<int> _syncPendingShiftsInternal() async {
    final currentSync = _syncPendingShiftsFuture;
    if (currentSync != null) {
      return currentSync;
    }

    final syncFuture = _performPendingShiftSync();
    _syncPendingShiftsFuture = syncFuture;

    try {
      return await syncFuture;
    } finally {
      if (identical(_syncPendingShiftsFuture, syncFuture)) {
        _syncPendingShiftsFuture = null;
      }
    }
  }

  Future<int> _performPendingShiftSync() async {
    if (!connectionController.isOnline.value) {
      return 0;
    }

    final pendingShifts = await localDataSource.getPendingFinishedShifts();
    var syncedCount = 0;

    final orderedShifts = [...pendingShifts]
      ..sort((a, b) => a.endTime.compareTo(b.endTime));

    for (final shift in orderedShifts) {
      final route = await routeLocalDataSource.getRouteByLocalShiftId(
        shift.localId,
      );
      final remoteShiftId = await remoteDataSource.syncFinishedShift(
        shift,
        route,
      );
      await routeLocalDataSource.assignRemoteShiftId(
        localShiftId: shift.localId,
        remoteShiftId: remoteShiftId,
      );
      await localDataSource.removePendingFinishedShift(shift.localId);
      syncedCount++;
    }

    return syncedCount;
  }

  Future<List<ShiftEntity>> _mergePendingShiftHistory(
    List<ShiftEntity> remoteShifts,
  ) async {
    final pendingShifts = await localDataSource.getPendingFinishedShifts();
    final pendingEntities = <ShiftEntity>[];

    for (final entry in pendingShifts.asMap().entries) {
      final route = await routeLocalDataSource.getRouteByLocalShiftId(
        entry.value.localId,
        includePoints: false,
      );
      pendingEntities.add(
        entry.value.toShiftEntity(
          index: entry.key + 1,
          route: route,
        ),
      );
    }

    final merged = <ShiftEntity>[
      ...pendingEntities,
      ...remoteShifts,
    ];

    return merged
        .asMap()
        .entries
        .map(
          (entry) => ShiftEntity(
            index: entry.key + 1,
            localId: entry.value.localId,
            remoteShiftId: entry.value.remoteShiftId,
            date: entry.value.date,
            startTime: entry.value.startTime,
            endTime: entry.value.endTime,
            duration: entry.value.duration,
            drivenKm: entry.value.drivenKm,
            isPendingSync: entry.value.isPendingSync,
            hasRoute: entry.value.hasRoute,
            trackedDistanceKm: entry.value.trackedDistanceKm,
            routePointCount: entry.value.routePointCount,
          ),
        )
        .toList();
  }

  Future<ActiveShiftEntity> _enrichLocalActiveShift(
    ActiveShiftModel localShift,
  ) async {
    final route = await routeLocalDataSource.getRouteByLocalShiftId(
      localShift.id,
      includePoints: false,
    );

    return localShift.copyWith(
      currentDrivenKm: route?.totalDistanceKm ?? 0,
    );
  }
}
