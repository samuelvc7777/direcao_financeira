enum TransactionType {
  income,
  expense;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
    }
  }

  String toApiValue() => name.toUpperCase();

  static TransactionType fromApiValue(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => TransactionType.expense,
    );
  }
}

enum AssetType {
  bankAccount,
  creditCard;

  String get label {
    switch (this) {
      case AssetType.bankAccount:
        return 'Conta Bancaria';
      case AssetType.creditCard:
        return 'Cartao de Credito';
    }
  }

  String toApiValue() {
    switch (this) {
      case AssetType.bankAccount:
        return 'BANK_ACCOUNT';
      case AssetType.creditCard:
        return 'CREDIT_CARD';
    }
  }

  static AssetType fromApiValue(String value) {
    if (value.toUpperCase() == 'BANK_ACCOUNT') return AssetType.bankAccount;
    if (value.toUpperCase() == 'CREDIT_CARD') return AssetType.creditCard;
    return AssetType.bankAccount; // default fallback
  }
}

class TransactionEntity {
  final int id;
  final TransactionType type;
  final AssetType assetType;
  final int amountCents;
  final int categoryId;
  final String description;
  final DateTime transactionDate;
  final int? bankAccountId;
  final int? creditCardId;

  // Campos extras que podem vir populados do backend (joins)
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final String? assetName;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.assetType,
    required this.amountCents,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
    this.bankAccountId,
    this.creditCardId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.assetName,
  });

  double get amount => amountCents / 100.0;
}
