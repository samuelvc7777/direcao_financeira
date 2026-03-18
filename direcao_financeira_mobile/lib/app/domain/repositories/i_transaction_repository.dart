import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class ITransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
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
  });
}
