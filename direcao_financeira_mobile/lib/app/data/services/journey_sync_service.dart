import '../../core/network/realtime_client.dart';
import '../../domain/entities/active_shift_entity.dart';
import '../../domain/entities/shift_entity.dart';
import '../datasources/i_journey_datasource.dart';
import '../datasources/journey_local_datasource.dart';
import '../datasources/journey_route_local_datasource.dart';
import '../models/active_shift_model.dart';

class JourneySyncService {
  JourneySyncService({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.routeLocalDataSource,
    required this.realtimeClient,
  });

  final IJourneyDataSource remoteDataSource;
  final IJourneyLocalDataSource localDataSource;
  final IJourneyRouteLocalDataSource routeLocalDataSource;
  final RealtimeClient realtimeClient;

  Future<int>? _syncPendingShiftsFuture;

  Future<int> syncPendingShiftsIfOnline() async {
    if (!realtimeClient.isOnline.value) {
      return 0;
    }

    return syncPendingShifts();
  }

  Future<int> syncPendingShifts() async {
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

  Future<List<ShiftEntity>> mergePendingShiftHistory(
    List<ShiftEntity> remoteShifts,
  ) async {
    final pendingEntities = await getPendingShiftHistoryEntities();

    final merged = <ShiftEntity>[...pendingEntities, ...remoteShifts];

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

  Future<List<ShiftEntity>> getPendingShiftHistoryEntities() async {
    final pendingShifts = await localDataSource.getPendingFinishedShifts();
    final pendingEntities = <ShiftEntity>[];

    for (final entry in pendingShifts.asMap().entries) {
      final route = await routeLocalDataSource.getRouteByLocalShiftId(
        entry.value.localId,
        includePoints: false,
      );
      pendingEntities.add(
        entry.value.toShiftEntity(index: entry.key + 1, route: route),
      );
    }

    return pendingEntities;
  }

  Future<ActiveShiftEntity> enrichLocalActiveShift(
    ActiveShiftModel localShift,
  ) async {
    final route = await routeLocalDataSource.getRouteByLocalShiftId(
      localShift.id,
      includePoints: false,
    );

    return localShift.copyWith(currentDrivenKm: route?.totalDistanceKm ?? 0);
  }

  Future<int> _performPendingShiftSync() async {
    if (!realtimeClient.isOnline.value) {
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
}
