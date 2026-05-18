class DetectedRideDraftEntity {
  const DetectedRideDraftEntity({
    this.platformName,
    this.detectedAt,
    required this.paymentMethod,
    required this.grossValueCents,
    required this.netProfitCents,
    required this.totalKm,
    required this.totalTimeSeconds,
    required this.gainPerKmCents,
    required this.gainPerHourCents,
    this.passengerName,
    this.originAddress,
    this.destinationAddress,
    this.rideType,
  });

  final String? platformName;
  final DateTime? detectedAt;
  final String paymentMethod;
  final int grossValueCents;
  final int netProfitCents;
  final double totalKm;
  final int totalTimeSeconds;
  final int gainPerKmCents;
  final int gainPerHourCents;
  final String? passengerName;
  final String? originAddress;
  final String? destinationAddress;
  final String? rideType;
}
