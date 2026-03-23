import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/network/api_error_mapper.dart';
import '../../core/network/api_request_logger.dart';
import '../../domain/entities/detected_ride_draft_entity.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/i_ride_repository.dart';
import '../datasources/i_ride_datasource.dart';

class RideRepositoryImpl implements IRideRepository {
  RideRepositoryImpl(
    this.dataSource, {
    required this.apiErrorMapper,
    required this.apiRequestLogger,
  });

  final IRideDataSource dataSource;
  final ApiErrorMapper apiErrorMapper;
  final ApiRequestLogger apiRequestLogger;

  @override
  Future<Either<Failure, List<RideEntity>>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  }) async {
    try {
      final rides = await dataSource.getRides(
        period: period,
        date: date,
        endDate: endDate,
      );
      return Right(rides);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'RideRepositoryImpl.getRides',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao buscar corridas.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> createDetectedRide(
    DetectedRideDraftEntity ride,
  ) async {
    try {
      await dataSource.createDetectedRide(ride);
      return const Right(unit);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'RideRepositoryImpl.createDetectedRide',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao salvar corrida detectada.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> finishRide({
    required int rideId,
    required String paymentMethod,
  }) async {
    try {
      await dataSource.finishRide(rideId: rideId, paymentMethod: paymentMethod);
      return const Right(unit);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'RideRepositoryImpl.finishRide',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao finalizar corrida.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelRide({
    required int rideId,
    required String cancelReason,
  }) async {
    try {
      await dataSource.cancelRide(rideId: rideId, cancelReason: cancelReason);
      return const Right(unit);
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'RideRepositoryImpl.cancelRide',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao cancelar corrida.'),
      );
    }
  }
}
