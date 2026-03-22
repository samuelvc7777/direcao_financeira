import '../../domain/entities/credit_card_entity.dart';

class CreditCardModel extends CreditCardEntity {
  CreditCardModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.color,
    required super.limitCents,
    required super.availableLimitCents,
    required super.closingDay,
    required super.dueDay,
    required super.lastFourDigits,
    required super.isActive,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      color: (json['color'] as String?) ?? '#8B5CF6',
      limitCents: json['limitCents'] as int,
      availableLimitCents: json['availableLimitCents'] as int,
      closingDay: json['closingDay'] as int,
      dueDay: json['dueDay'] as int,
      lastFourDigits: json['lastFourDigits'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'color': color,
      'limitCents': limitCents,
      'availableLimitCents': availableLimitCents,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'lastFourDigits': lastFourDigits,
      'isActive': isActive,
    };
  }
}
