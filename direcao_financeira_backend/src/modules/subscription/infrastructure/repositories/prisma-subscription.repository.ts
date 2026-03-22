import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../../../../prisma/prisma.service';
import {
  SubscriptionDetails,
  SubscriptionRepository,
} from '../../domain/repositories/subscription.repository';

@Injectable()
export class PrismaSubscriptionRepository implements SubscriptionRepository {
  constructor(private readonly prisma: PrismaService) {}

  private readonly subscriptionInclude = {
    plan: true,
    payments: {
      orderBy: { createdAt: 'desc' as const },
    },
  };

  findActiveByUserId(userId: number): Promise<SubscriptionDetails | null> {
    return this.prisma.client.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: this.subscriptionInclude,
      orderBy: { createdAt: 'desc' },
    });
  }

  findHistoryByUserId(userId: number): Promise<SubscriptionDetails[]> {
    return this.prisma.client.subscription.findMany({
      where: { userId },
      include: this.subscriptionInclude,
      orderBy: { createdAt: 'desc' },
    });
  }

  findActivePlanById(planId: number) {
    return this.prisma.client.plan.findFirst({
      where: {
        id: planId,
        isActive: true,
      },
    });
  }

  async cancelActiveSubscription(userId: number, now: Date) {
    const currentSubscription = await this.findActiveByUserId(userId);

    if (!currentSubscription) {
      return null;
    }

    return this.prisma.client.subscription.update({
      where: { id: currentSubscription.id },
      data: {
        status: SubscriptionStatus.CANCELED,
        canceledAt: now,
        endDate: now,
        autoRenew: false,
      },
      include: this.subscriptionInclude,
    });
  }

  async changePlan(userId: number, planId: number, now: Date, endDate: Date) {
    return this.prisma.client.$transaction(async (tx) => {
      const currentSubscription = await tx.subscription.findFirst({
        where: {
          userId,
          status: SubscriptionStatus.ACTIVE,
        },
        orderBy: { createdAt: 'desc' },
      });

      if (currentSubscription) {
        await tx.subscription.update({
          where: { id: currentSubscription.id },
          data: {
            status: SubscriptionStatus.CANCELED,
            canceledAt: now,
            endDate: now,
            autoRenew: false,
          },
        });
      }

      return tx.subscription.create({
        data: {
          userId,
          planId,
          status: SubscriptionStatus.ACTIVE,
          startDate: now,
          endDate,
          autoRenew: false,
        },
        include: this.subscriptionInclude,
      });
    });
  }

  async renewActiveSubscription(
    userId: number,
    endDate: Date,
    autoRenew: boolean,
  ) {
    const activeSubscription = await this.findActiveByUserId(userId);

    if (!activeSubscription) {
      return null;
    }

    return this.prisma.client.subscription.update({
      where: { id: activeSubscription.id },
      data: {
        endDate,
        autoRenew,
      },
      include: this.subscriptionInclude,
    });
  }

  findLatestByUserId(userId: number): Promise<SubscriptionDetails | null> {
    return this.prisma.client.subscription.findFirst({
      where: { userId },
      include: {
        plan: true,
        payments: {
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  createSubscription(data: {
    userId: number;
    planId: number;
    startDate: Date;
    endDate: Date;
    autoRenew: boolean;
  }) {
    return this.prisma.client.subscription.create({
      data: {
        ...data,
        status: SubscriptionStatus.ACTIVE,
      },
      include: this.subscriptionInclude,
    });
  }
}
