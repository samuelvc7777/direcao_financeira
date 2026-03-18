import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_transaction_repository.dart';

class GetTransactionsUseCase {
  final ITransactionRepository repository;
  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    return await repository.getTransactions();
  }
}

class CreateTransactionUseCase {
  final ITransactionRepository repository;
  CreateTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call({
    required TransactionType type,
    required AssetType assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required DateTime transactionDate,
    int? bankAccountId,
    int? creditCardId,
  }) async {
    return await repository.createTransaction(
      type: type,
      assetType: assetType,
      amountCents: amountCents,
      categoryId: categoryId,
      description: description,
      transactionDate: transactionDate,
      bankAccountId: bankAccountId,
      creditCardId: creditCardId,
    );
  }
}
