import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/detected_ride_draft_entity.dart';
import '../repositories/i_ride_repository.dart';

class CreateDetectedRideUseCase {
  CreateDetectedRideUseCase(this.repository);

  final IRideRepository repository;

  Future<Either<Failure, Unit>> call(DetectedRideDraftEntity ride) {
    return repository.createDetectedRide(ride);
  }
}

class CreateFinishedRideUseCase {
  CreateFinishedRideUseCase(this.repository);

  final IRideRepository repository;

  Future<Either<Failure, Unit>> call(DetectedRideDraftEntity ride) {
    return repository.createFinishedRide(ride);
  }
}
