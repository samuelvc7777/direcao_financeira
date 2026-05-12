import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/data/services/ride_route_estimator.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/detected_ride_draft_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/paged_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_import_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_ride_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/services/movesj_history_screenshot_parser.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/create_detected_ride_usecase.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/import_ride_photo_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/widgets/ride_details_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'salva corrida importada no horario lido do print e fecha a tela',
    (tester) async {
      final repository = _FakeRideRepository();
      final controller = ImportRidePhotoController(
        createFinishedRideUseCase: CreateFinishedRideUseCase(repository),
        parser: const MoveSjHistoryScreenshotParser(),
        routeEstimator: _FakeRideRouteEstimator(),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SizedBox.shrink()),
            GetPage(name: '/import', page: () => const SizedBox.shrink()),
          ],
        ),
      );
      Get.toNamed('/import');
      await tester.pumpAndSettle();

      controller.parsedDateTime.value = DateTime(2026, 5, 12, 19);
      controller.amountController.text = 'R\$ 17,51';
      controller.passengerController.text = 'Carolina';
      controller.originController.text = 'Rua A, 123';
      controller.destinationController.text = 'Rua B, 456';
      controller.distanceKmController.text = '8,5';
      controller.durationMinutesController.text = '19';
      controller.selectedPaymentOption.value = RidePaymentOption.pix;

      await controller.saveRide();
      await tester.pumpAndSettle();

      expect(
        repository.lastFinishedRide?.detectedAt,
        DateTime(2026, 5, 12, 19),
      );
      expect(repository.lastFinishedRide?.paymentMethod, 'PIX');
      expect(repository.lastFinishedRide?.totalKm, 9.5);
      expect(repository.lastFinishedRide?.totalTimeSeconds, 24 * 60);
      expect(repository.lastFinishedRide?.gainPerKmCents, 184);
      expect(repository.lastFinishedRide?.gainPerHourCents, 4378);
      expect(Get.currentRoute, '/');

      controller.onClose();
    },
  );
}

class _FakeRideRouteEstimator extends RideRouteEstimator {
  @override
  Future<RideRouteEstimate?> estimate({
    required String originAddress,
    required String destinationAddress,
  }) async => null;
}

class _FakeRideRepository implements IRideRepository {
  DetectedRideDraftEntity? lastFinishedRide;

  @override
  Future<Either<Failure, Unit>> createDetectedRide(
    DetectedRideDraftEntity ride,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> createFinishedRide(
    DetectedRideDraftEntity ride,
  ) async {
    lastFinishedRide = ride;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> cancelRide({
    required int rideId,
    required String cancelReason,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> finishRide({
    required int rideId,
    required String paymentMethod,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, PagedResultEntity<RideImportEntity>>>
  getImportableRides({
    String period = 'month',
    String? date,
    String? endDate,
    String? status = 'FINISHED',
    int offset = 0,
    int limit = 100,
  }) async => Right(
    PagedResultEntity(
      items: const [],
      totalCount: 0,
      offset: offset,
      limit: limit,
    ),
  );

  @override
  Future<Either<Failure, PagedResultEntity<RideEntity>>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
    String? status,
    int offset = 0,
    int limit = 20,
  }) async => Right(
    PagedResultEntity(
      items: const [],
      totalCount: 0,
      offset: offset,
      limit: limit,
    ),
  );
}
