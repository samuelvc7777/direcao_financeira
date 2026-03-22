import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/i_ride_repository.dart';
import '../datasources/i_ride_datasource.dart';

class RideRepositoryImpl implements IRideRepository {
  final IRideDataSource dataSource;

  RideRepositoryImpl(this.dataSource);

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
      if (e is DioException) {
        return Left(ServerFailure(e.message ?? 'Erro ao buscar corridas'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
