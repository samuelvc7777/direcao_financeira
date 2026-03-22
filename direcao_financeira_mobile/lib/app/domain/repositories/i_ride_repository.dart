import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/ride_entity.dart';

abstract class IRideRepository {
  Future<Either<Failure, List<RideEntity>>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  });
}
