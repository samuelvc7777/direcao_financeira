import 'package:dio/dio.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../models/bank_account_model.dart';

abstract class IBankAccountDataSource {
  Future<List<BankAccountModel>> getBankAccounts();
  Future<BankAccountModel> createBankAccount({
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
  });
  Future<BankAccountModel> updateBankAccount({
    required int id,
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
    bool? isActive,
  });
  Future<void> deactivateBankAccount(int id);
  Future<void> reactivateBankAccount(int id);
}

class BankAccountRemoteDataSource implements IBankAccountDataSource {
  BankAccountRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    final response = await dio.get('/finance/bank-accounts');
    final data = response.data;
    final items = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['data'] ?? data['bankAccounts'] ?? [])
            : [];

    if (items is! List) {
      return [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(BankAccountModel.fromJson)
        .toList();
  }

  @override
  Future<BankAccountModel> createBankAccount({
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
  }) async {
    final response = await dio.post(
      '/finance/bank-accounts',
      data: {
        'name': name,
        'bankName': bankName,
        'color': color,
        'accountType': accountType.toApiValue(),
        'initialBalanceCents': initialBalanceCents,
      },
    );

    return _parseBankAccount(response.data);
  }

  @override
  Future<BankAccountModel> updateBankAccount({
    required int id,
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'bankName': bankName,
      'color': color,
      'accountType': accountType.toApiValue(),
      'initialBalanceCents': initialBalanceCents,
    };

    if (isActive != null) {
      data['isActive'] = isActive;
    }

    final response = await dio.patch('/finance/bank-accounts/$id', data: data);
    return _parseBankAccount(response.data);
  }

  @override
  Future<void> deactivateBankAccount(int id) {
    return dio.delete('/finance/bank-accounts/$id');
  }

  @override
  Future<void> reactivateBankAccount(int id) {
    return dio.patch(
      '/finance/bank-accounts/$id',
      data: {'isActive': true},
    );
  }

  BankAccountModel _parseBankAccount(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['account'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data['account'] as Map<String, dynamic>);
      }
      if (data['bankAccount'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(
          data['bankAccount'] as Map<String, dynamic>,
        );
      }
      if (data['data'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      return BankAccountModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de contas bancarias.');
  }
}
