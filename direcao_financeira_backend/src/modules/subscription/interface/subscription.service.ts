import { Injectable } from '@nestjs/common';
import { ChangePlanDto } from './dto/change-plan.dto';
import { RenewSubscriptionDto } from './dto/renew-subscription.dto';
import {
  CancelCurrentSubscriptionUseCase,
  ChangePlanUseCase,
  GetActiveSubscriptionUseCase,
  GetSubscriptionHistoryUseCase,
  RenewSubscriptionUseCase,
} from '../application/use-cases/subscription.use-cases';

@Injectable()
export class SubscriptionService {
  constructor(
    private readonly getActiveSubscriptionUseCase: GetActiveSubscriptionUseCase,
    private readonly getSubscriptionHistoryUseCase: GetSubscriptionHistoryUseCase,
    private readonly changePlanUseCase: ChangePlanUseCase,
    private readonly cancelCurrentSubscriptionUseCase: CancelCurrentSubscriptionUseCase,
    private readonly renewSubscriptionUseCase: RenewSubscriptionUseCase,
  ) {}

  getActiveSubscription(userId: number) {
    return this.getActiveSubscriptionUseCase.execute(userId);
  }

  getSubscriptionHistory(userId: number) {
    return this.getSubscriptionHistoryUseCase.execute(userId);
  }

  changePlan(userId: number, changePlanDto: ChangePlanDto) {
    return this.changePlanUseCase.execute(userId, changePlanDto);
  }

  cancelCurrentSubscription(userId: number) {
    return this.cancelCurrentSubscriptionUseCase.execute(userId);
  }

  renewSubscription(userId: number, renewDto: RenewSubscriptionDto) {
    return this.renewSubscriptionUseCase.execute(userId, renewDto);
  }
}
