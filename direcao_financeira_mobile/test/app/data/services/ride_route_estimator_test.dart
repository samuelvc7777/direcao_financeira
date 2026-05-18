import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:direcao_financeira_mobile/app/data/services/ride_route_estimator.dart';

void main() {
  test(
    'usa Google Directions quando geocoding gratuito nao encontra endereco',
    () async {
      final calledHosts = <String>[];
      final dio = _fakeDio((options, handler) {
        calledHosts.add(options.uri.host);

        if (options.uri.host == 'nominatim.openstreetmap.org') {
          handler.resolve(Response(requestOptions: options, data: []));
          return;
        }

        if (options.uri.host == 'routes.googleapis.com') {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'routes': [
                  {'distanceMeters': 7420, 'duration': '960s'},
                ],
              },
            ),
          );
          return;
        }

        handler.reject(
          DioException(requestOptions: options, message: 'endpoint inesperado'),
        );
      });

      final estimator = RideRouteEstimator(dio: dio, googleMapsApiKey: 'gmaps');

      final estimate = await estimator.estimate(
        originAddress: 'R. Teste, 10',
        destinationAddress: 'Av. Destino, 20',
      );

      expect(calledHosts, contains('nominatim.openstreetmap.org'));
      expect(calledHosts, contains('routes.googleapis.com'));
      expect(estimate?.distanceKm, 7.42);
      expect(estimate?.durationMinutes, 16);
    },
  );

  test('prefere OpenRouteService antes de Google para poupar Maps', () async {
    final calledHosts = <String>[];
    final dio = _fakeDio((options, handler) {
      calledHosts.add(options.uri.host);

      if (options.uri.host == 'nominatim.openstreetmap.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: [
              {'lat': '-21.1350', 'lon': '-44.2610'},
            ],
          ),
        );
        return;
      }

      if (options.uri.host == 'api.openrouteservice.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'routes': [
                {
                  'summary': {'distance': 3100, 'duration': 420},
                },
              ],
            },
          ),
        );
        return;
      }

      handler.reject(
        DioException(requestOptions: options, message: 'endpoint inesperado'),
      );
    });

    final estimator = RideRouteEstimator(
      dio: dio,
      googleMapsApiKey: 'gmaps',
      openRouteServiceApiKey: 'ors-key',
    );

    final estimate = await estimator.estimate(
      originAddress: 'R. Teste, 10',
      destinationAddress: 'Av. Destino, 20',
    );

    expect(calledHosts, contains('nominatim.openstreetmap.org'));
    expect(calledHosts, contains('api.openrouteservice.org'));
    expect(calledHosts, isNot(contains('routes.googleapis.com')));
    expect(estimate?.distanceKm, 3.1);
    expect(estimate?.durationMinutes, 7);
  });

  test('usa OpenRouteService quando a chave esta configurada', () async {
    final dio = _fakeDio((options, handler) {
      if (options.uri.host == 'nominatim.openstreetmap.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: [
              {'lat': '-21.1350', 'lon': '-44.2610'},
            ],
          ),
        );
        return;
      }

      if (options.uri.host == 'api.openrouteservice.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'routes': [
                {
                  'summary': {'distance': 12340, 'duration': 1500},
                },
              ],
            },
          ),
        );
        return;
      }

      handler.reject(
        DioException(requestOptions: options, message: 'endpoint inesperado'),
      );
    });

    final estimator = RideRouteEstimator(
      dio: dio,
      openRouteServiceApiKey: 'ors-key',
    );

    final estimate = await estimator.estimate(
      originAddress: 'R. Teste, 10',
      destinationAddress: 'Av. Destino, 20',
    );

    expect(estimate?.distanceKm, 12.34);
    expect(estimate?.durationMinutes, 25);
  });

  test('cai para OSRM quando OpenRouteService falha', () async {
    final calledHosts = <String>[];
    final dio = _fakeDio((options, handler) {
      calledHosts.add(options.uri.host);

      if (options.uri.host == 'nominatim.openstreetmap.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: [
              {'lat': '-21.1350', 'lon': '-44.2610'},
            ],
          ),
        );
        return;
      }

      if (options.uri.host == 'api.openrouteservice.org') {
        handler.reject(
          DioException(requestOptions: options, message: 'ors indisponivel'),
        );
        return;
      }

      if (options.uri.host == 'router.project-osrm.org') {
        handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'routes': [
                {'distance': 5800, 'duration': 720},
              ],
            },
          ),
        );
        return;
      }

      handler.reject(
        DioException(requestOptions: options, message: 'endpoint inesperado'),
      );
    });

    final estimator = RideRouteEstimator(
      dio: dio,
      openRouteServiceApiKey: 'ors-key',
    );

    final estimate = await estimator.estimate(
      originAddress: 'Rua Origem, 10',
      destinationAddress: 'Rua Destino, 20',
    );

    expect(calledHosts, contains('api.openrouteservice.org'));
    expect(calledHosts, contains('router.project-osrm.org'));
    expect(estimate?.distanceKm, 5.8);
    expect(estimate?.durationMinutes, 12);
  });
}

Dio _fakeDio(
  void Function(RequestOptions options, RequestInterceptorHandler handler)
  onRequest,
) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}
