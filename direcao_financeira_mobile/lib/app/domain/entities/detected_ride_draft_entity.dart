class DetectedRideDraftEntity {
  const DetectedRideDraftEntity({
    required this.paymentMethod,
    required this.grossValueCents,
    required this.netProfitCents,
    required this.totalKm,
    required this.totalTimeSeconds,
    this.passengerName,
    this.originAddress,
    this.destinationAddress,
  });

  final String paymentMethod;
  final int grossValueCents;
  final int netProfitCents;
  final double totalKm;
  final int totalTimeSeconds;
  final String? passengerName;
  final String? originAddress;
  final String? destinationAddress;
}
