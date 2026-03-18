import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/credit_card_entity.dart';
import '../../domain/repositories/i_credit_card_repository.dart';
import '../models/credit_card_model.dart';

class CreditCardRepository implements ICreditCardRepository {
  final Dio dio;

  CreditCardRepository({required this.dio});

  @override
  Future<Either<Failure, List<CreditCardEntity>>> getCreditCards() async {
    try {
      final response = await dio.get('/finance/credit-cards');
      final data = response.data;
      final items = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['data'] ?? data['creditCards'] ?? [])
              : [];

      if (items is! List) {
        return const Right([]);
      }

      return Right(
        items
            .whereType<Map<String, dynamic>>()
            .map(CreditCardModel.fromJson)
            .toList(),
      );
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
      final response = await dio.post(
        '/finance/credit-cards',
        data: {
          'name': name,
          'brand': brand,
          'limitCents': limitCents,
          'closingDay': closingDay,
          'dueDay': dueDay,
          'lastFourDigits': lastFourDigits,
        },
      );

      return Right(_parseCreditCard(response.data));
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
      final Map<String, dynamic> data = {
        'name': name,
        'brand': brand,
        'limitCents': limitCents,
        'closingDay': closingDay,
        'dueDay': dueDay,
        'lastFourDigits': lastFourDigits,
      };

      if (isActive != null) {
        data['isActive'] = isActive;
      }

      final response = await dio.patch(
        '/finance/credit-cards/$id',
        data: data,
      );

      return Right(_parseCreditCard(response.data));
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
      await dio.patch(
        '/finance/credit-cards/$id',
        data: {'isActive': false},
      );
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
      await dio.patch(
        '/finance/credit-cards/$id',
        data: {'isActive': true},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(_extractMessage(e, 'Erro ao reativar cartao de credito.')),
      );
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao reativar cartao de credito.'));
    }
  }

  CreditCardEntity _parseCreditCard(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['card'] is Map<String, dynamic>) {
        return CreditCardModel.fromJson(data['card']);
      }
      if (data['data'] is Map<String, dynamic>) {
        return CreditCardModel.fromJson(data['data']);
      }
      return CreditCardModel.fromJson(data);
    }

    throw Exception('Resposta invalida da API de cartoes de credito.');
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
