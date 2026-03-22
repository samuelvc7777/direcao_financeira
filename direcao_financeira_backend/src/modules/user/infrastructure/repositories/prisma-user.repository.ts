import { ConflictException, Injectable } from '@nestjs/common';
import { SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../../../../prisma/prisma.service';
import { CreateUserDto } from '../../interface/dto/create-user.dto';
import { UpdateUserDto } from '../../interface/dto/update-user.dto';
import {
  UserRepository,
  UserWithSubscriptions,
} from '../../domain/repositories/user.repository';

function isPrismaKnownError(error: unknown): error is { code: string } {
  return typeof error === 'object' && error !== null && 'code' in error;
}

@Injectable()
export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  private readonly userWithSubscriptionsInclude = {
    subscriptions: {
      include: { plan: true },
      orderBy: { createdAt: 'desc' as const },
    },
  };

  async create(
    data: CreateUserDto & { password: string },
  ): Promise<UserWithSubscriptions> {
    try {
      const { planId, ...userData } = data;

      return await this.prisma.client.user.create({
        data: {
          ...userData,
          subscriptions:
            planId && (!userData.role || userData.role === 'USER')
              ? {
                  create: {
                    planId,
                    status: SubscriptionStatus.ACTIVE,
                    autoRenew: false,
                  },
                }
              : undefined,
        },
        include: this.userWithSubscriptionsInclude,
      });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2002') {
        throw new ConflictException('Este e-mail ja esta cadastrado.');
      }
      throw error;
    }
  }

  findAll(): Promise<UserWithSubscriptions[]> {
    return this.prisma.client.user.findMany({
      include: this.userWithSubscriptionsInclude,
    });
  }

  findById(id: number): Promise<UserWithSubscriptions | null> {
    return this.prisma.client.user.findUnique({
      where: { id },
      include: this.userWithSubscriptionsInclude,
    });
  }

  findByEmail(email: string): Promise<UserWithSubscriptions | null> {
    return this.prisma.client.user.findUnique({
      where: { email },
      include: this.userWithSubscriptionsInclude,
    });
  }

  update(
    id: number,
    data: Omit<UpdateUserDto, 'planId'>,
  ): Promise<UserWithSubscriptions> {
    return this.prisma.client.user.update({
      where: { id },
      data,
      include: this.userWithSubscriptionsInclude,
    });
  }

  async remove(id: number) {
    await this.prisma.client.user.delete({
      where: { id },
    });
  }

  async findDefaultActivePlanId() {
    const defaultPlan = await this.prisma.client.plan.findFirst({
      where: { isActive: true },
      orderBy: { priceCents: 'asc' },
    });

    return defaultPlan?.id ?? null;
  }
}
