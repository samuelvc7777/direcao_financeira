import 'package:dio/dio.dart';
import '../models/transaction_model.dart';

abstract class ITransactionDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> getTransaction(int id);
  Future<TransactionModel> createTransaction({
    required String type,
    required String assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required String transactionDate,
    int? bankAccountId,
    int? creditCardId,
    int? installmentCount,
  });

  Future<TransactionModel> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    String? transactionDate,
    String? scope,
  });

  Future<void> deleteTransaction(int id, {String? scope});
}

class TransactionRemoteDataSource implements ITransactionDataSource {
  final Dio dio;

  TransactionRemoteDataSource({required this.dio});

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await dio.get('/finance/transactions');
    final data = response.data;
    final items = data is List
        ? data
        : data is Map<String, dynamic>
        ? (data['data'] ?? data['transactions'] ?? [])
        : [];

    if (items is! List) return [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();
  }

  @override
  Future<TransactionModel> getTransaction(int id) async {
    final response = await dio.get('/finance/transactions/$id');
    return _parseTransaction(response.data);
  }

  @override
  @override
  Future<TransactionModel> createTransaction({
    required String type,
    required String assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required String transactionDate,
    int? bankAccountId,
    int? creditCardId,
    int? installmentCount,
  }) async {
    final Map<String, dynamic> payload = {
      'type': type,
      'assetType': assetType,
      'amountCents': amountCents,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': transactionDate,
    };

    if (bankAccountId != null) {
      payload['bankAccountId'] = bankAccountId;
    }
    if (creditCardId != null) {
      payload['creditCardId'] = creditCardId;
    }
    if (installmentCount != null && installmentCount > 1) {
      payload['installmentCount'] = installmentCount;
    }

    final response = await dio.post('/finance/transactions', data: payload);

    return _parseTransaction(response.data);
  }

  @override
  Future<TransactionModel> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    String? transactionDate,
    String? scope,
  }) async {
    final Map<String, dynamic> payload = {};
    if (categoryId != null) payload['categoryId'] = categoryId;
    if (description != null) payload['description'] = description;
    if (amountCents != null) payload['amountCents'] = amountCents;
    if (transactionDate != null) payload['transactionDate'] = transactionDate;
    if (scope != null) payload['scope'] = scope;

    final response = await dio.patch('/finance/transactions/$id', data: payload);
    return _parseTransaction(response.data);
  }

  @override
  Future<void> deleteTransaction(int id, {String? scope}) async {
    await dio.delete(
      '/finance/transactions/$id',
      data: scope != null ? {'scope': scope} : null,
    );
  }

  TransactionModel _parseTransaction(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['transaction'] is Map<String, dynamic>) {
        return TransactionModel.fromJson(data['transaction']);
      }
      if (data['data'] is Map<String, dynamic>) {
        return TransactionModel.fromJson(data['data']);
      }
      return TransactionModel.fromJson(data);
    }
    throw Exception('Resposta invalida da API de transacoes.');
  }
}
