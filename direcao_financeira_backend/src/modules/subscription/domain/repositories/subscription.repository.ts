import { SubscriptionStatus } from '@prisma/client';

export const SUBSCRIPTION_REPOSITORY = 'SUBSCRIPTION_REPOSITORY';

export interface SubscriptionPaymentSnapshot {
  id: number;
  subscriptionId: number;
  amountCents: number;
  status: string;
  method: string;
  externalReference: string | null;
  dueDate: Date | null;
  paidAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface SubscriptionDetails {
  id: number;
  userId: number;
  planId: number;
  status: SubscriptionStatus;
  startDate: Date;
  endDate: Date | null;
  canceledAt: Date | null;
  autoRenew: boolean;
  createdAt: Date;
  updatedAt: Date;
  plan: {
    id: number;
    code: string;
    name: string;
    description: string;
    priceCents: number;
    durationDays: number;
    color: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  };
  payments: SubscriptionPaymentSnapshot[];
}

export interface SubscriptionRepository {
  findActiveByUserId(userId: number): Promise<SubscriptionDetails | null>;
  findHistoryByUserId(userId: number): Promise<SubscriptionDetails[]>;
  findActivePlanById(
    planId: number,
  ): Promise<SubscriptionDetails['plan'] | null>;
  cancelActiveSubscription(
    userId: number,
    now: Date,
  ): Promise<SubscriptionDetails | null>;
  changePlan(
    userId: number,
    planId: number,
    now: Date,
    endDate: Date,
  ): Promise<SubscriptionDetails>;
  renewActiveSubscription(
    userId: number,
    endDate: Date,
    autoRenew: boolean,
  ): Promise<SubscriptionDetails | null>;
  findLatestByUserId(userId: number): Promise<SubscriptionDetails | null>;
  createSubscription(data: {
    userId: number;
    planId: number;
    startDate: Date;
    endDate: Date;
    autoRenew: boolean;
  }): Promise<SubscriptionDetails>;
}
