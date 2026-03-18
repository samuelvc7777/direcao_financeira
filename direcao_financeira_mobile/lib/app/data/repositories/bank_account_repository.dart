import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/repositories/i_bank_account_repository.dart';
import '../models/bank_account_model.dart';

class BankAccountRepository implements IBankAccountRepository {
  final Dio dio;

  BankAccountRepository({required this.dio});

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      final response = await dio.get('/finance/bank-accounts');
      final data = response.data;
      final items = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['data'] ?? data['bankAccounts'] ?? [])
              : [];

      if (items is! List) {
        return const Right([]);
      }

      return Right(
        items
            .whereType<Map<String, dynamic>>()
            .map(BankAccountModel.fromJson)
            .toList(),
      );
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
    required AccountType accountType,
    required int initialBalanceCents,
  }) async {
    try {
      final response = await dio.post(
        '/finance/bank-accounts',
        data: {
          'name': name,
          'bankName': bankName,
          'accountType': accountType.toApiValue(),
          'initialBalanceCents': initialBalanceCents,
        },
      );

      return Right(_parseBankAccount(response.data));
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
    required AccountType accountType,
    required int initialBalanceCents,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'bankName': bankName,
        'accountType': accountType.toApiValue(),
        'initialBalanceCents': initialBalanceCents,
      };

      if (isActive != null) {
        data['isActive'] = isActive;
      }

      final response = await dio.patch(
        '/finance/bank-accounts/$id',
        data: data,
      );

      return Right(_parseBankAccount(response.data));
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
      await dio.patch(
        '/finance/bank-accounts/$id',
        data: {'isActive': false},
      );
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
      await dio.patch(
        '/finance/bank-accounts/$id',
        data: {'isActive': true},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar conta bancaria.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar conta bancaria.'));
    }
  }

  BankAccountEntity _parseBankAccount(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['account'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data['account']);
      }
      if (data['bankAccount'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data['bankAccount']);
      }
      if (data['data'] is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data['data']);
      }
      return BankAccountModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de contas bancarias.');
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
