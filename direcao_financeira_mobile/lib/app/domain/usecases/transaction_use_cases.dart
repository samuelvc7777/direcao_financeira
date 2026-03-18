import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/bank_account_entity.dart';
import '../entities/category_entity.dart';
import '../entities/credit_card_entity.dart';
import '../entities/transaction_entity.dart';
import '../repositories/i_bank_account_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_credit_card_repository.dart';
import '../repositories/i_transaction_repository.dart';

class GetTransactionsUseCase {
  final ITransactionRepository repository;
  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    return await repository.getTransactions();
  }
}

class GetCategoriesUseCase {
  final ICategoryRepository repository;
  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() async {
    return await repository.getCategories();
  }
}

class GetBankAccountsUseCase {
  final IBankAccountRepository repository;
  GetBankAccountsUseCase(this.repository);

  Future<Either<Failure, List<BankAccountEntity>>> call() async {
    return await repository.getBankAccounts();
  }
}

class GetCreditCardsUseCase {
  final ICreditCardRepository repository;
  GetCreditCardsUseCase(this.repository);

  Future<Either<Failure, List<CreditCardEntity>>> call() async {
    return await repository.getCreditCards();
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
