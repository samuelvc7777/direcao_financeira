class CreditCardEntity {
  final int id;
  final String name;
  final String brand;
  final int limitCents;
  final int availableLimitCents;
  final int closingDay;
  final int dueDay;
  final String lastFourDigits;
  final bool isActive;

  CreditCardEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.limitCents,
    required this.availableLimitCents,
    required this.closingDay,
    required this.dueDay,
    required this.lastFourDigits,
    required this.isActive,
  });

  double get limit => limitCents / 100.0;
  double get availableLimit => availableLimitCents / 100.0;
  double get usedLimit => (limitCents - availableLimitCents) / 100.0;
  double get usedPercentage => limitCents > 0 ? (limitCents - availableLimitCents) / limitCents : 0.0;
}
