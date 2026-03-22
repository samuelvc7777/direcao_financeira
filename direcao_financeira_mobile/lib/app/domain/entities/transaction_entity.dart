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
}

enum TransactionMutationScope {
  current,
  all;
}

enum TransactionStatus {
  cleared,
  pending;
}

class TransactionEntity {
  final int id;
  final TransactionType type;
  final TransactionStatus status;
  final AssetType assetType;
  final int amountCents;
  final int categoryId;
  final String description;
  final DateTime transactionDate;
  final int? bankAccountId;
  final int? creditCardId;
  final String? installmentGroupId;
  final int? installmentNumber;
  final int? installmentCount;

  // Campos extras que podem vir populados do backend (joins)
  final String? categoryName;
  final String? categoryColor;
  final String? categoryIcon;
  final String? assetName;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.assetType,
    required this.amountCents,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
    this.bankAccountId,
    this.creditCardId,
    this.installmentGroupId,
    this.installmentNumber,
    this.installmentCount,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.assetName,
  });

  double get amount => amountCents / 100.0;
}
