import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/network/api_error_mapper.dart';
import '../../core/network/api_request_logger.dart';
import '../../core/network/realtime_client.dart';
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
import '../services/journey_shift_lifecycle_service.dart';
import '../services/journey_sync_service.dart';

class JourneyRepositoryImpl implements IJourneyRepository {
  JourneyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.routeLocalDataSource,
    required this.locationTrackingDataSource,
    required this.realtimeClient,
    required this.apiErrorMapper,
    required this.apiRequestLogger,
  }) : syncService = JourneySyncService(
         remoteDataSource: remoteDataSource,
         localDataSource: localDataSource,
         routeLocalDataSource: routeLocalDataSource,
         realtimeClient: realtimeClient,
       ),
       shiftLifecycleService = JourneyShiftLifecycleService(
         localDataSource: localDataSource,
         routeLocalDataSource: routeLocalDataSource,
         locationTrackingDataSource: locationTrackingDataSource,
       );

  final IJourneyDataSource remoteDataSource;
  final IJourneyLocalDataSource localDataSource;
  final IJourneyRouteLocalDataSource routeLocalDataSource;
  final ILocationTrackingDataSource locationTrackingDataSource;
  final RealtimeClient realtimeClient;
  final ApiErrorMapper apiErrorMapper;
  final ApiRequestLogger apiRequestLogger;
  final JourneySyncService syncService;
  final JourneyShiftLifecycleService shiftLifecycleService;

  @override
  Future<Either<Failure, ActiveShiftEntity?>> getActiveShift() async {
    try {
      final localShift = await localDataSource.getActiveShift();
      if (localShift != null) {
        return Right(await syncService.enrichLocalActiveShift(localShift));
      }

      await syncService.syncPendingShiftsIfOnline();

      final activeShift = await remoteDataSource.getActiveShift();
      if (activeShift != null) {
        await localDataSource.saveActiveShift(activeShift);
      }

      return Right(activeShift);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.getActiveShift',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar o turno ativo.',
        ),
      );
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
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.getDailyStatistics',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar as metricas da jornada.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ShiftEntity>>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async {
    try {
      await syncService.syncPendingShiftsIfOnline();

      final shifts = await remoteDataSource.getShiftHistory(
        filter: filter,
        date: date,
        endDate: endDate,
      );
      return Right(await syncService.mergePendingShiftHistory(shifts));
    } catch (e) {
      final pendingShifts = await localDataSource.getPendingFinishedShifts();
      if (pendingShifts.isNotEmpty) {
        return Right(await syncService.mergePendingShiftHistory(const []));
      }

      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.getShiftHistory',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar o historico da jornada.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> startShift() async {
    try {
      await shiftLifecycleService.startShift();
      return const Right(null);
    } on ValidationFailure catch (e) {
      return Left(e);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.startShift',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao iniciar o turno.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> pauseShift() async {
    try {
      await shiftLifecycleService.pauseShift();
      return const Right(null);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.pauseShift',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao pausar o turno.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resumeShift() async {
    try {
      await shiftLifecycleService.resumeShift();
      return const Right(null);
    } on ValidationFailure catch (e) {
      return Left(e);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.resumeShift',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao retomar o turno.'),
      );
    }
  }

  @override
  Future<Either<Failure, FinishShiftResultEntity>> finishShift() async {
    try {
      await shiftLifecycleService.finishShift();

      final syncedCount = realtimeClient.isOnline.value
          ? await syncService.syncPendingShifts()
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
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.finishShift',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao finalizar o turno.'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> syncPendingShifts() async {
    try {
      return Right(await syncService.syncPendingShifts());
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.syncPendingShifts',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao sincronizar turnos pendentes.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  ensureReadyForShiftStart() async {
    try {
      final status = await locationTrackingDataSource
          .ensureReadyForShiftStart();
      return Right(status);
    } on ValidationFailure catch (e) {
      return Left(e);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.ensureReadyForShiftStart',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao validar a localizacao para iniciar o turno.',
        ),
      );
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
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.getLocationTrackingStatus',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar o status de rastreamento.',
        ),
      );
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

        if (!realtimeClient.isOnline.value) {
          return Left(
            NetworkFailure(
              'Sem internet para carregar a rota sincronizada deste turno.',
            ),
          );
        }

        return Right(await remoteDataSource.getShiftRoute(remoteShiftId));
      }

      return Left(
        ValidationFailure(
          'O turno informado nao possui identificador de rota.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'JourneyRepositoryImpl.getShiftRoute',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar a rota do turno.',
        ),
      );
    }
  }
}
