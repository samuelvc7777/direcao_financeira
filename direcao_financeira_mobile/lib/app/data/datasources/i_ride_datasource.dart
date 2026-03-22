import '../../domain/entities/detected_ride_draft_entity.dart';
import '../models/ride_model.dart';

abstract class IRideDataSource {
  Future<List<RideModel>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  });

  Future<void> createDetectedRide(DetectedRideDraftEntity ride);
}
