import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../datasources/i_ride_datasource.dart';
import '../../../../domain/entities/detected_ride_draft_entity.dart';
import '../../../models/ride_model.dart';
import '../shared/supabase_table_names.dart';
import '../shared/supabase_time_filter.dart';
import '../shared/supabase_user_scope.dart';

class SupabaseRideRemoteDataSource implements IRideDataSource {
  SupabaseRideRemoteDataSource({required this.client})
    : userScope = SupabaseUserScope(client: client);

  final SupabaseClient client;
  final SupabaseUserScope userScope;

  @override
  Future<List<RideModel>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  }) async {
    final userId = await userScope.getCurrentUserId();
    final range = SupabaseTimeFilter.resolve(
      filter: period,
      date: date,
      endDate: endDate,
    );

    final rows = await client
        .from(SupabaseTableNames.rides)
        .select()
        .eq('userId', userId)
        .gte('createdAt', range.start.toUtc().toIso8601String())
        .lt('createdAt', range.endExclusive.toUtc().toIso8601String())
        .order('createdAt', ascending: false);

    return (rows as List)
        .map((row) => RideModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<void> createDetectedRide(DetectedRideDraftEntity ride) async {
    final userId = await userScope.getCurrentUserId();
    final now = DateTime.now().toUtc().toIso8601String();

    await client.from(SupabaseTableNames.rides).insert({
      'userId': userId,
      'status': 'PENDING',
      'platformName': ride.platformName,
      'paymentMethod': ride.paymentMethod,
      'grossValueCents': ride.grossValueCents,
      'netProfitCents': ride.netProfitCents,
      'totalKm': ride.totalKm,
      'totalTime': ride.totalTimeSeconds,
      'gainPerKmCents': ride.gainPerKmCents,
      'gainPerHourCents': ride.gainPerHourCents,
      'passengerName': ride.passengerName,
      'originAddress': ride.originAddress,
      'destinationAddress': ride.destinationAddress,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  @override
  Future<void> finishRide({
    required int rideId,
    required String paymentMethod,
  }) async {
    final userId = await userScope.getCurrentUserId();
    final now = DateTime.now().toUtc().toIso8601String();

    await client
        .from(SupabaseTableNames.rides)
        .update({
          'status': 'FINISHED',
          'paymentMethod': paymentMethod,
          'updatedAt': now,
        })
        .eq('id', rideId)
        .eq('userId', userId);
  }

  @override
  Future<void> cancelRide({
    required int rideId,
    required String cancelReason,
  }) async {
    final userId = await userScope.getCurrentUserId();
    final now = DateTime.now().toUtc().toIso8601String();

    await client
        .from(SupabaseTableNames.rides)
        .update({
          'status': 'CANCELED',
          'cancelReason': cancelReason,
          'updatedAt': now,
        })
        .eq('id', rideId)
        .eq('userId', userId);
  }
}
