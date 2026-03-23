class DetectedRideDraftEntity {
  const DetectedRideDraftEntity({
    this.platformName,
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
  });

  final String? platformName;
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
}
