enum AccountType {
  checking,
  savings,
  wallet,
  investment,
  other;

  String get label {
    switch (this) {
      case AccountType.checking:
        return 'Conta Corrente';
      case AccountType.savings:
        return 'Poupanca';
      case AccountType.wallet:
        return 'Carteira (Dinheiro)';
      case AccountType.investment:
        return 'Investimento';
      case AccountType.other:
        return 'Outro';
    }
  }

  String toApiValue() => name.toUpperCase();

  static AccountType fromApiValue(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AccountType.other,
    );
  }
}

class BankAccountEntity {
  final int id;
  final String name;
  final String bankName;
  final AccountType accountType;
  final int initialBalanceCents;
  final int currentBalanceCents;
  final bool isActive;

  BankAccountEntity({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountType,
    required this.initialBalanceCents,
    required this.currentBalanceCents,
    required this.isActive,
  });

  double get currentBalance => currentBalanceCents / 100.0;
  double get initialBalance => initialBalanceCents / 100.0;
}
