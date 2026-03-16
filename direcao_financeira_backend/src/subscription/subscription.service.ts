import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ChangePlanDto } from './dto/change-plan.dto';
import { RenewSubscriptionDto } from './dto/renew-subscription.dto';

@Injectable()
export class SubscriptionService {
  constructor(private prisma: PrismaService) {}

  private readonly subscriptionInclude = {
    plan: true,
    payments: {
      orderBy: { createdAt: 'desc' as const },
    },
  };

  private formatSubscription(subscription: any) {
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
      payments: subscription.payments ?? [],
    };
  }

  private addDays(baseDate: Date, days: number) {
    const nextDate = new Date(baseDate);
    nextDate.setDate(nextDate.getDate() + days);
    return nextDate;
  }

  async getActiveSubscription(userId: number) {
    const subscription = await this.prisma.client.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: this.subscriptionInclude,
      orderBy: { createdAt: 'desc' },
    });

    if (!subscription) {
      return null;
    }

    return this.formatSubscription(subscription);
  }

  async getSubscriptionHistory(userId: number) {
    const subscriptions = await this.prisma.client.subscription.findMany({
      where: { userId },
      include: this.subscriptionInclude,
      orderBy: { createdAt: 'desc' },
    });

    return subscriptions.map((subscription) => this.formatSubscription(subscription));
  }

  async changePlan(userId: number, changePlanDto: ChangePlanDto) {
    const plan = await this.prisma.client.plan.findFirst({
      where: {
        id: changePlanDto.planId,
        isActive: true,
      },
    });

    if (!plan) {
      throw new NotFoundException('Plano ativo nao encontrado.');
    }

    const currentSubscription = await this.prisma.client.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: { plan: true },
      orderBy: { createdAt: 'desc' },
    });

    if (currentSubscription?.planId === plan.id) {
      throw new ConflictException('O usuario ja esta neste plano.');
    }

    const now = new Date();
    const endDate = this.addDays(now, plan.durationDays);

    const subscription = await this.prisma.client.$transaction(async (tx) => {
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
          planId: plan.id,
          status: SubscriptionStatus.ACTIVE,
          startDate: now,
          endDate,
          autoRenew: false,
        },
        include: this.subscriptionInclude,
      });
    });

    return this.formatSubscription(subscription);
  }

  async cancelCurrentSubscription(userId: number) {
    const currentSubscription = await this.prisma.client.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: this.subscriptionInclude,
      orderBy: { createdAt: 'desc' },
    });

    if (!currentSubscription) {
      throw new NotFoundException('Nenhuma assinatura ativa foi encontrada.');
    }

    const now = new Date();
    const subscription = await this.prisma.client.subscription.update({
      where: { id: currentSubscription.id },
      data: {
        status: SubscriptionStatus.CANCELED,
        canceledAt: now,
        endDate: now,
        autoRenew: false,
      },
      include: this.subscriptionInclude,
    });

    return this.formatSubscription(subscription);
  }

  async renewSubscription(userId: number, renewDto: RenewSubscriptionDto) {
    const activeSubscription = await this.prisma.client.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      include: { plan: true },
      orderBy: { createdAt: 'desc' },
    });

    if (activeSubscription) {
      const renewalBaseDate = activeSubscription.endDate ?? new Date();
      const endDate = this.addDays(renewalBaseDate, activeSubscription.plan.durationDays);

      const renewedSubscription = await this.prisma.client.subscription.update({
        where: { id: activeSubscription.id },
        data: {
          endDate,
          autoRenew: renewDto.autoRenew ?? activeSubscription.autoRenew,
        },
        include: this.subscriptionInclude,
      });

      return this.formatSubscription(renewedSubscription);
    }

    const lastSubscription = await this.prisma.client.subscription.findFirst({
      where: { userId },
      include: { plan: true },
      orderBy: { createdAt: 'desc' },
    });

    if (!lastSubscription) {
      throw new NotFoundException('Nenhum historico de assinatura foi encontrado.');
    }

    if (!lastSubscription.plan.isActive) {
      throw new ConflictException('O ultimo plano do usuario nao esta mais disponivel.');
    }

    const now = new Date();
    const subscription = await this.prisma.client.subscription.create({
      data: {
        userId,
        planId: lastSubscription.planId,
        status: SubscriptionStatus.ACTIVE,
        startDate: now,
        endDate: this.addDays(now, lastSubscription.plan.durationDays),
        autoRenew: renewDto.autoRenew ?? false,
      },
      include: this.subscriptionInclude,
    });

    return this.formatSubscription(subscription);
  }
}
