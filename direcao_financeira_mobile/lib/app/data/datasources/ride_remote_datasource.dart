import 'package:dio/dio.dart';
import '../models/ride_model.dart';
import 'i_ride_datasource.dart';

class RideRemoteDataSource implements IRideDataSource {
  final Dio dio;

  RideRemoteDataSource({required this.dio});

  @override
  Future<List<RideModel>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  }) async {
    final response = await dio.get(
      '/rides',
      queryParameters: {
        'period': period,
        'date': date,
        'endDate': endDate,
      },
    );

    final data = response.data;
    if (data is! List) return [];

    return data.map((json) => RideModel.fromJson(json)).toList();
  }
}
