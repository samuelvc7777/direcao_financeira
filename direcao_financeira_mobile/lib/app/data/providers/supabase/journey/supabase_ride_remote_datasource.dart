import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../datasources/i_ride_datasource.dart';
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
}
