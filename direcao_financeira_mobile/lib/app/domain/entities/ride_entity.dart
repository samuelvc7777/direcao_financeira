class RideEntity {
  final int id;
  final String status;
  final String appName;
  final int grossValueCents;
  final String date;
  final String time;
  final String origin;
  final String destination;
  final String passenger;
  final int durationMinutes;
  final int gainPerKmCents;
  final int gainPerHourCents;

  const RideEntity({
    required this.id,
    required this.status,
    required this.appName,
    required this.grossValueCents,
    required this.date,
    required this.time,
    required this.origin,
    required this.destination,
    required this.passenger,
    required this.durationMinutes,
    required this.gainPerKmCents,
    required this.gainPerHourCents,
  });
}
