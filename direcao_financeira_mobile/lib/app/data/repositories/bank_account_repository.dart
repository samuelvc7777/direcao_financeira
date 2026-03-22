import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/repositories/i_bank_account_repository.dart';
import '../datasources/bank_account_datasource.dart';

class BankAccountRepository implements IBankAccountRepository {
  BankAccountRepository({required this.dataSource});

  final IBankAccountDataSource dataSource;

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      return Right(await dataSource.getBankAccounts());
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao carregar contas bancarias.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar contas bancarias.'));
    }
  }

  @override
  Future<Either<Failure, BankAccountEntity>> createBankAccount({
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
  }) async {
    try {
      return Right(
        await dataSource.createBankAccount(
          name: name,
          bankName: bankName,
          color: color,
          accountType: accountType,
          initialBalanceCents: initialBalanceCents,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao criar conta bancaria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao criar conta bancaria.'));
    }
  }

  @override
  Future<Either<Failure, BankAccountEntity>> updateBankAccount({
    required int id,
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
    bool? isActive,
  }) async {
    try {
      return Right(
        await dataSource.updateBankAccount(
          id: id,
          name: name,
          bankName: bankName,
          color: color,
          accountType: accountType,
          initialBalanceCents: initialBalanceCents,
          isActive: isActive,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao atualizar conta bancaria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao atualizar conta bancaria.'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateBankAccount(int id) async {
    try {
      await dataSource.deactivateBankAccount(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao desativar conta bancaria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao desativar conta bancaria.'));
    }
  }

  @override
  Future<Either<Failure, void>> reactivateBankAccount(int id) async {
    try {
      await dataSource.reactivateBankAccount(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar conta bancaria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar conta bancaria.'));
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
