import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/i_ride_repository.dart';

class GetRidesUseCase {
  final IRideRepository repository;

  GetRidesUseCase(this.repository);

  Future<Either<Failure, List<RideEntity>>> call({
    String period = 'day',
    String? date,
    String? endDate,
  }) async {
    return await repository.getRides(
      period: period,
      date: date,
      endDate: endDate,
    );
  }
}
