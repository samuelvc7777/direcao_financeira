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
    super.openInvoiceCents,
    super.closedInvoiceCents,
    super.payableInvoiceCents,
    super.openInvoiceClosingDate,
    super.nextDueDate,
    super.isInvoiceDueToday,
    super.isInvoiceOverdue,
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
      openInvoiceCents: json['openInvoiceCents'] as int? ?? 0,
      closedInvoiceCents: json['closedInvoiceCents'] as int? ?? 0,
      payableInvoiceCents: json['payableInvoiceCents'] as int? ?? 0,
      openInvoiceClosingDate: json['openInvoiceClosingDate'] == null
          ? null
          : DateTime.tryParse(json['openInvoiceClosingDate'].toString()),
      nextDueDate: json['nextDueDate'] == null
          ? null
          : DateTime.tryParse(json['nextDueDate'].toString()),
      isInvoiceDueToday: json['isInvoiceDueToday'] as bool? ?? false,
      isInvoiceOverdue: json['isInvoiceOverdue'] as bool? ?? false,
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
      'openInvoiceCents': openInvoiceCents,
      'closedInvoiceCents': closedInvoiceCents,
      'payableInvoiceCents': payableInvoiceCents,
      'openInvoiceClosingDate': openInvoiceClosingDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isInvoiceDueToday': isInvoiceDueToday,
      'isInvoiceOverdue': isInvoiceOverdue,
    };
  }
}
