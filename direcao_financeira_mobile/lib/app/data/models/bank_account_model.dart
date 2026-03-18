import '../../domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  BankAccountModel({
    required super.id,
    required super.name,
    required super.bankName,
    required super.accountType,
    required super.initialBalanceCents,
    required super.currentBalanceCents,
    required super.isActive,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      bankName: json['bankName'] as String,
      accountType: AccountType.fromApiValue(json['accountType'] as String),
      initialBalanceCents: json['initialBalanceCents'] as int,
      currentBalanceCents: json['currentBalanceCents'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bankName': bankName,
      'accountType': accountType.toApiValue(),
      'initialBalanceCents': initialBalanceCents,
      'currentBalanceCents': currentBalanceCents,
      'isActive': isActive,
    };
  }
}
