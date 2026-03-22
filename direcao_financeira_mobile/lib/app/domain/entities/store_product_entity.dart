class StoreProductEntity {
  final String productId;
  final String title;
  final String description;
  final String priceLabel;
  final double rawPrice;
  final String currencyCode;
  final String? offerToken;

  const StoreProductEntity({
    required this.productId,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.rawPrice,
    required this.currencyCode,
    this.offerToken,
  });
}
