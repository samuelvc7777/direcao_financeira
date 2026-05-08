import 'package:get_storage/get_storage.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/detected_ride_draft_entity.dart';
import '../models/ride_model.dart';

abstract class IRideLocalDataSource {
  Future<RideModel> savePendingRide(DetectedRideDraftEntity ride);
  Future<List<RideModel>> getPendingRides();
  Future<RideModel?> getPendingRideById(int localId);
  Future<void> removePendingRide(int localId);
}

class RideLocalDataSourceImpl implements IRideLocalDataSource {
  RideLocalDataSourceImpl({required this.storage});

  final GetStorage storage;

  static const _pendingRidesKey = 'journey_pending_rides';

  @override
  Future<RideModel> savePendingRide(DetectedRideDraftEntity ride) async {
    try {
      final pendingRides = await _readPendingRideEntries();
      final createdAt = ride.detectedAt?.toLocal() ?? DateTime.now();
      final model = RideModel.fromDetectedRideDraft(
        localId: -createdAt.microsecondsSinceEpoch,
        createdAt: createdAt,
        draft: ride,
      );

      pendingRides.add(
        _PendingRideStorageEntry(model: model, createdAt: createdAt),
      );
      await _writePendingRideEntries(pendingRides);
      return model;
    } catch (e) {
      throw LocalDataSourceException(
        'Erro ao salvar corrida pendente localmente: $e',
      );
    }
  }

  @override
  Future<List<RideModel>> getPendingRides() async {
    try {
      final entries = await _readPendingRideEntries();
      return entries.map((entry) => entry.model).toList();
    } catch (e) {
      throw LocalDataSourceException(
        'Erro ao carregar corridas pendentes locais: $e',
      );
    }
  }

  @override
  Future<RideModel?> getPendingRideById(int localId) async {
    final entries = await _readPendingRideEntries();
    for (final entry in entries) {
      if (entry.model.id == localId) {
        return entry.model;
      }
    }
    return null;
  }

  @override
  Future<void> removePendingRide(int localId) async {
    try {
      final entries = await _readPendingRideEntries();
      final updated = entries
          .where((entry) => entry.model.id != localId)
          .toList();
      await _writePendingRideEntries(updated);
    } catch (e) {
      throw LocalDataSourceException(
        'Erro ao remover corrida pendente local: $e',
      );
    }
  }

  Future<List<_PendingRideStorageEntry>> _readPendingRideEntries() async {
    final raw = storage.read(_pendingRidesKey);
    if (raw is! List) {
      return [];
    }

    final entries = raw.whereType<Map>().map((item) {
      final json = Map<String, dynamic>.from(item);
      final createdAt =
          DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now();
      return _PendingRideStorageEntry(
        model: RideModel.fromJson(json),
        createdAt: createdAt,
      );
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _writePendingRideEntries(entries);
    return entries;
  }

  Future<void> _writePendingRideEntries(
    List<_PendingRideStorageEntry> entries,
  ) async {
    await storage.write(
      _pendingRidesKey,
      entries
          .map((entry) => entry.model.toJson(createdAt: entry.createdAt))
          .toList(),
    );
  }
}

class _PendingRideStorageEntry {
  const _PendingRideStorageEntry({
    required this.model,
    required this.createdAt,
  });

  final RideModel model;
  final DateTime createdAt;
}
