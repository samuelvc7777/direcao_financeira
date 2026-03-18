import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../datasources/subscription_datasource.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  SubscriptionRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ISubscriptionRemoteDataSource remoteDataSource;
  final ISubscriptionLocalDataSource localDataSource;

  @override
  Future<Either<Failure, SubscriptionEntity?>> getMySubscription() async {
    try {
      return Right(await remoteDataSource.getMySubscription());
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /subscriptions/me ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar assinatura.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar assinatura.'));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionHistory() async {
    try {
      return Right(await remoteDataSource.getSubscriptionHistory());
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /subscriptions/me/history ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar historico.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar histórico.'));
    }
  }

  @override
  Future<Either<Failure, List<PlanEntity>>> getAvailablePlans() async {
    try {
      return Right(await remoteDataSource.getAvailablePlans());
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /admin/plans ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(ServerFailure(_extractMessage(e, 'Erro ao carregar planos.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao carregar planos.'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> changePlan(int planId) async {
    try {
      return Right(await remoteDataSource.changePlan(planId));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao trocar o plano.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao trocar o plano.'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> cancelSubscription() async {
    try {
      return Right(await remoteDataSource.cancelSubscription());
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao cancelar assinatura.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao cancelar assinatura.'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> renewSubscription({
    required bool autoRenew,
  }) async {
    try {
      return Right(
        await remoteDataSource.renewSubscription(autoRenew: autoRenew),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Erro ao renovar assinatura.')));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao renovar assinatura.'));
    }
  }

  @override
  Future<Either<Failure, void>> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  }) async {
    try {
      await localDataSource.syncStoredUser(
        activeSubscription: activeSubscription,
        subscriptions: subscriptions,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao sincronizar dados do usuário.'));
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
