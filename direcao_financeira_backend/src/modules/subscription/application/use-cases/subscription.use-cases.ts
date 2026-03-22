import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ChangePlanDto } from '../../interface/dto/change-plan.dto';
import { RenewSubscriptionDto } from '../../interface/dto/renew-subscription.dto';
import { toSubscriptionOutput } from '../presenters/subscription.presenter';
import { SUBSCRIPTION_REPOSITORY } from '../../domain/repositories/subscription.repository';
import type { SubscriptionRepository } from '../../domain/repositories/subscription.repository';

@Injectable()
export class GetActiveSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY)
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  async execute(userId: number) {
    const subscription =
      await this.subscriptionRepository.findActiveByUserId(userId);
    return subscription ? toSubscriptionOutput(subscription) : null;
  }
}

@Injectable()
export class GetSubscriptionHistoryUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY)
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  async execute(userId: number) {
    const subscriptions =
      await this.subscriptionRepository.findHistoryByUserId(userId);
    return subscriptions.map((subscription) =>
      toSubscriptionOutput(subscription),
    );
  }
}

@Injectable()
export class ChangePlanUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY)
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  private addDays(baseDate: Date, days: number) {
    const nextDate = new Date(baseDate);
    nextDate.setDate(nextDate.getDate() + days);
    return nextDate;
  }

  async execute(userId: number, changePlanDto: ChangePlanDto) {
    const plan = await this.subscriptionRepository.findActivePlanById(
      changePlanDto.planId,
    );

    if (!plan) {
      throw new NotFoundException('Plano ativo nao encontrado.');
    }

    const currentSubscription =
      await this.subscriptionRepository.findActiveByUserId(userId);

    if (currentSubscription?.planId === plan.id) {
      throw new ConflictException('O usuario ja esta neste plano.');
    }

    const now = new Date();
    const endDate = this.addDays(now, plan.durationDays);
    const subscription = await this.subscriptionRepository.changePlan(
      userId,
      plan.id,
      now,
      endDate,
    );

    return toSubscriptionOutput(subscription);
  }
}

@Injectable()
export class CancelCurrentSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY)
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  async execute(userId: number) {
    const subscription =
      await this.subscriptionRepository.cancelActiveSubscription(
        userId,
        new Date(),
      );

    if (!subscription) {
      throw new NotFoundException('Nenhuma assinatura ativa foi encontrada.');
    }

    return toSubscriptionOutput(subscription);
  }
}

@Injectable()
export class RenewSubscriptionUseCase {
  constructor(
    @Inject(SUBSCRIPTION_REPOSITORY)
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  private addDays(baseDate: Date, days: number) {
    const nextDate = new Date(baseDate);
    nextDate.setDate(nextDate.getDate() + days);
    return nextDate;
  }

  async execute(userId: number, renewDto: RenewSubscriptionDto) {
    const activeSubscription =
      await this.subscriptionRepository.findActiveByUserId(userId);

    if (activeSubscription) {
      const renewalBaseDate = activeSubscription.endDate ?? new Date();
      const endDate = this.addDays(
        renewalBaseDate,
        activeSubscription.plan.durationDays,
      );
      const renewedSubscription =
        await this.subscriptionRepository.renewActiveSubscription(
          userId,
          endDate,
          renewDto.autoRenew ?? activeSubscription.autoRenew,
        );

      if (!renewedSubscription) {
        throw new NotFoundException('Nenhuma assinatura ativa foi encontrada.');
      }

      return toSubscriptionOutput(renewedSubscription);
    }

    const lastSubscription =
      await this.subscriptionRepository.findLatestByUserId(userId);

    if (!lastSubscription) {
      throw new NotFoundException(
        'Nenhum historico de assinatura foi encontrado.',
      );
    }

    if (!lastSubscription.plan.isActive) {
      throw new ConflictException(
        'O ultimo plano do usuario nao esta mais disponivel.',
      );
    }

    const now = new Date();
    const subscription = await this.subscriptionRepository.createSubscription({
      userId,
      planId: lastSubscription.planId,
      startDate: now,
      endDate: this.addDays(now, lastSubscription.plan.durationDays),
      autoRenew: renewDto.autoRenew ?? false,
    });

    return toSubscriptionOutput(subscription);
  }
}
