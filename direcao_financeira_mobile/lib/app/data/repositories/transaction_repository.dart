import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_datasource.dart';

class TransactionRepository implements ITransactionRepository {
  final ITransactionDataSource dataSource;

  TransactionRepository({required this.dataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final items = await dataSource.getTransactions();
      return Right(items);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar transacoes.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar transacoes.'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id) async {
    try {
      final transaction = await dataSource.getTransaction(id);
      return Right(transaction);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar transacao.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar transacao.'));
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
        type: type.toApiValue(),
        assetType: assetType.toApiValue(),
        amountCents: amountCents,
        categoryId: categoryId,
        description: description,
        transactionDate: transactionDate.toIso8601String(),
        bankAccountId: bankAccountId,
        creditCardId: creditCardId,
        installmentCount: installmentCount,
      );

      return Right(transaction);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao criar transacao.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao criar transacao.'));
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
        transactionDate: transactionDate?.toIso8601String(),
        scope: scope?.toApiValue(),
      );
      return Right(transaction);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao atualizar transacao.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao atualizar transacao.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async {
    try {
      await dataSource.deleteTransaction(id, scope: scope?.toApiValue());
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao excluir transacao.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao excluir transacao.'));
    }
  }

  String _extractMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      if (message != null) {
        return message.toString();
      }
    }
    return fallback;
  }
}
