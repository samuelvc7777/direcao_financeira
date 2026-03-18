import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/credit_card_entity.dart';
import '../../domain/repositories/i_credit_card_repository.dart';
import '../datasources/credit_card_datasource.dart';

class CreditCardRepository implements ICreditCardRepository {
  CreditCardRepository({required this.dataSource});

  final ICreditCardDataSource dataSource;

  @override
  Future<Either<Failure, List<CreditCardEntity>>> getCreditCards() async {
    try {
      return Right(await dataSource.getCreditCards());
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao carregar cartoes de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar cartoes de credito.'));
    }
  }

  @override
  Future<Either<Failure, CreditCardEntity>> createCreditCard({
    required String name,
    required String brand,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async {
    try {
      return Right(
        await dataSource.createCreditCard(
          name: name,
          brand: brand,
          limitCents: limitCents,
          closingDay: closingDay,
          dueDay: dueDay,
          lastFourDigits: lastFourDigits,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao criar cartao de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao criar cartao de credito.'));
    }
  }

  @override
  Future<Either<Failure, CreditCardEntity>> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
    bool? isActive,
  }) async {
    try {
      return Right(
        await dataSource.updateCreditCard(
          id: id,
          name: name,
          brand: brand,
          limitCents: limitCents,
          closingDay: closingDay,
          dueDay: dueDay,
          lastFourDigits: lastFourDigits,
          isActive: isActive,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao atualizar cartao de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao atualizar cartao de credito.'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateCreditCard(int id) async {
    try {
      await dataSource.deactivateCreditCard(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao desativar cartao de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao desativar cartao de credito.'));
    }
  }

  @override
  Future<Either<Failure, void>> reactivateCreditCard(int id) async {
    try {
      await dataSource.reactivateCreditCard(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar cartao de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar cartao de credito.'));
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
