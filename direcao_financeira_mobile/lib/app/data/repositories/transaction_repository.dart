import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/api_error_mapper.dart';
import '../../core/network/api_request_logger.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_datasource.dart';

class TransactionRepository implements ITransactionRepository {
  TransactionRepository({
    required this.dataSource,
    required this.apiErrorMapper,
    required this.apiRequestLogger,
  });

  final ITransactionDataSource dataSource;
  final ApiErrorMapper apiErrorMapper;
  final ApiRequestLogger apiRequestLogger;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required DateTime referenceMonth,
  }) async {
    try {
      final items = await dataSource.getTransactions(
        referenceMonth: referenceMonth,
      );
      return Right(items);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.getTransactions',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar transacoes.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.getTransactions',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao carregar transacoes.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id) async {
    try {
      final transaction = await dataSource.getTransaction(id);
      return Right(transaction);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.getTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao carregar transacao.'),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.getTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao carregar transacao.',
        ),
      );
    }
  }

  @override
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
  }) async {
    try {
      final transaction = await dataSource.createTransaction(
        type: type,
        assetType: assetType,
        amountCents: amountCents,
        categoryId: categoryId,
        description: description,
        transactionDate: transactionDate,
        bankAccountId: bankAccountId,
        creditCardId: creditCardId,
        installmentCount: installmentCount,
      );

      return Right(transaction);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.createTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao criar transacao.'),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.createTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao criar transacao.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createInvoicePayment({
    required int bankAccountId,
    required int creditCardId,
    required int amountCents,
    required int expenseCategoryId,
    required int incomeCategoryId,
    required String description,
    required DateTime transactionDate,
  }) async {
    try {
      await dataSource.createInvoicePayment(
        bankAccountId: bankAccountId,
        creditCardId: creditCardId,
        amountCents: amountCents,
        expenseCategoryId: expenseCategoryId,
        incomeCategoryId: incomeCategoryId,
        description: description,
        transactionDate: transactionDate,
      );

      return const Right(null);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.createInvoicePayment',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao pagar fatura do cartao.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.createInvoicePayment',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao pagar fatura do cartao.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  }) async {
    try {
      final transaction = await dataSource.updateTransaction(
        id,
        categoryId: categoryId,
        description: description,
        amountCents: amountCents,
        transactionDate: transactionDate,
        scope: scope,
      );
      return Right(transaction);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.updateTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao atualizar transacao.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.updateTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao atualizar transacao.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async {
    try {
      await dataSource.deleteTransaction(id, scope: scope);
      return const Right(null);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.deleteTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(e, fallback: 'Erro ao excluir transacao.'),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'TransactionRepository.deleteTransaction',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao excluir transacao.',
        ),
      );
    }
  }
}
