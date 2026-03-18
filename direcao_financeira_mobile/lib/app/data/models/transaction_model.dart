import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.type,
    required super.assetType,
    required super.amountCents,
    required super.categoryId,
    required super.description,
    required super.transactionDate,
    super.bankAccountId,
    super.creditCardId,
    super.categoryName,
    super.categoryColor,
    super.categoryIcon,
    super.assetName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final bankAccount = json['bankAccount'] as Map<String, dynamic>?;
    final creditCard = json['creditCard'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'] as int,
      type: TransactionType.fromApiValue(json['type'] as String),
      assetType: AssetType.fromApiValue(json['assetType'] as String),
      amountCents: json['amountCents'] as int,
      categoryId: json['categoryId'] as int,
      description: json['description'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      bankAccountId: json['bankAccountId'] as int?,
      creditCardId: json['creditCardId'] as int?,
      categoryName: category?['name'] as String?,
      categoryColor: category?['color'] as String?,
      categoryIcon: category?['icon'] as String?,
      assetName: (bankAccount?['name'] ?? creditCard?['name']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiValue(),
      'assetType': assetType.toApiValue(),
      'amountCents': amountCents,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      if (bankAccountId != null) 'bankAccountId': bankAccountId,
      if (creditCardId != null) 'creditCardId': creditCardId,
    };
  }
}
