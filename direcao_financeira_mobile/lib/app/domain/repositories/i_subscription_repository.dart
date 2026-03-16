import '../entities/plan_entity.dart';
import '../entities/subscription_entity.dart';

abstract class ISubscriptionRepository {
  Future<SubscriptionEntity?> getMySubscription();
  Future<List<SubscriptionEntity>> getSubscriptionHistory();
  Future<List<PlanEntity>> getAvailablePlans();
  Future<SubscriptionEntity?> changePlan(int planId);
  Future<SubscriptionEntity?> cancelSubscription();
  Future<SubscriptionEntity?> renewSubscription({required bool autoRenew});
  Future<void> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  });
}
