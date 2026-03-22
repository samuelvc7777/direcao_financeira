import { SubscriptionStatus } from '@prisma/client';
import {
  UserSubscriptionSnapshot,
  UserWithSubscriptions,
} from '../repositories/user.repository';

export interface UserProfileOutput {
  id: number;
  name: string;
  email: string;
  role: 'USER' | 'ADMIN' | 'ATTENDANT';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  activeSubscription: UserSubscriptionSnapshot | null;
  subscriptions: UserSubscriptionSnapshot[];
}

export function toUserProfileOutput(
  user: UserWithSubscriptions,
): UserProfileOutput {
  const activeSubscription =
    user.subscriptions.find(
      (subscription) => subscription.status === SubscriptionStatus.ACTIVE,
    ) ?? null;

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    activeSubscription,
    subscriptions: user.subscriptions,
  };
}
