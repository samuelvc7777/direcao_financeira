import 'package:dio/dio.dart';

class RideRouteEstimate {
  const RideRouteEstimate({
    required this.distanceKm,
    required this.durationMinutes,
    required this.provider,
  });

  final double distanceKm;
  final int durationMinutes;
  final String provider;
}

class RideRouteEstimator {
  RideRouteEstimator({
    Dio? dio,
    String? googleMapsApiKey,
    String? openRouteServiceApiKey,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 5),
               headers: const {
                 'User-Agent': 'DirecaoFinanceira/1.0 ride import',
               },
             ),
           ),
       _googleMapsApiKey = googleMapsApiKey?.trim() ?? '',
       _openRouteServiceApiKey = openRouteServiceApiKey?.trim() ?? '';

  final Dio _dio;
  final String _googleMapsApiKey;
  final String _openRouteServiceApiKey;

  Future<RideRouteEstimate?> estimate({
    required String originAddress,
    required String destinationAddress,
  }) async {
    _GeoPoint? origin;
    _GeoPoint? destination;
    try {
      final points = await Future.wait([
        _geocode(originAddress),
        _geocode(destinationAddress),
      ]);
      origin = points[0];
      destination = points[1];
    } catch (_) {
      origin = null;
      destination = null;
    }
    if (origin == null || destination == null) {
      return _estimateWithGoogleDirections(
        originAddress: originAddress,
        destinationAddress: destinationAddress,
      );
    }

    final openRouteServiceEstimate = await _estimateWithOpenRouteService(
      origin: origin,
      destination: destination,
    );
    if (openRouteServiceEstimate != null) {
      return openRouteServiceEstimate;
    }

    final osrmEstimate = await _estimateWithOsrm(
      origin: origin,
      destination: destination,
    );
    if (osrmEstimate != null) {
      return osrmEstimate;
    }

    return _estimateWithGoogleDirections(
      originAddress: originAddress,
      destinationAddress: destinationAddress,
    );
  }

  Future<RideRouteEstimate?> _estimateWithGoogleDirections({
    required String originAddress,
    required String destinationAddress,
  }) async {
    if (_googleMapsApiKey.isEmpty) {
      return null;
    }

    final originQueries = _googleRouteQueries(originAddress);
    final destinationQueries = _googleRouteQueries(destinationAddress);

    for (final origin in originQueries) {
      for (final destination in destinationQueries) {
        Response<Map<String, dynamic>> response;
        try {
          response = await _dio.post<Map<String, dynamic>>(
            'https://routes.googleapis.com/directions/v2:computeRoutes',
            options: Options(
              headers: {
                'X-Goog-Api-Key': _googleMapsApiKey,
                'X-Goog-FieldMask': 'routes.distanceMeters,routes.duration',
              },
            ),
            data: {
              'origin': {'address': origin},
              'destination': {'address': destination},
              'travelMode': 'DRIVE',
              'languageCode': 'pt-BR',
              'regionCode': 'BR',
            },
          );
        } on DioException {
          continue;
        } catch (_) {
          continue;
        }

        final routes = response.data?['routes'];
        if (routes is! List || routes.isEmpty || routes.first is! Map) {
          continue;
        }

        final route = Map<String, dynamic>.from(routes.first as Map);
        final estimate = _estimateFromMetersAndSeconds(
          distanceMeters: (route['distanceMeters'] as num?)?.toDouble(),
          durationSeconds: _googleDurationSeconds(route['duration']),
          provider: 'Google Maps',
        );
        if (estimate != null) {
          return estimate;
        }
      }
    }

    return null;
  }

  Future<RideRouteEstimate?> _estimateWithOpenRouteService({
    required _GeoPoint origin,
    required _GeoPoint destination,
  }) async {
    if (_openRouteServiceApiKey.isEmpty) {
      return null;
    }

    Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        'https://api.openrouteservice.org/v2/directions/driving-car',
        options: Options(headers: {'Authorization': _openRouteServiceApiKey}),
        data: {
          'coordinates': [
            [origin.longitude, origin.latitude],
            [destination.longitude, destination.latitude],
          ],
        },
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
    final routes = response.data?['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map) {
      return null;
    }

    final route = Map<String, dynamic>.from(routes.first as Map);
    final summary = route['summary'];
    if (summary is! Map) {
      return null;
    }

    return _estimateFromMetersAndSeconds(
      distanceMeters: (summary['distance'] as num?)?.toDouble(),
      durationSeconds: (summary['duration'] as num?)?.toDouble(),
      provider: 'OpenRouteService',
    );
  }

  Future<RideRouteEstimate?> _estimateWithOsrm({
    required _GeoPoint origin,
    required _GeoPoint destination,
  }) async {
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

    return _estimateFromMetersAndSeconds(
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      provider: 'OSRM gratuito',
    );
  }

  Future<_GeoPoint?> _geocode(String address) async {
    for (final query in _geocodeQueries(address)) {
      Response<List<dynamic>> response;
      try {
        response = await _dio.get<List<dynamic>>(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'format': 'json',
            'limit': '1',
            'addressdetails': '1',
            'countrycodes': 'br',
            'accept-language': 'pt-BR,pt;q=0.9',
            'q': query,
          },
        );
      } on DioException {
        continue;
      } catch (_) {
        continue;
      }

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

  RideRouteEstimate? _estimateFromMetersAndSeconds({
    required double? distanceMeters,
    required double? durationSeconds,
    required String provider,
  }) {
    if (distanceMeters == null || durationSeconds == null) {
      return null;
    }

    return RideRouteEstimate(
      distanceKm: distanceMeters / 1000,
      durationMinutes: (durationSeconds / 60).round().clamp(1, 9999),
      provider: provider,
    );
  }

  List<String> _geocodeQueries(String address) {
    final cleaned = _normalizeAddress(address);
    final streetCandidate = _extractStreetCandidate(cleaned);
    final establishmentCandidate = cleaned.split(RegExp(r'\s+-\s+')).first;
    final withoutParentheses = cleaned
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final withoutReferences = withoutParentheses
        .replaceAll(
          RegExp(
            r'\b(proximo|em frente|ao lado|fundos|entrada)\b.*',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final queries = <String>[
      streetCandidate,
      '$streetCandidate, Sao Joao del Rei, MG, Brasil',
      establishmentCandidate,
      '$establishmentCandidate, Sao Joao del Rei, MG, Brasil',
      withoutReferences,
      '$withoutReferences, Sao Joao del Rei, MG, Brasil',
    ];

    return queries.where((query) => query.isNotEmpty).toSet().toList();
  }

  String _googleAddressQuery(String address) {
    final normalized = _normalizeAddress(address);
    if (normalized.toLowerCase().contains('brasil')) {
      return normalized;
    }

    return '$normalized, Sao Joao del Rei, MG, Brasil';
  }

  List<String> _googleRouteQueries(String address) {
    final normalized = _normalizeAddress(address);
    final streetCandidate = _extractStreetCandidate(normalized);
    final establishmentCandidate = normalized
        .split(RegExp(r'\s+-\s+'))
        .first
        .trim();

    return <String>[
      _googleAddressQuery(normalized),
      _googleAddressQuery(streetCandidate),
      _googleAddressQuery(establishmentCandidate),
    ].where((query) => query.isNotEmpty).toSet().toList();
  }

  String _extractStreetCandidate(String address) {
    final parts = address
        .split(RegExp(r'\s+-\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final streetIndex = parts.indexWhere(
      (part) => RegExp(
        r'^(Rua|Avenida|Av\.|R\.|Travessa|Praca)\b',
        caseSensitive: false,
      ).hasMatch(part),
    );
    if (streetIndex < 0) {
      return address;
    }

    return parts.skip(streetIndex).join(', ');
  }

  double? _googleDurationSeconds(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    final normalized = value.endsWith('s')
        ? value.substring(0, value.length - 1)
        : value;
    return double.tryParse(normalized);
  }

  String _normalizeAddress(String address) {
    return address
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\bAv\.\s*', caseSensitive: false), 'Avenida ')
        .replaceAll(RegExp(r'\bR\.\s*', caseSensitive: false), 'Rua ')
        .replaceAll(RegExp(r'\bPca\.\s*', caseSensitive: false), 'Praca ')
        .replaceAll(RegExp(r'\bPraca\b', caseSensitive: false), 'Praca')
        .replaceAll(RegExp(r'\bSao\b', caseSensitive: false), 'Sao')
        .trim();
  }
}

class _GeoPoint {
  const _GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
