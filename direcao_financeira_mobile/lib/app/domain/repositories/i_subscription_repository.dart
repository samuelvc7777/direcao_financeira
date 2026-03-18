import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/plan_entity.dart';
import '../entities/subscription_entity.dart';

abstract class ISubscriptionRepository {
  Future<Either<Failure, SubscriptionEntity?>> getMySubscription();
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionHistory();
  Future<Either<Failure, List<PlanEntity>>> getAvailablePlans();
  Future<Either<Failure, SubscriptionEntity?>> changePlan(int planId);
  Future<Either<Failure, SubscriptionEntity?>> cancelSubscription();
  Future<Either<Failure, SubscriptionEntity?>> renewSubscription({required bool autoRenew});
  Future<Either<Failure, void>> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  });
}
