import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/api_error_mapper.dart';
import '../../core/network/api_request_logger.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/repositories/i_bank_account_repository.dart';
import '../datasources/bank_account_datasource.dart';

class BankAccountRepository implements IBankAccountRepository {
  BankAccountRepository({
    required this.dataSource,
    required this.apiErrorMapper,
    required this.apiRequestLogger,
  });

  final IBankAccountDataSource dataSource;
  final ApiErrorMapper apiErrorMapper;
  final ApiRequestLogger apiRequestLogger;

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      return Right(await dataSource.getBankAccounts());
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.getBankAccounts',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao carregar contas bancarias.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.getBankAccounts',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao carregar contas bancarias.',
        ),
      );
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
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.createBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao criar conta bancaria.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.createBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao criar conta bancaria.',
        ),
      );
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
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.updateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao atualizar conta bancaria.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.updateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao atualizar conta bancaria.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deactivateBankAccount(int id) async {
    try {
      await dataSource.deactivateBankAccount(id);
      return const Right(null);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.deactivateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao desativar conta bancaria.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.deactivateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao desativar conta bancaria.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reactivateBankAccount(int id) async {
    try {
      await dataSource.reactivateBankAccount(id);
      return const Right(null);
    } on DioException catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.reactivateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro ao reativar conta bancaria.',
        ),
      );
    } catch (e) {
      apiRequestLogger.logRepositoryFailure(
        source: 'BankAccountRepository.reactivateBankAccount',
        error: e,
      );
      return Left(
        apiErrorMapper.mapToFailure(
          e,
          fallback: 'Erro inesperado ao reativar conta bancaria.',
        ),
      );
    }
  }
}
