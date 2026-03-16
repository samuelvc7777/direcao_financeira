import { Injectable } from '@nestjs/common';
import { SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats() {
    const dayAgo = new Date();
    dayAgo.setDate(dayAgo.getDate() - 1);

    const [totalUsers, activeUsers, newUsers24h, activeSubscriptions, plansCatalog] =
      await Promise.all([
        this.prisma.client.user.count(),
        this.prisma.client.user.count({ where: { isActive: true } }),
        this.prisma.client.user.count({ where: { createdAt: { gte: dayAgo } } }),
        this.prisma.client.subscription.findMany({
          where: { status: SubscriptionStatus.ACTIVE },
          include: { plan: true },
        }),
        this.prisma.client.plan.findMany({
          orderBy: { priceCents: 'asc' },
        }),
      ]);

    const estimatedRevenueCents = activeSubscriptions.reduce((sum, subscription) => {
      return sum + subscription.plan.priceCents;
    }, 0);

    const plans = plansCatalog.map((plan) => {
      const activeCount = activeSubscriptions.filter(
        (subscription) => subscription.planId === plan.id,
      ).length;

      return {
        name: plan.name,
        code: plan.code,
        count: activeCount,
        revenue: activeCount * (plan.priceCents / 100),
        revenueCents: activeCount * plan.priceCents,
      };
    });

    return {
      metrics: {
        totalUsers,
        activeUsers,
        newUsers24h,
        activeSubscriptions: activeSubscriptions.length,
        estimatedRevenue: estimatedRevenueCents / 100,
        estimatedRevenueCents,
      },
      plans,
      recentActivity: [],
    };
  }
}
