import 'dart:convert';

import 'package:dio/dio.dart';
import '../models/active_shift_model.dart';
import '../models/journey_statistics_model.dart';
import '../models/pending_finished_shift_model.dart';
import '../models/shift_route_model.dart';
import '../models/shift_model.dart';
import 'i_journey_datasource.dart';

class JourneyRemoteDataSource implements IJourneyDataSource {
  final Dio dio;

  JourneyRemoteDataSource({required this.dio});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 0) return '00:00:00';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimeOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  String _formatDateOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return '--/--/----';
    }
  }

  @override
  Future<ActiveShiftModel?> getActiveShift() async {
    final response = await dio.get('/journey/active');
    final rawData = response.data;

    if (rawData == null) {
      return null;
    }

    if (rawData is String) {
      final normalized = rawData.trim();

      if (normalized.isEmpty || normalized == 'null') {
        return null;
      }

      final decoded = jsonDecode(normalized);
      if (decoded is Map<String, dynamic>) {
        return ActiveShiftModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return ActiveShiftModel.fromJson(Map<String, dynamic>.from(decoded));
      }

      throw const FormatException(
        'Resposta invalida ao carregar turno ativo.',
      );
    }

    if (rawData is Map<String, dynamic>) {
      return ActiveShiftModel.fromJson(rawData);
    }

    if (rawData is Map) {
      return ActiveShiftModel.fromJson(Map<String, dynamic>.from(rawData));
    }

    throw const FormatException(
      'Resposta invalida ao carregar turno ativo.',
    );
  }

  @override
  Future<JourneyStatisticsModel> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async {
    final response = await dio.get(
      '/journey/stats',
      queryParameters: {
        'filter': filter,
        'date': date,
        'endDate': endDate,
      },
    );
    final data = response.data;

    return JourneyStatisticsModel(
      totalShifts: data['totalShifts'] ?? 0,
      totalTime: _formatDuration(data['totalTime'] ?? 0),
      averageTime: _formatDuration(data['avgShiftTime'] ?? 0),
      idleTime: _formatDuration(data['totalIdleTime'] ?? 0),
      drivenKm: '${(data['totalKm'] ?? 0.0).toStringAsFixed(1)} km',
      averageKmh: '${(data['avgKmh'] ?? 0.0).toStringAsFixed(1)} km/h',
      rideStats: data['rideStats'] != null
          ? RideStatisticsModel.fromJson(data['rideStats'])
          : const RideStatisticsModel(
              totalRides: 0,
              grossEarningsCents: 0,
              netEarningsCents: 0,
              totalCostsCents: 0,
              ridesTotalKm: 0.0,
              ridesTotalTime: 0,
            ),
    );
  }

  @override
  Future<List<ShiftModel>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async {
    final response = await dio.get(
      '/journey/history',
      queryParameters: {
        'filter': filter,
        'date': date,
        'endDate': endDate,
      },
    );
    final data = response.data;

    if (data is! List) return [];

    final List<ShiftModel> shifts = [];
    int index = 1;

    for (var item in data) {
      final startTimeStr = item['startTime'] as String?;
      final endTimeStr = item['endTime'] as String?;
      final totalTime = item['totalTime'] as int? ?? 0;
      final totalDrivenKm = item['totalDrivenKm'] as num? ?? 0.0;
      final trackedDistanceKm =
          (item['trackedDistanceKm'] as num?)?.toDouble() ?? 0.0;
      final hasRoute = item['hasRoute'] == true;

      shifts.add(
        ShiftModel(
          index: index++,
          remoteShiftId: item['remoteShiftId'] as int? ?? item['id'] as int?,
          date: startTimeStr != null
              ? _formatDateOnly(startTimeStr)
              : '--/--/----',
          startTime: startTimeStr != null
              ? _formatTimeOnly(startTimeStr)
              : '--:--',
          endTime: endTimeStr != null ? _formatTimeOnly(endTimeStr) : '--:--',
          duration: _formatDuration(totalTime),
          drivenKm: hasRoute
              ? trackedDistanceKm.toStringAsFixed(1)
              : totalDrivenKm > 0
              ? totalDrivenKm.toStringAsFixed(1)
              : null,
          hasRoute: hasRoute,
          trackedDistanceKm: trackedDistanceKm,
          routePointCount: item['routePointCount'] as int? ?? 0,
        ),
      );
    }

    return shifts;
  }

  @override
  Future<int> syncFinishedShift(
    PendingFinishedShiftModel shift,
    ShiftRouteModel? trackedRoute,
  ) async {
    final payload = {
      'startTime': shift.startTime.toUtc().toIso8601String(),
      'endTime': shift.endTime.toUtc().toIso8601String(),
      'idleTime': shift.idleTimeSeconds,
      'totalDrivenKm': shift.totalDrivenKm,
      if (shift.remoteShiftId != null)
        'remoteShiftId': shift.remoteShiftId,
      if (trackedRoute != null)
        'trackedRoute': {
          'points': trackedRoute.points
              .map((point) => {
                    'latitude': point.latitude,
                    'longitude': point.longitude,
                    'accuracyMeters': point.accuracyMeters,
                    'recordedAt':
                        point.recordedAt.toUtc().toIso8601String(),
                  })
              .toList(),
          'totalDistanceMeters': trackedRoute.totalDistanceMeters,
          'startedAt': trackedRoute.startedAt.toUtc().toIso8601String(),
          'endedAt': trackedRoute.endedAt.toUtc().toIso8601String(),
        },
    };

    final response = await dio.post(
      '/journey/sync-finished',
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['id'] as int;
    }

    if (data is Map) {
      return data['id'] as int;
    }

    throw const FormatException('Resposta invalida ao sincronizar turno.');
  }

  @override
  Future<ShiftRouteModel> getShiftRoute(int shiftId) async {
    final response = await dio.get('/journey/$shiftId/route');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ShiftRouteModel.fromRemoteJson(data);
    }

    if (data is Map) {
      return ShiftRouteModel.fromRemoteJson(Map<String, dynamic>.from(data));
    }

    throw const FormatException('Resposta invalida ao carregar rota do turno.');
  }
}
