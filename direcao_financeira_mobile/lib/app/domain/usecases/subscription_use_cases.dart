import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/plan_entity.dart';
import '../entities/subscription_entity.dart';
import '../repositories/i_subscription_repository.dart';

class GetMySubscriptionUseCase {
  GetMySubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, SubscriptionEntity?>> call() {
    return _repository.getMySubscription();
  }
}

class GetSubscriptionHistoryUseCase {
  GetSubscriptionHistoryUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, List<SubscriptionEntity>>> call() {
    return _repository.getSubscriptionHistory();
  }
}

class GetAvailablePlansUseCase {
  GetAvailablePlansUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, List<PlanEntity>>> call() {
    return _repository.getAvailablePlans();
  }
}

class ChangePlanUseCase {
  ChangePlanUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, SubscriptionEntity?>> call(int planId) {
    return _repository.changePlan(planId);
  }
}

class CancelSubscriptionUseCase {
  CancelSubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, SubscriptionEntity?>> call() {
    return _repository.cancelSubscription();
  }
}

class RenewSubscriptionUseCase {
  RenewSubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, SubscriptionEntity?>> call({
    required bool autoRenew,
  }) {
    return _repository.renewSubscription(autoRenew: autoRenew);
  }
}

class SyncStoredUserSubscriptionUseCase {
  SyncStoredUserSubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Either<Failure, void>> call({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  }) {
    return _repository.syncStoredUser(
      activeSubscription: activeSubscription,
      subscriptions: subscriptions,
    );
  }
}
