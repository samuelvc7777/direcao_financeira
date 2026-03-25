import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

abstract class ITransactionDataSource {
  Future<List<TransactionModel>> getTransactions({
    required DateTime referenceMonth,
  });
  Future<TransactionModel> getTransaction(int id);
  Future<TransactionModel> createTransaction({
    required TransactionType type,
    required AssetType assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required DateTime transactionDate,
    int? bankAccountId,
    int? creditCardId,
    int? installmentCount,
  });

  Future<TransactionModel> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  });

  Future<void> deleteTransaction(int id, {TransactionMutationScope? scope});
}
