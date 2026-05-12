import 'package:dio/dio.dart';

class RideRouteEstimate {
  const RideRouteEstimate({
    required this.distanceKm,
    required this.durationMinutes,
  });

  final double distanceKm;
  final int durationMinutes;
}

class RideRouteEstimator {
  RideRouteEstimator({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {
                'User-Agent': 'DirecaoFinanceira/1.0 ride import',
              },
            ),
          );

  final Dio _dio;

  Future<RideRouteEstimate?> estimate({
    required String originAddress,
    required String destinationAddress,
  }) async {
    final origin = await _geocode(originAddress);
    final destination = await _geocode(destinationAddress);
    if (origin == null || destination == null) {
      return null;
    }

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: const {'overview': 'false'},
    );
    final routes = response.data?['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map) {
      return null;
    }

    final route = Map<String, dynamic>.from(routes.first as Map);
    final distanceMeters = (route['distance'] as num?)?.toDouble();
    final durationSeconds = (route['duration'] as num?)?.toDouble();
    if (distanceMeters == null || durationSeconds == null) {
      return null;
    }

    return RideRouteEstimate(
      distanceKm: distanceMeters / 1000,
      durationMinutes: (durationSeconds / 60).round().clamp(1, 9999),
    );
  }

  Future<_GeoPoint?> _geocode(String address) async {
    for (final query in _geocodeQueries(address)) {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'json',
          'limit': '1',
          'countrycodes': 'br',
          'q': query,
        },
      );
      final data = response.data;
      if (data == null || data.isEmpty || data.first is! Map) {
        continue;
      }

      final first = Map<String, dynamic>.from(data.first as Map);
      final latitude = double.tryParse(first['lat']?.toString() ?? '');
      final longitude = double.tryParse(first['lon']?.toString() ?? '');
      if (latitude != null && longitude != null) {
        return _GeoPoint(latitude: latitude, longitude: longitude);
      }
    }

    return null;
  }

  List<String> _geocodeQueries(String address) {
    final cleaned = address.replaceAll(RegExp(r'\s+'), ' ').trim();
    final withoutParentheses = cleaned
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final beforeDash = cleaned.split(' - ').first.trim();
    final queries = <String>[
      cleaned,
      '$cleaned, Brasil',
      withoutParentheses,
      '$withoutParentheses, Brasil',
      beforeDash,
      '$beforeDash, Sao Joao del Rei, MG, Brasil',
    ];

    return queries.where((query) => query.isNotEmpty).toSet().toList();
  }
}

class _GeoPoint {
  const _GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
