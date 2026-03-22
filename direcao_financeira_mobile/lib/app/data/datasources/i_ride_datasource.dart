import '../models/ride_model.dart';

abstract class IRideDataSource {
  Future<List<RideModel>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  });
}
