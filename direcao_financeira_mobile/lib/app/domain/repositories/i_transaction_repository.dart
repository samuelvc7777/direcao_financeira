import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class ITransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required DateTime referenceMonth,
  });
  Future<Either<Failure, TransactionEntity>> getTransaction(int id);
  Future<Either<Failure, TransactionEntity>> createTransaction({
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

  Future<Either<Failure, TransactionEntity>> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  });

  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  });
}
