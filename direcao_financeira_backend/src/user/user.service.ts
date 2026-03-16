import { ConflictException, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { SubscriptionStatus } from '@prisma/client';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  private readonly userWithSubscriptionsInclude = {
    subscriptions: {
      include: { plan: true },
      orderBy: { createdAt: 'desc' as const },
    },
  };

  private formatUserResponse(user: any) {
    const activeSubscription =
      user.subscriptions?.find(
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
      subscriptions: user.subscriptions ?? [],
    };
  }

  async create(createUserDto: CreateUserDto) {
    try {
      const { password, planId, ...userData } = createUserDto;
      const hashedPassword = await bcrypt.hash(password, 10);

      let initialPlanId = planId;

      if (!initialPlanId && (!userData.role || userData.role === 'USER')) {
        const defaultPlan = await this.prisma.client.plan.findFirst({
          where: { isActive: true },
          orderBy: { priceCents: 'asc' },
        });

        if (defaultPlan) {
          initialPlanId = defaultPlan.id;
        }
      }

      const user = await this.prisma.client.user.create({
        data: {
          ...userData,
          password: hashedPassword,
          subscriptions:
            initialPlanId && (!userData.role || userData.role === 'USER')
              ? {
                  create: {
                    planId: initialPlanId,
                    status: SubscriptionStatus.ACTIVE,
                    autoRenew: false,
                  },
                }
              : undefined,
        },
        omit: { password: true },
        include: this.userWithSubscriptionsInclude,
      });

      return this.formatUserResponse(user);
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException('Este e-mail ja esta cadastrado.');
      }
      throw error;
    }
  }

  async findAll() {
    const users = await this.prisma.client.user.findMany({
      omit: { password: true },
      include: this.userWithSubscriptionsInclude,
    });

    return users.map((user) => this.formatUserResponse(user));
  }

  findByEmail(email: string) {
    return this.prisma.client.user.findUnique({
      where: { email },
      include: this.userWithSubscriptionsInclude,
    });
  }

  async findOne(id: number) {
    const user = await this.prisma.client.user.findUnique({
      where: { id },
      omit: { password: true },
      include: this.userWithSubscriptionsInclude,
    });

    if (!user) {
      return null;
    }

    return this.formatUserResponse(user);
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    const { planId, ...userData } = updateUserDto;

    const user = await this.prisma.client.user.update({
      where: { id },
      data: userData,
      omit: { password: true },
      include: this.userWithSubscriptionsInclude,
    });

    return this.formatUserResponse(user);
  }

  remove(id: number) {
    return this.prisma.client.user.delete({
      where: { id },
    });
  }

  async getProfileById(id: number) {
    return this.findOne(id);
  }
}
