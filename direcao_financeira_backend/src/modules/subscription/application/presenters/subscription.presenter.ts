import { SubscriptionDetails } from '../../domain/repositories/subscription.repository';

export function toSubscriptionOutput(subscription: SubscriptionDetails) {
  return {
    id: subscription.id,
    status: subscription.status,
    startDate: subscription.startDate,
    endDate: subscription.endDate,
    canceledAt: subscription.canceledAt,
    autoRenew: subscription.autoRenew,
    createdAt: subscription.createdAt,
    updatedAt: subscription.updatedAt,
    plan: subscription.plan,
    payments: subscription.payments,
  };
}
