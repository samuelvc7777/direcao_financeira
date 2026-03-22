import 'package:dio/dio.dart';

import '../models/credit_card_model.dart';

abstract class ICreditCardDataSource {
  Future<List<CreditCardModel>> getCreditCards();
  Future<CreditCardModel> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  });
  Future<CreditCardModel> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
    bool? isActive,
  });
  Future<void> deactivateCreditCard(int id);
  Future<void> reactivateCreditCard(int id);
}

class CreditCardRemoteDataSource implements ICreditCardDataSource {
  CreditCardRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<CreditCardModel>> getCreditCards() async {
    final response = await dio.get('/finance/credit-cards');
    final data = response.data;
    final items = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['data'] ?? data['creditCards'] ?? [])
            : [];

    if (items is! List) {
      return [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(CreditCardModel.fromJson)
        .toList();
  }

  @override
  Future<CreditCardModel> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async {
    final response = await dio.post(
      '/finance/credit-cards',
      data: {
        'name': name,
        'brand': brand,
        'color': color,
        'limitCents': limitCents,
        'closingDay': closingDay,
        'dueDay': dueDay,
        'lastFourDigits': lastFourDigits,
      },
    );

    return _parseCreditCard(response.data);
  }

  @override
  Future<CreditCardModel> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'brand': brand,
      'color': color,
      'limitCents': limitCents,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'lastFourDigits': lastFourDigits,
    };

    if (isActive != null) {
      data['isActive'] = isActive;
    }

    final response = await dio.patch('/finance/credit-cards/$id', data: data);
    return _parseCreditCard(response.data);
  }

  @override
  Future<void> deactivateCreditCard(int id) {
    return dio.delete('/finance/credit-cards/$id');
  }

  @override
  Future<void> reactivateCreditCard(int id) {
    return dio.patch(
      '/finance/credit-cards/$id',
      data: {'isActive': true},
    );
  }

  CreditCardModel _parseCreditCard(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['card'] is Map<String, dynamic>) {
        return CreditCardModel.fromJson(data['card'] as Map<String, dynamic>);
      }
      if (data['data'] is Map<String, dynamic>) {
        return CreditCardModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      return CreditCardModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de cartoes de credito.');
  }
}
