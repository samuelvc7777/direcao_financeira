import 'package:dio/dio.dart';

import '../../../datasources/i_ride_datasource.dart';
import '../../../../domain/entities/detected_ride_draft_entity.dart';
import '../../../models/ride_model.dart';

class NestRideRemoteDataSource implements IRideDataSource {
  NestRideRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<RideModel>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  }) async {
    final response = await dio.get(
      '/rides',
      queryParameters: {'period': period, 'date': date, 'endDate': endDate},
    );

    final data = response.data;
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((json) => RideModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> createDetectedRide(DetectedRideDraftEntity ride) {
    throw UnsupportedError(
      'Criacao de corrida pendente via overlay esta disponivel apenas no provider Supabase.',
    );
  }

  @override
  Future<void> finishRide({
    required int rideId,
    required String paymentMethod,
  }) {
    throw UnsupportedError(
      'Finalizacao de corrida via detalhes esta disponivel apenas no provider Supabase.',
    );
  }

  @override
  Future<void> cancelRide({required int rideId, required String cancelReason}) {
    throw UnsupportedError(
      'Cancelamento de corrida via detalhes esta disponivel apenas no provider Supabase.',
    );
  }
}
