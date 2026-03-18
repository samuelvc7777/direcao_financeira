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
  });
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
  Future<TransactionModel> createTransaction({
    required String type,
    required String assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required String transactionDate,
    int? bankAccountId,
    int? creditCardId,
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
      payload['accountId'] = bankAccountId; // Envia accountId como fallback
    }
    
    if (creditCardId != null) {
      payload['creditCardId'] = creditCardId;
      payload['accountId'] = creditCardId; // Envia accountId como fallback
    }

    final response = await dio.post(
      '/finance/transactions',
      data: payload,
    );

    return _parseTransaction(response.data);
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
