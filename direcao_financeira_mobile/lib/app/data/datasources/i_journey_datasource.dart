import '../models/active_shift_model.dart';
import '../models/journey_statistics_model.dart';
import '../models/pending_finished_shift_model.dart';
import '../models/shift_route_model.dart';
import '../models/shift_model.dart';

abstract class IJourneyDataSource {
  Future<ActiveShiftModel?> getActiveShift();
  Future<JourneyStatisticsModel> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  });
  Future<List<ShiftModel>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
  });
  Future<int> syncFinishedShift(
    PendingFinishedShiftModel shift,
    ShiftRouteModel? trackedRoute,
  );
  Future<ShiftRouteModel> getShiftRoute(int shiftId);
}
